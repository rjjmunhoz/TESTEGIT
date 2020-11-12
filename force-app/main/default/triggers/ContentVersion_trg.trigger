trigger ContentVersion_trg on ContentVersion (after update) {

	if(trigger.isAfter){
		if(trigger.isUpdate){
			ContentDocumentHandler_cls.versionControlContentVersion(trigger.new);
		}
	}
}