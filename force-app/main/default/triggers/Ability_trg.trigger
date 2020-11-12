trigger Ability_trg on Ability__c (before insert, before update, after insert, after update) {
	if(Trigger.isBefore){
        if(Trigger.isInsert){
            AbilityHandler_cls.ValidateJunctionAbility(Trigger.new);
            //AbilityHandler_cls.ValidateJunctionAbilityRescuer(Trigger.new);
        }
	    if(Trigger.isUpdate){
            //AbilityHandler_cls.ValidateJunctionAbility(Trigger.new);
		}
	}
	if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            AbilityHandler_cls.synchronizeRescuer(Trigger.new);
            AbilityHandler_cls.providerReasonUpdate(Trigger.new);
        }
	}
}