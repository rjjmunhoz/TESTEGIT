trigger DiscountType_trg on DiscountType__c (before insert, before update) {

    if (!TriggerCheck.isActive('DiscountType__c')) return;

    if(Trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            DiscountTypeHandler.duplicateRuleDiscountType(Trigger.new);
        }
	}
}