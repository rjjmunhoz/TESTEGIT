({
    doSearchEmployee: function (component, event, helper) {        
        component.set("v.loading", true);
        var cpf = component.get("v.cpf");
        if(cpf == null || cpf == "") {
            component.set("v.loading", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "Digite um CPF para realizar a consulta",
                "type": "error"
            });
            toastEvent.fire();
        }
        else {
            var action = component.get('c.searchEmployeeByCPF');
            action.setParams({ 'aCPF': cpf });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var regWzdWrapper = response.getReturnValue();
                    if(regWzdWrapper == null) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": "Dados não localizados, verifique se o CPF foi digitado corretamente",
                            "type": "info"
                        });
                        toastEvent.fire();
                    }
                    else {   
                        console.log("###regWzdWrapper: ",JSON.stringify(regWzdWrapper));   
                        if(regWzdWrapper.contact.Status__c == 'Ativo') {                            
                            component.set("v.contact",regWzdWrapper.contact);
                            helper.doOpenNotAllowedModal(component, event, helper);
                        }      
                        else {
                            if(regWzdWrapper.contact.StatusRadar__c == 'Aguardando Radar') {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Operação não Permitida",
                                    "message": "Colaborador aguardando análise no Radar",
                                    "type": "info"
                                });
                                toastEvent.fire();
                            } 
                            else {
                                if(regWzdWrapper.contact.RisksStatus__c == 'Aguardando Gestão de Custos e Riscos') {
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Operação não Permitida",
                                        "message": "Colaborador aguardando análise da Gestão de Custos e Riscos",
                                        "type": "info"
                                    });
                                    toastEvent.fire();
                                } 
                                else {
                                    if(component.get("v.resetStepWizard")) {
                                        regWzdWrapper.contact.StepWizard__c = 2;
                                    }
                                    component.set("v.contact",regWzdWrapper.contact);  
                                    component.set("v.isSalesforcePlatformUser",regWzdWrapper.isSalesforcePlatformUser);   
                                    var stepArray = [[2,"step2"], [3,"step3"]];
                                    var stepMap = new Map(stepArray);
                                    component.set("v.selectedStep",stepMap.get(regWzdWrapper.contact.StepWizard__c)); 
                                }
                            }                            
                        }   
                    }                                                   
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "message": errors[0].message,
                                "type": "error"
                            });
                            toastEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                component.set("v.loading", false);
            });
            $A.enqueueAction(action);
        }        
    },      
    doSaveContact: function (component, event, helper) {
        component.set("v.loading", true);
        var contact = component.get("v.contact");
        var action = component.get('c.saveContact');
        action.setParams({ 'aContact': JSON.stringify(contact) });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                if(contact.StepWizard__c == 2) {
                    component.set("v.selectedStep","step3");  
                    component.set("v.contact.StepWizard__c",3);   
                }
                else if(contact.StepWizard__c == 3) {   
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": contact.Id,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    helper.doClearDataCad(component, event, helper);   
                }
            }
            else if (state === "ERROR") {
                var stepArray = [["step2", 2], ["step3", 3]];
                var stepMap = new Map(stepArray);
                var step = component.get("v.selectedStep");         
                component.set("v.contact.Status__c", 'Em implantação');        
                component.set("v.contact.StepWizard__c", stepMap.get(step));  
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": errors[0].message,
                            "type": "error"
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action);
    },    
    ableToNextStep: function (component, step) {
        var stepArray = [["step2", 2], ["step3", 3]];
        var stepMap = new Map(stepArray);
        var contact = component.get("v.contact");  
        if(contact == null || stepMap.get(step) > contact.StepWizard__c) {
            return false;
        }  
        return true;            
    },
    redirectToRescuer: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.contact.Id"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        helper.doClearDataCad(component, event, helper);  
    }, 
    doCloseWizard: function (component, event, helper) {        
        helper.doClearDataCad(component, event, helper);        
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewName": null,
            "scope": "Contact"
        });
        navEvent.fire();
    },  
    doClearDataCad: function (component, event, helper) {
        component.set("v.selectedStep", 'step1'); 
        component.set("v.cpf", null); 
        component.find("cpf_field").getElement().value = null;
    },  
    doOpenNotAllowedModal: function (component, event, helper) {
        var cmpTarget = component.find('NotAllowed');
        var cmpBack = component.find('ModalNotAllowed');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    doCloseNotAllowedModal: function (component, event, helper) {
        var cmpTarget = component.find('NotAllowed');
        var cmpBack = component.find('ModalNotAllowed');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    doOpenCancelModal: function (component, event, helper) {
        var cmpTarget = component.find('ModalCancel');
        var cmpBack = component.find('ModalCancelbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    doCloseCancelModal: function (component, event, helper) {
        var cmpTarget = component.find('ModalCancel');
        var cmpBack = component.find('ModalCancelbackdrop');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    cpfError: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Erro",
            "message": "Digite um CPF válido.",
            "type": "error"
        });
        toastEvent.fire();
    }
})