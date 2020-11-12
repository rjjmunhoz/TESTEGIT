({
	changeFinancingDate : function(component, event, helper) {
        var value = event.getSource().get("v.value");
        if(value === 'Não'){
            component.set("v.disableFinanc", true);
            component.set("v.requiredFinanc", false);
        }else{
            component.set("v.disableFinanc", false);
            component.set("v.requiredFinanc", true);
        }
    },
    changeCompany : function(component, event, helper) {
        var value = component.get("v.companyListValues");
        var vehicleFields = component.get("v.vehicleFields");
        var action = component.get("c.updateCompany");
        action.setParams({
            'aVehicleJson' : JSON.stringify(vehicleFields),
            'lValuesCompany' : value
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('State picklist ', state);
            if (state == "SUCCESS") {
                var vehicle =JSON.stringify(response.getReturnValue());
                component.set("v.vehicleFields", JSON.parse(vehicle));
            }
    	    else if (state === "ERROR") {
                console.log('Entrou no Error');
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Erro API",
                                "message": errors[0].message + '. Entre em contato com o administrador do sistema.',
                                "type": "error"
                            });
                            toastEvent.fire();
                        }
                    }
                else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
       

    },
    validateFields : function(component, event, helper) {
        var allValid = true;
        var fields = component.find("field");
        fields.forEach(function (field) {
            console.log("###field ",JSON.stringify(field));
            if($A.util.isEmpty(field.get("v.value"))){
                allValid = false;                
            } 
        });
        if(!allValid) {
            console.log('Passo5');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "Por favor preencher os campos obrigatórios!",
                "type": "info"
            });
            toastEvent.fire();
        }        
        return allValid;
    },
    loadJquery: function (component, event, helper) {
        jQuery(document).ready(function () {
            $('.phone').mask('(99)9999-9999');
            $('.mobile').mask('(99)99999-9999');
            $('.renavam').mask('00000000000');
        });
    },
    phoneRes: function (component, event, helper) {
        var phone = component.find("phoneRes").getElement().value;
        component.set("v.vehicleFields.phone__c", phone);
        console.log("phone " + component.get("v.vehicleFields.phone__c"));
        
    },
    mobilePhone: function (component, event, helper) {
        var mobile = component.find("phoneMobile").getElement().value;
        component.set("v.vehicleFields.secondaryphone__c", mobile);
        console.log("phone " + component.get("v.vehicleFields.secondaryphone__c"));
        
    },
    renavamCode: function (component, event, helper) {
        var renav = component.find("renavamCode").getElement().value;
        component.set("v.vehicleFields.RenavamCode__c", renav);
        console.log("renav " + component.get("v.vehicleFields.RenavamCode__c"));
        
    },
})