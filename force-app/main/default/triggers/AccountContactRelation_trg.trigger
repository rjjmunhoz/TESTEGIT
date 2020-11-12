trigger AccountContactRelation_trg on AccountContactRelation (before insert, before delete) {

    if (!TriggerCheck.isActive('AccountContactRelation')) return;

    if (trigger.isBefore) {
        if (trigger.isInsert) {
            AccountContactRelationHandler.predefinedValues(trigger.new);    
        }
        if (trigger.isDelete) {
            AccountContactRelationHandler.blockExclusion(trigger.old);    
        }
    }
    
}