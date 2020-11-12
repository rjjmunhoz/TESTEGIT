/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de ContentDocumentLink  e ContentVersion
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-07-10      Eduardo Costa           class created 
**************************************************************************************************************/
public without sharing class ContentDocumentHandler_cls {
	public static void versionControlContentDocumentLink(List<ContentDocumentLink> aContentDocumentLinkLst) {

		Set<Id> lOrderIdSet = new Set<Id>();
		Set<Id> lContentDocumentLinkIdSet = new Set<Id>();
		for(ContentDocumentLink lContentLink :aContentDocumentLinkLst) {
			String lObjectName = lContentLink.LinkedEntityId.getSObjectType().getDescribe().getName();
		  	if (lObjectName == 'Order') {
                lOrderIdSet.add(lContentLink.LinkedEntityId);
                lContentDocumentLinkIdSet.add(lContentLink.Id);
		  	}
	  	}

        if(lOrderIdSet.isEmpty()) return;
        
        versionControl(lContentDocumentLinkIdSet, lOrderIdSet);
	}

    public static void versionControlContentVersion(List<ContentVersion> aContentVersionLst) {

		Set<Id> lContentDocumentIdSet = new Set<Id>();
		for(ContentVersion lContentVersion :aContentVersionLst) {
			lContentDocumentIdSet.add(lContentVersion.ContentDocumentId);
	  	}

        Set<Id> lOrderIdSet = new Set<Id>();
        Set<Id> lContentDocumentLinkIdSet = new Set<Id>();
        for(ContentDocumentLink lContentLink :[SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :lContentDocumentIdSet]) {
            String lObjectName = lContentLink.LinkedEntityId.getSObjectType().getDescribe().getName();
            if (lObjectName == 'Order') {
                lOrderIdSet.add(lContentLink.LinkedEntityId);
                lContentDocumentLinkIdSet.add(lContentLink.Id);
            }
        }

        if(lOrderIdSet.isEmpty()) return;
        
        versionControl(lContentDocumentLinkIdSet, lOrderIdSet);
	}

    public static void versionControl(Set<Id> aContentDocumentLinkIdSet, Set<Id> aOrderIdSet) {
        
        Set<Id> lContentDocumentIdSet = new Set<Id>();        
        Map<String,List<ContentDocumentLink>> lNFNameContentDocumentLinkMap = new Map<String,List<ContentDocumentLink>>();
		for(ContentDocumentLink lContentLink :[SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE Id IN :aContentDocumentLinkIdSet]) {
            List<ContentDocumentLink> lContentDocumentLinkLst = lNFNameContentDocumentLinkMap.get(lContentLink.ContentDocument.Title);
            if(lContentDocumentLinkLst == null) {
                lContentDocumentLinkLst = new List<ContentDocumentLink>();
                lNFNameContentDocumentLinkMap.put(lContentLink.ContentDocument.Title,lContentDocumentLinkLst);
            }
            lContentDocumentLinkLst.add(lContentLink);
	  	}

        Map<Id,ContentDocumentLink> lContentDocumentLinkToDeleteMap = new Map<Id,ContentDocumentLink>();
        Map<Id,Id> lContentDocumentToMoveVersionMap = new Map<Id,Id>();
        for(ContentDocumentLink lContentLink :[SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :aOrderIdSet AND Id NOT IN :aContentDocumentLinkIdSet]) {

			if(lNFNameContentDocumentLinkMap.containsKey(lContentLink.ContentDocument.Title)) {
                for(ContentDocumentLink lCdLink :lNFNameContentDocumentLinkMap.get(lContentLink.ContentDocument.Title)) {
                    // Chave contem o ContentDocument que será movido para o Valor
                    lContentDocumentToMoveVersionMap.put(lCdLink.ContentDocumentId, lContentLink.ContentDocumentId);
                    lContentDocumentLinkToDeleteMap.put(lCdLink.Id,lCdLink);
                }                
            }
        }

        
        List<ContentVersion> llContentVersionToCreateLst = new List<ContentVersion>();
        for(ContentVersion lContentVersion :[SELECT Id, Title, PathOnClient, ContentDocumentId, 
                Origin, SharingPrivacy, SharingOption, VersionData, Description FROM ContentVersion
                WHERE ContentDocumentId IN :lContentDocumentToMoveVersionMap.keySet()]) {
            llContentVersionToCreateLst.add(
                new ContentVersion(
                    Title = lContentVersion.Title, 
                    PathOnClient = lContentVersion.PathOnClient, 
                    ContentDocumentId = lContentDocumentToMoveVersionMap.get(lContentVersion.ContentDocumentId), 
                    Origin = lContentVersion.Origin, 
                    SharingPrivacy = lContentVersion.SharingPrivacy, 
                    SharingOption = lContentVersion.SharingOption, 
                    VersionData = lContentVersion.VersionData, 
                    Description = lContentVersion.Description
                )
            );			
        }

        insert llContentVersionToCreateLst;       
        
        delete lContentDocumentLinkToDeleteMap.values();
    }
    
    

    public static void changeOwnerContentDocument(List<ContentDocumentLink> aContentDocumentLinkLst) {

		Set<Id> lOrderIdSet = new Set<Id>();
		Map<Id,Id> lContentDocumentOrderMap = new Map<Id,Id>();
		for(ContentDocumentLink lContentLink :aContentDocumentLinkLst) {
			String lObjectName = lContentLink.LinkedEntityId.getSObjectType().getDescribe().getName();
		  	if (lObjectName == 'Order') {
                lOrderIdSet.add(lContentLink.LinkedEntityId);
                lContentDocumentOrderMap.put(lContentLink.ContentDocumentId,lContentLink.LinkedEntityId);
		  	}
        }
          
        if(lOrderIdSet.isEmpty()) return;

		Map<Id,Order> lOrderMap = new Map<Id,Order>([SELECT Id, Account.OwnerId, OrderNumber, ReasonForRefusal__c FROM Order WHERE Id IN :lOrderIdSet]);

        List<ContentVersion> lContentVersionToUpdateOwnerLst = new List<ContentVersion>();
        for(ContentVersion lContentVersion :[SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :lContentDocumentOrderMap.keySet()]) {
            Order lOrder = lOrderMap.get(lContentDocumentOrderMap.get(lContentVersion.ContentDocumentId));
            lContentVersionToUpdateOwnerLst.add(
                new ContentVersion(
                    Id = lContentVersion.Id,
                    OwnerId = lOrder.Account.OwnerId,
                    Title = 'NF_' + lOrder.OrderNumber,
                    ReasonForChange = (String.isNotBlank(lOrder.ReasonForRefusal__c)?('Corrigido: ' + lOrder.ReasonForRefusal__c):'')
                )
            );
        }

        update lContentVersionToUpdateOwnerLst;          
    }

    public static void validateSize(List<ContentDocumentLink> aContentDocumentLinkLst) {

		Map<Id,List<ContentDocumentLink>> lContentDocumentLinkMap = new Map<Id,List<ContentDocumentLink>>();
		for(ContentDocumentLink lContentLink :aContentDocumentLinkLst) {
			String lObjectName = lContentLink.LinkedEntityId.getSObjectType().getDescribe().getName();
		  	if (lObjectName == 'Order') {
                List<ContentDocumentLink> lContentDocumentLinkLst = lContentDocumentLinkMap.get(lContentLink.ContentDocumentId);
                if(lContentDocumentLinkLst == null) {
                    lContentDocumentLinkLst = new List<ContentDocumentLink>();
                    lContentDocumentLinkMap.put(lContentLink.ContentDocumentId,lContentDocumentLinkLst);
                }
                lContentDocumentLinkLst.add(lContentLink);
		  	}
        }
          
        if(lContentDocumentLinkMap.isEmpty()) return;

        List<Object> lParameters = new List<Object> {Label.MaxSizePaymentOrderInvoice};
        String lTextErrorMaxSizePaymentOrderInvoice = String.format(Label.TextErrorMaxSizePaymentOrderInvoice, lParameters);
        List<ContentVersion> lContentVersionToUpdateOwnerLst = new List<ContentVersion>();
        for(ContentDocument lContentDoc :[SELECT Id, ContentSize FROM ContentDocument WHERE Id IN :lContentDocumentLinkMap.keySet()]) {
            if(lContentDoc.ContentSize > (1048576*Decimal.valueOf(Label.MaxSizePaymentOrderInvoice))) {
                for(ContentDocumentLink lContentLink :lContentDocumentLinkMap.get(lContentDoc.Id)) {                    
                    lContentLink.addError(lTextErrorMaxSizePaymentOrderInvoice);
                }
            }

        }       
    }
    
    
}