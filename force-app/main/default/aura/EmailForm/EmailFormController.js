({
    cancel: function (component, event, helper) {
        helper.doCancel(component, event, helper);
    }, 
    addEmailIntoList: function (component, event, helper){
        helper.doEmailIntoList(component, event, helper);
    },
    onSendEmail: function (component, event, helper) {
        helper.doEmailIntoList(component, event, helper);
        var emailList = [];
        var emailList = component.get("v.emailList");
        console.log('emailList ------->', emailList);

        if (emailList.length < 1) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Atenção",
                "message": "Por favor, insira ao menos um endereço de email.",
                "duration": ' 5000',
                "type": 'warning',
            });
            toastEvent.fire();
        }
        else {
            helper.sendEmail(component, event, helper);
        }
    }
})