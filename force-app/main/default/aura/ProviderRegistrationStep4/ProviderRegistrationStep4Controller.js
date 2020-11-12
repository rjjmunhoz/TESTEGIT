({
    onInit: function (component, event, helper) {

        var pep = [
            {
                "label": "Sim",
                "value": "S"
            },
            {
                "label": "Não",
                "value": "N"
            }
        ];
        var msg = $A.get("{!$Label.c.CompanyResponsable}");
        component.set("v.companyResponsableMsg", msg);
        component.set("v.optionsPEP", pep);
        component.set("v.contactsFields", { "PEP__c": "" });


    },
    loadJquery: function (component, event, helper) {
        jQuery(document).ready(function () {
            $('.phone').mask('(99)9999-9999');
            $('.mobile').mask('(99)99999-9999');
            $('.cpf').mask('999.999.999-99');
            $('.cep').mask('99999-999');
        });
    },
    
    partnerPhone: function (component, event, helper) {
        var partners = component.get("v.partners");
        partners[event.currentTarget.name].Phone = event.currentTarget.value;
        component.set("v.partners", partners);
        console.log('mobile ' + partners[event.currentTarget.name].Phone );
    
    },
    partnerMobile: function (component, event, helper) {
        var partners = component.get("v.partners");
        partners[event.currentTarget.name].MobilePhone = event.currentTarget.value;
        component.set("v.partners", partners);
        console.log('mobile ' + partners[event.currentTarget.name].MobilePhone);
    },
    billingCep: function (component, event, helper) {
        var cep = component.find("billingCep").getElement().value;
        component.set("v.accountFields.OperationalZip__c", cep);
        console.log("billingCep " + component.get("v.accountFields.OperationalZip__c"));
    },
    shippingCep: function (component, event, helper) {
        var cep = component.find("shippingCep").getElement().value;
        component.set("v.accountFields.DeliveryZip__c", cep);
        console.log("shippingCep " + component.get("v.accountFields.DeliveryZip__c"));
    },
    taxCep: function (component, event, helper) {
        var cep = component.find("taxCep").getElement().value;
        component.set("v.accountFields.TaxZip__c", cep);
        console.log("shippingCep " + component.get("v.accountFields.TaxZip__c"));
    },
})