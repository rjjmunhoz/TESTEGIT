({
    redirectToRecord: function (component, event, helper) {
        var parentValue = component.get("v.parentId");
        // var navEvt = $A.get("e.force:navigateToSObject");
        // navEvt.setParams({
        //     "recordId": parentValue,
        //     "slideDevName": "detail"
        // });
        // navEvt.fire();

        window.location.href = '/' + parentValue;

    },
    sucessToast: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Sucesso",
            "message": "Registros vinculados com sucesso!",
            "duration": ' 5000',
            "type": 'success',
        });
        toastEvent.fire();
    }
})