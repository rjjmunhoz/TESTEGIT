({
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
    onHealthInsuranceChange : function(component, event, helper) {
        var checkCmp = component.find("healthInsuranceField").get("v.checked");
        component.set("v.contact.HealthInsurance__c",checkCmp);
    },
    onDentalChange : function(component, event, helper) {
        var checkCmp = component.find("dentalField").get("v.checked");
        component.set("v.contact.Dental__c",checkCmp);
    },
    onMandatoryField : function (component, event, helper) {  
        var contact = component.get("v.contact");
        switch(contact.Role__c) {
        case 'Administrativo':
        case 'Gestor':
            component.set("v.requiredFields",false);
            break;
        case 'Ajudante':
        case 'Aprendiz':
        case 'Gestor Operacional':
        case 'Socorrista':
            component.set("v.requiredFields",true);
            break;
        default:
            component.set("v.requiredFields",false);
        }
        //Obrigatoriedade Carteira de trabalho
        switch(contact.Role__c) {
        case 'Administrativo':
        case 'Gestor Operacional':
        case 'Gestor':
            component.set("v.requiredFieldsWorkRegisterBooklet",false);
            break;
        case 'Socorrista':
        case 'Ajudante':
        case 'Aprendiz':
            component.set("v.requiredFieldsWorkRegisterBooklet",true);
            break;
        default:
            component.set("v.requiredFieldsWorkRegisterBooklet",false);
        }

        
    },
})