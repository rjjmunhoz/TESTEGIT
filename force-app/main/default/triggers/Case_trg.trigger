trigger Case_trg on Case (before insert, before update, after insert, after update) {
    if (!TriggerCheck.isActive('Case')) return;
     
    if(Trigger.isBefore){
	    if(Trigger.isUpdate){
            
            CaseHandler.requiresRequirements(Trigger.newMap);
           	CaseHandler.waitForOperationalAnalysis(Trigger.newMap);
            CaseHandler.verifyAttachment(Trigger.newMap);
            CaseHandler.checkResults(Trigger.newMap);
            CaseHandler.waitForDeployment(Trigger.newMap);
		}
        if(Trigger.isInsert){
             CaseHandler.duplicateRuleCase(Trigger.new);
        }
	}
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            CaseHandler.changeCaseStatus(Trigger.new);
            CaseHandler.activateService(Trigger.new);
            CreateChildrenCaseHandler.startOperationalAnalysisAndDeployment(Trigger.new);
            CreateChildrenCaseHandler.activateSelectedAreas(Trigger.new);
            CaseHandler.valueFieldChildCase(Trigger.new,Trigger.oldMap);
		}
        if(Trigger.isInsert){
            // CaseHandler.valueFieldAssigmentsChildCase(Trigger.new);
            CaseHandler.AutoResponseRulesUsingRESTAPI(Trigger.new);            
        }            
    }
}