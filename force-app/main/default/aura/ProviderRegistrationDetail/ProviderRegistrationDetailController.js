({
   onInit: function (component, event, helper) {
      
      var step = component.get("v.accountFields.StepWizard__c");
      var typePerson = component.get("v.accountFields.LegalSituation__c");
       
      console.log('status ', status);
      if (step != '1') {
         if(typePerson == 'PJ'){
         	window.location.href = "/lightning/cmp/c__ProviderRegistrationWizard?c__loadByUrl=true&c__recordId=" + component.get("v.accountFields.RecordTypeId") + '&c__cnpj=' + component.get("v.accountFields.CNPJ__c") + '&c__personType=' + component.get("v.accountFields.LegalSituation__c") + '&retURL=%2F001';
         }
         else{
              window.location.href = "/lightning/cmp/c__ProviderRegistrationWizard?c__loadByUrl=true&c__recordId=" + component.get("v.accountFields.RecordTypeId") + '&c__cpf=' + component.get("v.accountFields.CNPJ__c") + '&c__personType=' + component.get("v.accountFields.LegalSituation__c") + '&retURL=%2F001';
         }
      }
      else{
         component.set("v.spinner", false);
      }
   },
})