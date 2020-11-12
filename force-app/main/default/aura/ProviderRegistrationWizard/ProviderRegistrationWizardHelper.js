({
    doInit: function (component, event, helper) {
        component.set("v.accountFields", { "ActuationType__c": "", "HaveParking__c": "", "Attend24h__c": "", "Analyst__c": "", "ScheduleType__c": "", "Schedule__c": "" });
        var action = component.get('c.getPicklistValues');
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                component.set("v.providerTypeOptions", response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

        var bankAction = component.get('c.getBankValues');
        // action.setParams({ });
        bankAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                component.set("v.bankOptions", response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(bankAction);
    },
    searchProvider: function (component, event, helper, aCnpj) {
        component.set("v.loading", true);
        // cnpj = component.get("v.cnpj");
        // console.log('selectedStep + ' + component.get("v.selectedStep"));

        var action = component.get('c.searchCnpj');
        action.setParams({
            'aCnpj': aCnpj
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                if (response.getReturnValue() != null) {
                    var accountRecord = response.getReturnValue();
                    
                    component.set("v.accountFields", accountRecord.lAcc);
                    component.set("v.partners", accountRecord.lContactLst);
                    // console.log('accountRecord.lAcc ' + JSON.stringify(accountRecord.lAcc));
                    // console.log('component.get("v.partners") ' + JSON.stringify(component.get("v.partners")));
                    if (accountRecord.lAcc.StatusRadar__c == 'L') {
                        component.set('v.radarStatus', 'Liberado');
                    }
                    else if (accountRecord.lAcc.StatusRadar__c == 'B') {
                        component.set('v.radarStatus', 'Bloqueado');
                    }
                    else if (accountRecord.lAcc.StatusRadar__c == 'Aguardando Radar') {
                        component.set('v.radarStatus', accountRecord.lAcc.StatusRadar__c);
                    }
                    
                    if (accountRecord.lAcc.ContractType__c != undefined && (accountRecord.lAcc.ContractType__c.includes("Help Desk") || accountRecord.lAcc.ContractType__c.includes("Linha Branca") || accountRecord.lAcc.ContractType__c.includes("Linha Básica") || accountRecord.lAcc.ContractType__c.includes("Vigilante"))){
                        component.set("v.paymentTable", false);
                    }
                    if (accountRecord.lAcc.CardSituation__c.includes("Inativa") || accountRecord.lAcc.CardSituation__c.includes("INATIVA") || accountRecord.lAcc.CardSituation__c.includes("inativa") || 
                        accountRecord.lAcc.CardSituation__c.includes("Inapta") || accountRecord.lAcc.CardSituation__c.includes("INAPTA") || accountRecord.lAcc.CardSituation__c.includes("inapta") ||
                        accountRecord.lAcc.CardSituation__c.includes("Suspensa") || accountRecord.lAcc.CardSituation__c.includes("SUSPENSA") || accountRecord.lAcc.CardSituation__c.includes("suspensa") ||
                        accountRecord.lAcc.CardSituation__c.includes("Baixada") || accountRecord.lAcc.CardSituation__c.includes("BAIXADA") || accountRecord.lAcc.CardSituation__c.includes("baixada") ||
                        accountRecord.lAcc.CardSituation__c.includes("Nula") || accountRecord.lAcc.CardSituation__c.includes("NULA") || accountRecord.lAcc.CardSituation__c.includes("nula") ||
                        accountRecord.lAcc.Name == null || accountRecord.lAcc.CompanyName__c == null || accountRecord.lAcc.UpdateDate__c == null || accountRecord.lAcc.CardSituation__c == null){
                        component.set("v.cardSituation", false);
                    }
                    else{
                        component.set("v.cardSituation", true);
                    }
                    // console.log('v.cardSituation ' + component.get("v.cardSituation"));
                    // console.log('Account Record ' + JSON.stringify(response.getReturnValue()));

                    // if (accountRecord.lAcc.GreaterEqual90Days__c != 'reanalisysPermited' && (accountRecord.lAcc.Status__c == 'Inativo' || accountRecord.lAcc.Status__c == 'Ativo')) {
                    //     helper.openNotAllowedModal(component, event, helper);
                    // }
                    if (accountRecord.lAcc.Status__c != 'Inativo' && accountRecord.lAcc.Status__c != 'Em implantação' && accountRecord.lAcc.Status__c != undefined || (accountRecord.lAcc.Status__c == 'Em implantação' && accountRecord.lAcc.StepWizard__c == '1')) {
                        helper.openNotAllowedModal(component, event, helper);
                    }
                    else if (accountRecord.lAcc.GreaterEqual90Days__c == 'reanalisysRefused'){
                        helper.openNotAllowedModal(component, event, helper);
                    }
                    else if (accountRecord.lAcc.StepWizard__c == 1 || accountRecord.lAcc.StepWizard__c == 2 || accountRecord.lAcc.StepWizard__c == undefined) {
                        component.set("v.selectedStep", 'step2');
                    }
                    else if (accountRecord.lAcc.StepWizard__c == 3) {
                        helper.handleVisibility(component, event, helper);
                        component.set("v.selectedStep", 'step3');
                    }
                    else if (accountRecord.lAcc.StepWizard__c == 4) {
                        helper.handleVisibility(component, event, helper);
                        // helper.getPartners(component, event, helper);  
                        component.set("v.selectedStep", 'step4');
                    }
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Atenção",
                        "message": "CNPJ não localizado. Verifique o número e digite novamente.",
                        "type": "warning"
                    });
                    toastEvent.fire();
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Erro API",
                            "message": errors[0].message + '. Entre em contato com o administrador do sistema.',
                            "type": "error"
                        });
                        toastEvent.fire();
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action);
    },
    handleVisibility: function (component, event, helper) {
        var accountFields = component.get("v.accountFields");

        if (accountFields.StepWizard__c == 1 || accountFields.StepWizard__c == 2){
            component.set("v.disabledNext", true);
            component.set("v.disabledReanalisys", true);
            component.set("v.disabledCancel", true);
            component.set("v.renderReanalysReason", true);
            component.set("v.step3Messages", $A.get("{!$Label.c.MessageScreenThreeRadar}"));
            component.set("v.renderReanalyStatus", true);            
            component.set("v.selectedStep", "step3");
        }
        else if (accountFields.StepWizard__c == 3) {
            if (accountFields.StatusRadar__c == 'Aguardando Radar') {
                component.set("v.disabledCancel", true);
                component.set("v.disabledNext", true);
                component.set("v.renderReanalysReason", true);
                component.set("v.disabledReanalisys", true);
                component.set("v.renderReanalyStatus", true); 
                component.set("v.step3Messages", $A.get("{!$Label.c.MessageScreenThreeRadar}"));
            }
            else if (accountFields.StatusRadar__c != 'Aguardando Radar' && accountFields.StatusRadar__c != 'L' && (accountFields.RisksStatus__c == null || accountFields.RisksStatus__c == undefined)) {
                component.set("v.disabledNext", true);
                component.set("v.renderReanalyStatus", true); 
            }
            else if (accountFields.StatusRadar__c == 'L') {
                component.set("v.renderReanalysReason", true);
                component.set("v.disabledReanalisys", true);
                component.set("v.renderReanalyStatus", true); 
            }
            else if (accountFields.RisksStatus__c == 'Liberado'){
                component.set("v.disabledReanalisys", true);
                component.set("v.renderReanalysReason", true);
            }
            else if (accountFields.RisksStatus__c == 'Aguardando Gestão de Custos e Riscos'){
                component.set("v.disabledNext", true);
                component.set("v.disabledReanalisys", true);
                component.set("v.disabledCancel", true);
                component.set("v.disableTypeReanalysisReason", true);
                component.set("v.step3Messages", $A.get("{!$Label.c.MessageScreenThreeRisk}"));
            }          
            else if (accountFields.RisksStatus__c != 'Aguardando Gestão de Custos e Riscos' && accountFields.RisksStatus__c != undefined && accountFields.RisksStatus__c != 'Liberado' && accountFields.StatusRadar__c != 'Aguardando Radar' && accountFields.StatusRadar__c != 'L') {
                component.set("v.disabledNext", true);
                component.set("v.disabledReanalisys", true);
                component.set("v.renderReanalyStatus", false);
                component.set("v.disableTypeReanalysisReason", true);
                component.set("v.step3Messages", $A.get("{!$Label.c.CancelMessage}"));
            }
        }
        else if (accountFields.StepWizard__c == 4) {
            component.set("v.disableTypeReanalysisReason", true);
            component.set("v.renderReanalysReason", true);
            component.set("v.disabledReanalisys", true);
            component.set("v.renderReanalyStatus", false);
        }
    },
    openNotAllowedModal: function (component, event, helper) {
        var cmpTarget = component.find('NotAllowed');
        var cmpBack = component.find('ModalNotAllowed');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    redirectToProvider: function (component, event, helper) {
        
        var recordId = component.get("v.accountFields.Id");
        // var orgDomain = $A.get("{!$Label.c.OrgDomain}");
        // var url = orgDomain + "/" + recordId;
        var url = "/" + recordId;

        // console.log('url ' + recordId);
        // var urlEvent = $A.get("e.force:navigateToURL");
        // urlEvent.setParams({
        //     "url": url
        // });
        // urlEvent.fire();
        window.location.href = url;
    },

    updateProvider: function (component, event, helper) {
        component.set("v.loading", true);
        var accountFields = component.get("v.accountFields");
        var action = component.get('c.updateAccount');
        action.setParams({ aProviderJson: JSON.stringify(accountFields) });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                console.log('updated succefully');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Erro API",
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

    updateContacts: function (component, event, helper) {
        component.set("v.loading", true);
        var accountFields = component.get("v.accountFields");
        var action = component.get('c.updateContact');
        action.setParams({ aProviderJson: JSON.stringify(accountFields) });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                console.log('updated succefully');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action);
    },

    sendPartners: function (component, event, helper) {
        component.set("v.partnersSpinner", true);
        var accountFields = component.get("v.accountFields");
        var cnpj = component.get("v.cnpj");
        var action = component.get('c.calloutPartners');
        // console.log('cnpj ' + cnpj);
        // console.log('accountFields.Id ' + accountFields.Id);
        action.setParams({ aCNPJ: cnpj, aProviderId: accountFields.Id });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                console.log('Partners Loaded');
                component.set("v.partners", response.getReturnValue());
                // console.log('Partners : ' + JSON.stringify(response.getReturnValue()));
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.loading", false);
            component.set("v.partnersSpinner", false);
        });
        $A.enqueueAction(action);
    },

    savePartners: function (component, event, helper) {
        
        var partners = component.get("v.partners");
        console.log(JSON.stringify(partners));
        
        var action = component.get('c.savePartners');
        action.setParams({
            'aPartners': JSON.stringify(partners)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
               console.log('Partners created sussefully!');
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Erro API",
                            "message": errors[0].message + '. Entre em contato com o administrador do sistema.',
                            "type": "error"
                        });
                        toastEvent.fire();
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }
            component.set("v.loading", false);
        });
        $A.enqueueAction(action);       
    },
    cnpjError: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Erro",
            "message": "Digite um CNPJ válido.",
            "type": "error"
        });
        toastEvent.fire();
    },
    cpfError: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Erro",
            "message": "Digite um CPF válido.",
            "type": "error"
        });
        toastEvent.fire();
    },
    doSearchEmployee: function (component, event, helper, cpf) {        
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
                    console.log("###regWzdWrapper: ",JSON.stringify(regWzdWrapper));
                    if(regWzdWrapper == null) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": "Dados não localizados, verifique se o CPF foi digitado corretamente",
                            "type": "info"
                        });
                        toastEvent.fire();
                    }
                    else { 
                        component.set("v.accountFields", regWzdWrapper.account);
                        console.log('v.accountFields ' + component.get("v.accountFields.Name"));
                        console.log('accountRecord.lAcc ' + JSON.stringify(regWzdWrapper.account));
                        
                        if (regWzdWrapper.account.StatusRadar__c == 'L') {
                            console.log('1');
                            component.set('v.radarStatus', 'Liberado');
                        }
                        else if (regWzdWrapper.account.StatusRadar__c == 'B') {
                            console.log('2');
                            component.set('v.radarStatus', 'Bloqueado');
                        }
                        else if (regWzdWrapper.account.StatusRadar__c == 'Aguardando Radar') {
                            console.log('3');
                            component.set('v.radarStatus', regWzdWrapper.account.StatusRadar__c);
                        }
                        
                        if (regWzdWrapper.account.CardSituation__c.includes("Inativa") || regWzdWrapper.account.CardSituation__c.includes("INATIVA") || regWzdWrapper.account.CardSituation__c.includes("inativa") || 
                            regWzdWrapper.account.CardSituation__c.includes("Inapta") || regWzdWrapper.account.CardSituation__c.includes("INAPTA") || regWzdWrapper.account.CardSituation__c.includes("inapta") ||
                            regWzdWrapper.account.CardSituation__c.includes("Suspensa") || regWzdWrapper.account.CardSituation__c.includes("SUSPENSA") || regWzdWrapper.account.CardSituation__c.includes("suspensa") ||
                            regWzdWrapper.account.CardSituation__c.includes("Baixada") || regWzdWrapper.account.CardSituation__c.includes("BAIXADA") || regWzdWrapper.account.CardSituation__c.includes("baixada") ||
                            regWzdWrapper.account.CardSituation__c.includes("Nula") || regWzdWrapper.account.CardSituation__c.includes("NULA") || regWzdWrapper.account.CardSituation__c.includes("nula") ||
                            regWzdWrapper.account.Name == null || regWzdWrapper.account.UpdateDate__c == null || regWzdWrapper.account.CardSituation__c == null){
                            component.set("v.cardSituation", false);
                        }
                        else{
                            component.set("v.cardSituation", true);
                        }
                        if (regWzdWrapper.account.Status__c != 'Inativo' && regWzdWrapper.account.Status__c != 'Em implantação' && regWzdWrapper.account.Status__c != undefined || (regWzdWrapper.account.Status__c == 'Em implantação' && regWzdWrapper.account.StepWizard__c == '1')) {
                            helper.openNotAllowedModal(component, event, helper);
                        }
                        else if (regWzdWrapper.account.GreaterEqual90Days__c == 'reanalisysRefused'){
                            helper.openNotAllowedModal(component, event, helper);
                        }
                        else if (regWzdWrapper.account.StepWizard__c == 1 || regWzdWrapper.account.StepWizard__c == 2 || regWzdWrapper.account.StepWizard__c == undefined) {
                            component.set("v.selectedStep", 'step2');
                        }
                        else if (regWzdWrapper.account.StepWizard__c == 3) {
                            helper.handleVisibility(component, event, helper);
                            component.set("v.selectedStep", 'step3');
                        }
                        else if (regWzdWrapper.account.StepWizard__c == 4) {
                            helper.handleVisibility(component, event, helper);
                            component.set("v.selectedStep", 'step4');
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
    }
})