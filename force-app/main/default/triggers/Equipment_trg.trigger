trigger Equipment_trg on Equipment__c (before insert, before update) {
	if(Trigger.isBefore){
        if(Trigger.isInsert){
            EquipmentHandler_cls.ValidateJunctionModal(Trigger.new);
        }
	    if(Trigger.isUpdate){
            EquipmentHandler_cls.ValidateJunctionModal(Trigger.new);
		}
	}
}