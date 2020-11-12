/**************************************************************************************************************
* Globant Brasil
* @author        	Misael RIbas (misael.ribas@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de Equipment
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-08      Misael RIbas            class created 
*            1.1    2020-07-21      Matheus Branco          remove method
**************************************************************************************************************/
public class EquipmentHandler_cls {
    public static void ValidateJunctionModal(List<Equipment__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lModalSet = new Set<Id>();
        Set<Id> lEquipmentSet = new Set<Id>();
        for(Equipment__c lEquipment :aNewLst){
            lModalSet.add(lEquipment.Modal__c);
            lEquipmentSet.add(lEquipment.OperationalSetup__c);
        }

        Set<String> lRecordsSet = new Set<String>();
        for(Equipment__c lEquipment :[SELECT OperationalSetup__c, Modal__c FROM Equipment__c WHERE Modal__c =: lModalSet AND OperationalSetup__c =: lEquipmentSet]){
           lRecordsSet.add(lEquipment.OperationalSetup__c +''+lEquipment.Modal__c);
        }
        system.debug('lRecordsSet ' + lRecordsSet);
        if(lRecordsSet.isEmpty()) return;

        for(Equipment__c lEquipment :aNewLst){
            if(lRecordsSet.contains(lEquipment.OperationalSetup__c +''+lEquipment.Modal__c)){
                lEquipment.addError(Label.MessageError_JunctionEquipmentModal);
            }
        }
    }
}