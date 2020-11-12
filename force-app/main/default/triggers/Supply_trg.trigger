trigger Supply_trg on Supply__c (before insert, before update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            SupplyHandler_cls.ValidateJunctionSupply(Trigger.new);
        }
	    if(Trigger.isUpdate){
            SupplyHandler_cls.ValidateJunctionSupply(Trigger.new);
		}
	}
}