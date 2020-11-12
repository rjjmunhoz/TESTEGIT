({    phone: function (component, event, helper) {
        var phone = component.find("mobile").getElement().value;
        component.set("v.accountFields.OperationalPhone__c", phone);

        var phone2 = component.find("mobile2").getElement().value;
        component.set("v.accountFields.Phone", phone2);
    
    	var phone3 = component.find("mobile3").getElement().value;
        component.set("v.accountFields.OperationalPhone__c", phone3);

        var phone4 = component.find("mobile4").getElement().value;
        component.set("v.accountFields.Phone", phone4);
    
        console.log("Phone " + component.get("v.accountFields.OperationalPhone__c"));
        console.log("Phone2 " + component.get("v.accountFields.Phone"));

    },
  
  	phonePF: function (component, event, helper) {
    	var phone3 = component.find("mobile3").getElement().value;
        component.set("v.accountFields.OperationalPhone__c", phone3);

        var phone4 = component.find("mobile4").getElement().value;
        component.set("v.accountFields.Phone", phone4);
    
        console.log("Phone " + component.get("v.accountFields.OperationalPhone__c"));
        console.log("Phone2 " + component.get("v.accountFields.Phone"));

    },

    loadForm: function (component, event, helper) {
        component.set("v.formSpinner",false);
    },

    contractType: function (component, event, helper) {
        var accountRecord = component.get("v.accountFields"); 
        
        if(accountRecord.LegalSituation__c == 'PJ'){
            if (accountRecord.ContractType__c.includes("7") || accountRecord.ContractType__c.includes("27") || accountRecord.ContractType__c.includes("26") || accountRecord.ContractType__c.includes("14")|| accountRecord.ContractType__c.includes("2") || accountRecord.ContractType__c.includes("8")) { 
                component.set("v.paymentTable", false);   
                console.log('get ' + component.get("v.paymentTable")); 
                console.log('accountRecord ' + accountRecord.ContractType__c);
                console.log('accountRecord ' + accountRecord.PayTable__c);
                //preencher tablela       
            }
            else{
                component.set("v.paymentTable", true);
                component.set("v.accountFields.PayTable__c", null);
                console.log('get ' + component.get("v.paymentTable")); 
                console.log('accountRecord ' + accountRecord.ContractType__c);
                }
        }
    },
      loadJquery: function (component, event, helper) {
          jQuery(document).ready(function () {
              $('.phone').mask('(99)9999-9999');
              $('.mobile').mask('(99)99999-9999');
          });
      },
})