({
    onInit: function (component, event, helper) {
        helper.doinit(component, event, helper);
    },
    onSubmit: function (component, event, helper) {
        helper.doSubmit(component, event, helper);
    },
    onSave: function (component, event, helper) {
        var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
        var status = component.get("v.caseRecord.Status");
        var recType = component.get("v.caseRecord.RecordType.DeveloperName");
        if(recType == 'Prototyping' && (status == 'Análise de Prototipação' || status == 'POC')){
            helper.doSubmit(component, event, helper);
        }
    }
})