({
    sendEmail: function (component, event, helper) {
        var caseId = component.get('v.recordId');
        var emailLst = component.get('v.emailList');
        var attach = component.get('v.attach');
        var emailBody = component.get('v.emailBody');
        var emailSubject = component.get('v.emailSubject');
        
        var action = component.get('c.sendEmailFunction');
        action.setParams({
            'aSendAttach': attach,
            'aCaseId': caseId,
            'aBoddy' : emailBody,
            'aSubject': emailSubject,
            'aEmailDest' : emailLst           
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('State-->' + state);
            if (state == "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Email enviado com sucesso!",
                    "type": "success"
                });
                toastEvent.fire();
                helper.doCancel(component, event, helper);
            } else {
                toastEvent.setParams({
                    "type": 'error',
                    "message": "Não foi possível enviar o email.",
                    "mode": "sticky"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    doCancel: function (component, event, helper) {
        component.set('v.emailList', []);
        component.find('email').set('v.value', '');
        component.set('v.attach', false);
        component.set('v.emailBody', '');
        component.set('v.emailSubject', '');
    }, 
    doEmailIntoList: function (component, event, helper) {

        var value = component.find('email').get('v.value');
        var validity = component.find("email").get("v.validity");
        console.log('validade ---> ', validity.valid); //returns true
        if (validity.valid == false) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Erro  ",
                "message": "Por favor, insira um endereço de email válido.",
                "duration": ' 5000',
                "type": 'error',
            });
            toastEvent.fire();
        }
        else {
            var emailList = [];
            emailList = component.get("v.emailList");
            var toList = component.find('email').get('v.value');
            if (toList != null && toList != '') {
                emailList.push(toList);
            }
            component.set("v.emailList", emailList);
            console.log("Lista de emails ---> ", JSON.stringify(component.get("v.emailList")));
            component.find('email').set('v.value', '');
            // $A.get('e.force:refreshView').fire();
        }
    }
})