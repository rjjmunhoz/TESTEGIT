trigger ContentDocumentLink_trg on ContentDocumentLink (after insert, before insert) {
    
	if(trigger.isAfter){
		if(trigger.isInsert){
			// Include version in updated invoice
			ContentDocumentHandler_cls.versionControlContentDocumentLink(trigger.new);
			// change owner ContentDocument to same Account owner
			ContentDocumentHandler_cls.changeOwnerContentDocument(trigger.new);			
		}
	}
	if(trigger.isBefore){
		if(trigger.isInsert){
			// Validade size invoice Payment Order
			ContentDocumentHandler_cls.validateSize(trigger.new);		
		}
	}
}