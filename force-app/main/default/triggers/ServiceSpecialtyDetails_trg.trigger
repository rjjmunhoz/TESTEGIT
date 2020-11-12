trigger ServiceSpecialtyDetails_trg on ServiceSpecialtyDetails__c(after insert, after delete,after update, before insert, before update) {

    if (!TriggerCheck.isActive('ServiceSpecialtyDetails__c')) return;

    if (Trigger.isAfter) {
        if(Trigger.isInsert){
            ServiceSpecialtyDetailsHandler_cls.legacyIntegration(trigger.new);
        }
        else if(Trigger.isUpdate){
            ServiceSpecialtyDetailsHandler_cls.legacyIntegration(trigger.new);
        }
        else if (Trigger.isDelete) {
            ServiceSpecialtyDetailsHandler_cls.legacyIntegration(trigger.old);
        }
    }

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ServiceSpecialtyDetailsHandler_cls.ValidateJunctionServiceSpecialtyDetails(Trigger.new);
        }
	    if(Trigger.isUpdate){
            ServiceSpecialtyDetailsHandler_cls.junctionReasonSpecialtyMessage(trigger.newMap);
            //ServiceSpecialtyDetailsHandler_cls.ValidateJunctionServiceSpecialtyDetails(Trigger.new);
		}
    }
}