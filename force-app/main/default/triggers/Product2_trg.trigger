trigger Product2_trg on Product2(before update, before insert, after insert, after update) {
    if (!TriggerCheck.isActive('Product2')) return;

    if (trigger.isBefore) {
        if (trigger.isUpdate) {
            //Product2Handler.checkServiceActivation(trigger.newMap);
            //Product2Handler.duplicateControl(trigger.new);
        }
        if(trigger.isInsert){
            //Product2Handler.duplicateControl(trigger.new);
            Product2Handler.generateExternalId(trigger.new);
        }
    }

    if(trigger.isAfter){
        if (trigger.isUpdate) {
            //Product2Handler.checkServiceActivation(trigger.newMap);
            Product2Handler.legacyIntegration(trigger.newMap);
            Product2Handler.synchronizeRescuerVehicle(Trigger.new);
            Product2Handler.providerAbilityUpdate(Trigger.new);
        }
        if(trigger.isInsert){
            Product2Handler.legacyIntegration(trigger.newMap);
            Product2Handler.validateExternalId(trigger.new);
            Product2Handler.synchronizeRescuerVehicle(Trigger.new);
        }
    }
}