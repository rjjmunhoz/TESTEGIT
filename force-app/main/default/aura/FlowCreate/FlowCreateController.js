({
    init: function (component) {
        var myPageRef = component.get("v.pageReference");
        var flowName = myPageRef.state.c__flowName;
        console.log(flowName);
        component.set("v.flowName", flowName);

        var flowData = component.find("flowData");
        flowData.startFlow(component.get("v.flowName"));
    },
    closeModal: function (component) {
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        if (recordId != null) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "slideDevName": "detail"
            });
            navEvt.fire();
        } else {
            /*
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewName": null,
                "scope": "Case"
            });
            navEvent.fire();*/
            window.location.href = '/500';
        }
    }
})