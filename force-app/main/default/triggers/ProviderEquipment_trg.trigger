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
trigger ProviderEquipment_trg on ProviderEquipment__c (after insert, after update, after delete, before insert) {
    if (!TriggerCheck.isActive('ProviderEquipment__c')) return;

    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            ProviderEquipmentHandler_cls.newProviderEquipament(Trigger.new);
        }
    }

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ProviderEquipmentHandler_cls.validateJunctionEquipamentProvider(trigger.new);
        }
    }
}