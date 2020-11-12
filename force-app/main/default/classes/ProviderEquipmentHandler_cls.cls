/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService dos usuários do Portal
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-09-03      Mariana Ribeiro         class created 
**************************************************************************************************************/
public class ProviderEquipmentHandler_cls {

    public static void newProviderEquipament(List<ProviderEquipment__c> aNewLst){
        TriggerCheck.assert();

        Set<Id> lProviderIdSet = new Set<Id>();
        for(ProviderEquipment__c lProvider :aNewLst){
            lProviderIdSet.add(lProvider.Provider__c);
        }
        // System.debug('Set de prestadores para integrar ------------------> ' + lProviderIdSet);
        if(lProviderIdSet.isEmpty()) return;
        SpecialtyWrapper_cls lSObjectToIntegrateLst = ProviderEquipamentWebService_cls.newProviderEquipament(lProviderIdSet);
        
        if(lSObjectToIntegrateLst != null){
            System.enqueueJob(new IntegrationHandler_cls(lSObjectToIntegrateLst));
        }
    }

    public static void validateJunctionEquipamentProvider(List<ProviderEquipment__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lProviderSet = new Set<Id>();
        Set<Id> lEquipmentSet = new Set<Id>();
        for(ProviderEquipment__c lEquipamentProvider :aNewLst){
            lProviderSet.add(lEquipamentProvider.Provider__c);
            lEquipmentSet.add(lEquipamentProvider.Equipment__c);
        }

        Set<String> lRecordsSet = new Set<String>();
        for(ProviderEquipment__c lEquipamentProvider:[SELECT Provider__c, Equipment__c FROM ProviderEquipment__c WHERE Provider__c =: lProviderSet AND Equipment__c =: lEquipmentSet]){
           lRecordsSet.add(lEquipamentProvider.Equipment__c +''+lEquipamentProvider.Provider__c);
        }
        system.debug('lRecordsSet ' + lRecordsSet);
        if(lRecordsSet.isEmpty()) return;

        for(ProviderEquipment__c lEquipamentProvider :aNewLst){
            if(lRecordsSet.contains(lEquipamentProvider.Equipment__c +''+lEquipamentProvider.Provider__c)){
                lEquipamentProvider.addError(Label.MessageError_JunctionProviderEquipment);
            }
        }
    }
}