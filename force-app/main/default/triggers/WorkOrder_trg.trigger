trigger WorkOrder_trg on WorkOrder (before insert, before update) {
    if(!TriggerCheck.isActive('WorkOrder')) return;

    if(trigger.isBefore){
        if(trigger.isInsert){
            WorkOrderHandler_cls.insertWorkOrderWithRelationship(trigger.new);
        }
    }
}