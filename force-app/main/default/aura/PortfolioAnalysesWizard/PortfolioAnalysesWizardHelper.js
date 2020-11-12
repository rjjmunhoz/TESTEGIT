({
    doinit: function (component, event, helper) {
        var thisRecord = component.get("v.caseRecord");
        console.log('Id do registro: ',component.get("v.recordId"));
        console.log('Satus do registro: ', thisRecord.Status);
        component.set("v.showSpinner", true);

        var action = component.get('c.searchParameters');
        action.setParams({
            'aStatus': thisRecord.Status,
            'aRecordType': thisRecord.RecordType.DeveloperName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var result = response.getReturnValue();
                console.log('Result: ', result);
                component.set("v.portfolioFields", result.lFields);
                component.set("v.helpMessage", result.lHelpText);

                console.log('helpMessage: ', component.get("v.helpMessage"));
                console.log('fieldsToShow: ', component.get("v.portfolioFields"));
                console.log('RecordType.DeveloperName', component.get("v.caseRecord.RecordType.DeveloperName"));
            }
            else {
                console.log("Failed with state: " + state);
            } 
        });

        $A.enqueueAction(action);
        component.set("v.showSpinner", false);
    },
    doSubmit: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})