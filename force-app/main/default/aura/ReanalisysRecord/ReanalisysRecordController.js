({
    onInit : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        var greaterEqual90Days = component.get("v.accountRecord.GreaterEqual90Days__c");
        var status = component.get("v.accountRecord.Status__c");
        console.log('greaterEqual90Days '+ greaterEqual90Days);
        var cnpj = component.get("v.accountRecord.CNPJ__c");
        console.log('cnpj ' + cnpj);

        if(greaterEqual90Days != 'reanalisysRefused' && status == 'Inativo'){
            // $A.get("e.force:closeQuickAction").fire();

            var orgDomain = $A.get("{!$Label.c.OrgDomain}");
            var url = orgDomain + "/lightning/cmp/c__ProviderRegistrationWizard?c__cnpj="+cnpj+"&c__loadByUrl=true&c__selectedStep=step2";
            // var urlEvent = $A.get("e.force:navigateToURL");
            // urlEvent.setParams({
            //     "url": url
            // });
            // urlEvent.fire();
            window.location.href = url;
        }
    }
})