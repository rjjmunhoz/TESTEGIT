({
    doInit: function (component, event, helper) {
        console.log("###doInit");
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        var recordTypeIdRescuer = $A.get("{!$Label.c.RecordTypeIdRescuer}");

        if (recordTypeIdRescuer != recordTypeId) {
            component.set("v.goRescuerRegistrationWizard", false);
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/003",
                isredirect: true
            });
            urlEvent.fire();     
            urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url" : "/003/e?RecordType="+recordTypeId+"&nooverride=1",
                isredirect: true
            });
            urlEvent.fire();           
        }
        else {            
            component.set("v.goRescuerRegistrationWizard", true);
        }
    },
    redirect: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/003"
        });
        urlEvent.fire();        
    },
})