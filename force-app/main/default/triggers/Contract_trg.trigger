trigger Contract_trg on Contract (before insert) {
	
    if (!TriggerCheck.isActive('Contract')) return;

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ContractHandler_cls.CheckDuplicatesContracts(Trigger.new);
            ContractHandler_cls.AutoFillContractFields(Trigger.new);
    	}
    }
}