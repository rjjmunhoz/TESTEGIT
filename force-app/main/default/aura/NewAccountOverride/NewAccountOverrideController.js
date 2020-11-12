({
    doInit: function (component, event, helper) {
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        var recordTypeIdProvider = $A.get("{!$Label.c.RecordTypeIdProvider}");

        if (recordTypeIdProvider != recordTypeId) {
            // var url = "/001";
            // var urlEvent = $A.get("e.force:navigateToURL");
            // urlEvent.setParams({
            //     "url": url
            // });
            // urlEvent.fire();           
            // window.location.href = "/001/e?RecordType="+recordTypeId+"&nooverride=1";
            // window.location.href = "/001/e?RecordType=" + recordTypeId + "&nooverride=1&navigationLocation=MRU_LIST&backgroundContext=%2Flightning%2Fo%2FAccount%2Flist%3FfilterName%3DRecent";
            window.location.href = "/lightning/o/Account/new?recordTypeId=" + recordTypeId + "&nooverride=1&navigationLocation=LIST_VIEW&backgroundContext=%2Flightning%2Fo%2FAccount%2Flist%3FfilterName%3DAllAccounts";
          
            // url = "/001/e?RecordType="+recordTypeId+"&nooverride=1";
            // urlEvent = $A.get("e.force:navigateToURL");
            // urlEvent.setParams({
            //     "url" : url
            // });
            // urlEvent.fire();
        }

        else {
            window.location.href = '/lightning/cmp/c__ProviderRegistrationWizard?c__loadByUrl=false&' + '&retURL=%2F001';
        }
    }
})