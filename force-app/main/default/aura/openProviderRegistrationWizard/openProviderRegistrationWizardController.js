({
    invoke : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
            "isredirect": true,
            "url": "/lightning/cmp/c__ProviderRegistrationWizard?c__loadByUrl=true&c__cnpj=" + component.get("v.cnpj") +'&c__personType='+ component.get("v.personType") +'&retURL=%2F001'
         });
         urlEvent.fire();
    }
})