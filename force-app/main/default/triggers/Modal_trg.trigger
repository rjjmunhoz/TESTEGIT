trigger Modal_trg on Modal__c(before update, after insert, after update) {
    if (!TriggerCheck.isActive('Modal__c')) return;

    if (trigger.isBefore) {
        if (trigger.isUpdate) {
                //ModalHandler.checksModalActivation(trigger.newMap);
        }
    }

    if(trigger.isAfter){
        if (trigger.isUpdate) {
            ModalHandler.legacyIntegration(trigger.newMap);
        }
        if(trigger.isInsert){
            ModalHandler.legacyIntegration(trigger.newMap);
        }
    }
}