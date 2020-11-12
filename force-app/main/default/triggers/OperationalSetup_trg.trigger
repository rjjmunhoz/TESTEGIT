trigger OperationalSetup_trg on OperationalSetup__c (before update, before insert, after insert, after update) {
    if (!TriggerCheck.isActive('OperationalSetup__c')) return;

    if(trigger.isBefore){
        if(trigger.isInsert){
            OperationalSetupHandler.generateExternalId(trigger.new);
        }
        if(trigger.isUpdate){
            OperationalSetupHandler.checkGMVEquipmentSupplyActivation(trigger.newMap);
        }
    }
    if(trigger.isAfter){
        if(trigger.isInsert){
            OperationalSetupHandler.legacyIntegration(trigger.newMap);
            OperationalSetupHandler.validateExternalId(trigger.new);
        }
        if(trigger.isUpdate){
            OperationalSetupHandler.legacyIntegration(trigger.newMap);
            OperationalSetupHandler.providerAbilityUpdate(trigger.new);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            OperationalSetupHandler.synchronizeRescuer(Trigger.new);
            OperationalSetupHandler.vehicleEquipmentUpdate(Trigger.new);
            OperationalSetupHandler.providerEquipmentUpdate(Trigger.new);
        }
	}
}