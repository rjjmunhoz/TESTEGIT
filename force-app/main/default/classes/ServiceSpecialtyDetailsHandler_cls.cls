/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Classe manipuladora da trigger do objeto Item de Serviço/Especialidade/Motivo
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-02-11      Eduardo Costa           class created 
* @version   2.0    2020-04-09      Mariana Ribeiro         creation of the ValidateJunctionServiceSpecialtyDetails method
* @version   2.1    2020-05-27      Jean Sganzerla          providerSpecialtyUpdate implementation 
* @version   2.2    2020-05-28      Matheus Branco          update method legacyIntegration
* @version   2.3    2020-06-15      Jean Sganzerla          providerSpecialtyUpdate removed
**************************************************************************************************************/
public with sharing class ServiceSpecialtyDetailsHandler_cls {

    private static final String ACTIVE = Label.Status_Active;
    private static final String IN_DEPLOYMENT = Label.Status_Deployment;
    private static final String PROVIDER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProviderRecordType).getRecordTypeId();

    public static void legacyIntegration(List<ServiceSpecialtyDetails__c> aServiceSpecialtyDetailsLst) {

        Set<Id> lServiceSpecialtyDetailsToIntegrateSet = new Set<Id>();
        for(ServiceSpecialtyDetails__c lServSpecDet: aServiceSpecialtyDetailsLst){
            system.debug('lServSpecDet :' + JSON.serialize(lServSpecDet));
            if(String.isNotBlank(lServSpecDet.SpecialtyStatus__c) && 
                    !lServSpecDet.SpecialtyStatus__c.equals(IN_DEPLOYMENT) && 
                    String.isNotBlank(lServSpecDet.ReasonStatus__c) && 
                    !lServSpecDet.ReasonStatus__c.equals(IN_DEPLOYMENT) || 
                    TriggerCheck.isChanged(lServSpecDet, ServiceSpecialtyDetails__c.IsActive__c)){
                lServiceSpecialtyDetailsToIntegrateSet.add(lServSpecDet.SpecialtyDetail__c);              
            }
        }

        if(lServiceSpecialtyDetailsToIntegrateSet.isEmpty()) return;

        List<Product2> lServiceSpecialtyDetailsToIntegrateLst = SpecialtyWebService.getSpecialtyWithFieldsToIntegrate(lServiceSpecialtyDetailsToIntegrateSet);
        system.debug('ServSpecDet :' + JSON.serialize(lServiceSpecialtyDetailsToIntegrateLst));      
        if(lServiceSpecialtyDetailsToIntegrateLst.isEmpty()) return;

        System.enqueueJob(new IntegrationHandler_cls(lServiceSpecialtyDetailsToIntegrateLst));
    }

    public static void ValidateJunctionServiceSpecialtyDetails(List<ServiceSpecialtyDetails__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lDetailSet = new Set<Id>();
        Set<Id> lServiceSet = new Set<Id>();
        Set<Id> lSpecialtyServiceSet = new Set<Id>();
        Set<Id> lSpecialtyDetailSet = new Set<Id>();
        for(ServiceSpecialtyDetails__c lServiceSpecialtyDetail :aNewLst){
            lDetailSet.add(lServiceSpecialtyDetail.Detail__c);
            lServiceSet.add(lServiceSpecialtyDetail.Service__c);
            lSpecialtyServiceSet.add(lServiceSpecialtyDetail.Specialty__c);
            lSpecialtyDetailSet.add(lServiceSpecialtyDetail.SpecialtyDetail__c);
        }

        Set<String> lRecordsServiceSet = new Set<String>();
        Set<String> lRecordsDetailSet = new Set<String>();
        for(ServiceSpecialtyDetails__c lServiceSpecialtyDetail :[SELECT Specialty__c, Detail__c, Service__c, SpecialtyDetail__c  FROM ServiceSpecialtyDetails__c WHERE (Specialty__c IN :lSpecialtyServiceSet AND Service__c IN :lServiceSet) OR (Detail__c IN :lDetailSet AND SpecialtyDetail__c IN :lSpecialtyDetailSet)]){
            if(lServiceSpecialtyDetail.Specialty__c != null){
                lRecordsServiceSet.add(lServiceSpecialtyDetail.Specialty__c +''+lServiceSpecialtyDetail.Service__c);
            }
            if(lServiceSpecialtyDetail.SpecialtyDetail__c != null){
                lRecordsDetailSet.add(lServiceSpecialtyDetail.SpecialtyDetail__c +''+lServiceSpecialtyDetail.Detail__c);
            }

        }
        system.debug('lRecordsSet ' + lRecordsServiceSet);
        if(!lRecordsServiceSet.isEmpty()){
            for(ServiceSpecialtyDetails__c lServiceSpecialtyDetail :aNewLst){
                if(lRecordsServiceSet.contains(lServiceSpecialtyDetail.Specialty__c +''+lServiceSpecialtyDetail.Service__c)){
                    lServiceSpecialtyDetail.addError(Label.ErrorServiceSpecialtyLinked);
                }
            }
        }

        if(!lRecordsDetailSet.isEmpty()){
            for(ServiceSpecialtyDetails__c lServiceSpecialtyDetail :aNewLst){
                if(lRecordsDetailSet.contains(lServiceSpecialtyDetail.SpecialtyDetail__c +''+lServiceSpecialtyDetail.Detail__c)){
                    lServiceSpecialtyDetail.addError(Label.ErrorDetailSpecialtyLinked);
                }
            }
        }        
    }
    public static void junctionReasonSpecialtyMessage(Map<Id,ServiceSpecialtyDetails__c> aNewMap){
        TriggerCheck.assert();

        Set<Id> lSpecialtySet = new Set<Id>();
        for(ServiceSpecialtyDetails__c lServiceSpecialtyDetail : aNewMap.values()){
            system.debug('lServiceSpecialtyDetail.SpecialtyDetail__c '+ lServiceSpecialtyDetail.SpecialtyDetail__c);
            if(TriggerCheck.isChangedTo(lServiceSpecialtyDetail, ServiceSpecialtyDetails__c.IsActive__c,false) && lServiceSpecialtyDetail.SpecialtyStatus__c == ACTIVE){
                lSpecialtySet.add(lServiceSpecialtyDetail.SpecialtyDetail__c);
            }
        }
        if(lSpecialtySet.isEmpty()) return;

        Map<Id,List<ServiceSpecialtyDetails__c>> lJunctionMap = new Map<Id,List<ServiceSpecialtyDetails__c>>();
        for(ServiceSpecialtyDetails__c lJunction :[SELECT SpecialtyDetail__c, Detail__c FROM ServiceSpecialtyDetails__c WHERE SpecialtyDetail__c IN :lSpecialtySet AND IsActive__c = true AND Detail__r.Status__c = :ACTIVE]){
            List<ServiceSpecialtyDetails__c> lJunctionLst = lJunctionMap.get(lJunction.SpecialtyDetail__c);
            if(lJunctionLst == null){
                lJunctionLst = new List<ServiceSpecialtyDetails__c>();
                lJunctionMap.put(lJunction.SpecialtyDetail__c, lJunctionLst);
            }
            lJunctionLst.add(lJunction);
        }

        for(ServiceSpecialtyDetails__c lServiceSpecialtyDetail : aNewMap.values()){
            if(lJunctionMap.get(lServiceSpecialtyDetail.SpecialtyDetail__c).size() < 2){
                aNewMap.get(lServiceSpecialtyDetail.Id).addError(Label.ErrorDetailSingleSpecialtyLinked); 
            }
        }    
    }
}