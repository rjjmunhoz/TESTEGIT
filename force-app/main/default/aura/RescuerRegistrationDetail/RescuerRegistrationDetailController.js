({
   onInit: function (component, event, helper) {
      
      var recTypeDevName = component.get("v.contactFields.RecordType.Developername");
      console.log('recTypeDevName ', recTypeDevName);
      var status = component.get("v.contactFields.Status__c");
      console.log('status ', status);
      if (status == 'Em implantação' && 1+1==3) {
         var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
            "isredirect": true,
            "url": "/lightning/cmp/c__RescuerRegistrationWizard?c__loadByUrl=true&c__recordId=" + component.get("v.contactFields.RecordTypeId") + '&c__cpf=' + component.get("v.contactFields.CPF__c") + '&retURL=%2F003'
         });
         urlEvent.fire();
      }
      else{
         component.set("v.spinner", false);
      }
      // component.set("v.selectedStep",selectedStep);
   },
})