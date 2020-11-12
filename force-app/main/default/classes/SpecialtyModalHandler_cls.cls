/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Classe manipuladora da trigger do objeto Modal da especialidade
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-05-29      Matheus Branco           class created 
*            1.1    2020-07-21      Matheus Branco           remove method ValidateJunctionSpecialtyModal
**************************************************************************************************************/

public with sharing class SpecialtyModalHandler_cls {
    public static void ValidateJunctionSpecialtyModal(List<SpecialtyModal__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lModalSet = new Set<Id>();
        Set<Id> lSpecialtySet = new Set<Id>();
        for(SpecialtyModal__c lSpecialtyModal :aNewLst){
            lModalSet.add(lSpecialtyModal.Modal__c);
            lSpecialtySet.add(lSpecialtyModal.Product2__c);
        }

        Set<String> lRecordsSet = new Set<String>();
        for(SpecialtyModal__c lSpecialtyModal :[SELECT Modal__c, Product2__c FROM SpecialtyModal__c WHERE Modal__c IN :lModalSet AND Product2__c IN :lSpecialtySet]){
            lRecordsSet.add(lSpecialtyModal.Modal__c +''+lSpecialtyModal.Product2__c);
        }
        system.debug('lRecordsSet ' + lRecordsSet);
        if(!lRecordsSet.isEmpty()){
            for(SpecialtyModal__c lSpecialtyModal :aNewLst){
                if(lRecordsSet.contains(lSpecialtyModal.Modal__c +''+lSpecialtyModal.Product2__c)){
                    lSpecialtyModal.addError(Label.ErrorSpecialtyLinkedModal);
                }
            }
        }
    }

    public static void synchronizeVehicle(List<SpecialtyModal__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lModalIdSet = new Set<Id>();
        for(SpecialtyModal__c lSpecModal :aNewLst){
            if(TriggerCheck.isChanged(lSpecModal, SpecialtyModal__c.Modal__c) || 
                    TriggerCheck.isChanged(lSpecModal, SpecialtyModal__c.Product2__c) || 
                    TriggerCheck.isChanged(lSpecModal, SpecialtyModal__c.IsActive__c )) {
                if(lSpecModal.Modal__c != null) {
                    lModalIdSet.add(lSpecModal.Modal__c);
                }  
                if(trigger.isUpdate) {
                    lModalIdSet.add(((SpecialtyModal__c)trigger.oldMap.get(lSpecModal.id)).Modal__c);
                }            
            }            
        }
        if(lModalIdSet.isEmpty()) return;       
        
        Map<Id,Vehicle__c> lVehicleMap = new Map<Id,Vehicle__c>([SELECT Id FROM Vehicle__c WHERE TypeModal__c IN :lModalIdSet]);

        VehicleWebService_cls.setVehicleToSynchronize(lVehicleMap.keySet());
    }
}