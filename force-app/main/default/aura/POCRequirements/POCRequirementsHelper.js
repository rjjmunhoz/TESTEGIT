({
    saveCase: function(component, event, helper) {
        var lRequirements = component.find('requirements').get('v.value');
        var lExpected = component.find('expected').get('v.value');
        var lRecordId = component.get("v.recordId");
        var lResponse;
        console.log('lExpected',JSON.stringify(lExpected));
        
        var action = component.get('c.createPOCRequeriment');
        action.setParams({
            'aPOCRequirements': lRequirements,
            'aExpectedOutcome': lExpected,
            'aRecordId': lRecordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Requisito criado com sucesso!",
                    "type": "success"
                });
                toastEvent.fire();
            } 
            else{
                toastEvent.setParams({
                    "type": 'error',
                    "message": "Erro ao criar o requisito! Atualize a página e tente novamente.",
                    "mode": "sticky"
                });
                toastEvent.fire();
                lResponse = response.getReturnValue();
                console.log("lResponse ---> " + JSON.stringify(lResponse));
            }
        });
        
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
        component.set("v.lRequirements", " ");
        component.set("v.lExpected", " ");
    }

})