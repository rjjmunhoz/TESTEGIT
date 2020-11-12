trigger OperationalService_trg on OperationalService__c (before insert, before update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            OperationalServiceHandler_cls.ValidateJunctionOperationalService(Trigger.new);
        }
	    if(Trigger.isUpdate){
            OperationalServiceHandler_cls.ValidateJunctionOperationalService(Trigger.new);
		}
	}
}