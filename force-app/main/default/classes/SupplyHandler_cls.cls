/**************************************************************************************************************
* Globant Brasil
* @author        	Misael RIbas (misael.ribas@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de Supply
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-08      Misael RIbas            class created 
*            1.1    2020-07-21      Matheus Branco          remove method ValidateJunctionSupply
**************************************************************************************************************/
public with sharing class SupplyHandler_cls {
    public static void ValidateJunctionSupply(List<Supply__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lModalSet = new Set<Id>();
        Set<Id> lSupplySet = new Set<Id>();
        for(Supply__c lSupply :aNewLst){
            lModalSet.add(lSupply.Modal__c);
            lSupplySet.add(lSupply.OperationalSetup__c);
        }

        Set<String> lRecordsSet = new Set<String>();
        for(Supply__c lSupply :[SELECT OperationalSetup__c, Modal__c FROM Supply__c WHERE Modal__c IN :lModalSet AND OperationalSetup__c IN :lSupplySet]){
           lRecordsSet.add(lSupply.OperationalSetup__c +''+lSupply.Modal__c);
        }
        system.debug('lRecordsSet ' + lRecordsSet);
        if(lRecordsSet.isEmpty()) return;

        for(Supply__c lSupply :aNewLst){
            if(lRecordsSet.contains(lSupply.OperationalSetup__c +''+lSupply.Modal__c)){
                lSupply.addError(Label.ErrorSupplyModalLinked);
            }
        }
    }
}