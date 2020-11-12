/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de OperationalService
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-08      Mariana Ribeiro         class created 
**************************************************************************************************************/
public with sharing class OperationalServiceHandler_cls {
    public static void ValidateJunctionOperationalService(List<OperationalService__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lSpecialtySet = new Set<Id>();
        Set<Id> lOperationalServiceSet = new Set<Id>();
        for(OperationalService__c lOperationalService :aNewLst){
            lSpecialtySet.add(lOperationalService.Specialty__c);
            lOperationalServiceSet.add(lOperationalService.OperationalService__c);
        }

        Set<String> lRecordsSet = new Set<String>();
        for(OperationalService__c lOperationalService :[SELECT Specialty__c, OperationalService__c FROM OperationalService__c WHERE Specialty__c IN :lSpecialtySet AND OperationalService__c IN :lOperationalServiceSet]){
           lRecordsSet.add(lOperationalService.Specialty__c +''+lOperationalService.OperationalService__c);
        }
        //system.debug('lRecordsSet ' + lRecordsSet);
        if(lRecordsSet.isEmpty()) return;

        for(OperationalService__c lOperationalService :aNewLst){
            if(lRecordsSet.contains(lOperationalService.Specialty__c +''+lOperationalService.OperationalService__c)){
                lOperationalService.addError(Label.OperationalServiceErro_VinculoDuplicado);
            }
        }
    }
}