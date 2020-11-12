trigger Event_trg on Event (before insert, before update, after insert, after update) {
	//if (!TriggerCheck.isActive('Event')) return;
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            EventHandler.countQRAsQuantity(trigger.newMap);
    	}
        if(trigger.isUpdate){
            EventHandler.countQRAsQuantity(trigger.newMap);
        }
        
    }
}