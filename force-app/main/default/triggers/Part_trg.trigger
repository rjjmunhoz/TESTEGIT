trigger Part_trg on Part__c (before insert, before update) {
	if(Trigger.isBefore){
        if(Trigger.isInsert){
            PartHandler_cls.ValidateJunctionPart(Trigger.new);
        }
	    if(Trigger.isUpdate){
            PartHandler_cls.ValidateJunctionPart(Trigger.new);
		}
	}
}