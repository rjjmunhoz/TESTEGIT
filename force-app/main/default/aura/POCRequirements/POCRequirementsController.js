({
    handleSaveCase: function (component, event, helper) {
        var lRequirements = component.find('requirements').get('v.value');
        var lExpected = component.find('expected').get('v.value');
        if (!lRequirements || /^\s*$/.test(lRequirements) || !lExpected || /^\s*$/.test(lExpected)) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Atenção",
                "message": "Para criar um novo requisito, é necessário preencher os campos 'Requisitos da POC' e 'Retorno Esperado'.",
                "duration": ' 6000',
                "type": 'warning',
            });
            toastEvent.fire();
        }
        else{
            helper.saveCase(component, event, helper);
        }
    }
})