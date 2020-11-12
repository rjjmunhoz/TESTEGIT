trigger EquipmentSupplyPart_trg on EquipmentSupplyPart__c (after insert, after update, before insert, before update) {
    if (!TriggerCheck.isActive('EquipmentSupplyPart__c')) return;
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            EquipmentSupplyPartHandler_cls.duplicityControl(Trigger.new);
        }
        if(Trigger.isUpdate){
            //EquipmentSupplyPartHandler_cls.duplicityControl(Trigger.new);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            EquipmentSupplyPartHandler_cls.newProviderAbility(Trigger.new);
        }
        if(Trigger.isUpdate){
            EquipmentSupplyPartHandler_cls.newProviderAbility(Trigger.new);
        }
    }
}