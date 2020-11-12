({
    onChangeRole : function(component, event, helper) {
        component.set("v.contact", component.get("v.contact"));
    },
    onChangeField : function(component, event, helper) {
        // Comando somente para atualizar o contato no objeto PAI
        component.set("v.contact", component.get("v.contact"));
    },
    validateFields : function(component, event, helper) {
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (!allValid) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "Por favor preencher os campos obrigatórios!",
                "type": "info"
            });
            toastEvent.fire();
        }
        return allValid;
    },
    onSetAccountId : function (component, event, helper) {  
        component.set("v.showRecordForm",false);
        component.set("v.loading",true);
        var eventFields = event.getParam("fields");        
        var contact = component.get("v.contact");
        contact.AccountId = eventFields.AccountId.value;
        component.set("v.contact",contact);
        component.set("v.loading",false);
        component.set("v.showRecordForm",true);
    },
    onMandatoryField : function (component, event, helper) {  
        var contact = component.get("v.contact");
        switch(contact.Role__c) {
        case 'Administrativo':
        case 'Ajudante':
        case 'Aprendiz':
        case 'Gestor':
            component.set("v.requiredFields",false);
            break;
        case 'Gestor Operacional':
        case 'Socorrista':
            component.set("v.requiredFields",true);
            break;
        default:
            component.set("v.requiredFields",false);
        }
    },
})