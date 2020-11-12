trigger ContractInstallment_trg on ContractInstallment__c (before insert) {

    if (!TriggerCheck.isActive('ContractInstallment__c')) return;

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ContractInstallmentHandler_cls.contractRelationshipCreation(Trigger.new);
            ContractInstallmentHandler_cls.contractInstallmentMonthValidation(Trigger.new);
            
    	}
    }
}