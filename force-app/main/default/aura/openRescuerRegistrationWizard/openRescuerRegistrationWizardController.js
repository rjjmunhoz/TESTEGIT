({
    invoke : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
            "isredirect": true,
            "url": "/lightning/cmp/c__RescuerRegistrationWizard?c__cpf=" + component.get("v.cpf") + '&retURL=%2F003'
         });
         urlEvent.fire();
    }
})