({
    onInit: function (component, event, helper) {
      
        var step = component.get("v.vehicleFields.Step__c");
        var standard = component.get("v.vehicleFields.StandardVehicle__c");
        console.log('component.get("v.vehicleFields.Step__c"):' + step);
        console.log('status ', status);
        if (step != 'Step4') {
            if(step == 'Step3' && standard == 'Não'){
               component.set("v.spinner", false);
            }else{           
               var urlEvent = $A.get("e.force:navigateToURL");
               urlEvent.setParams({
                  "isredirect": true,
                  "url": "/lightning/cmp/c__VehicleRegistrationWizard?c__loadByUrl=true&c__selectedStep="+component.get("v.vehicleFields.Step__c") +"&c__Placa_Chassi="+component.get("v.vehicleFields.plate__c")+ '&retURL=%2Fa0A'
               });
               urlEvent.fire();
            }
        }
        else{
           component.set("v.spinner", false);
        }
        // component.set("v.selectedStep",selectedStep);
     },
})