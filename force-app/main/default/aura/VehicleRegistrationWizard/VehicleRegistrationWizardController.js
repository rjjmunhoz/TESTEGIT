({  
    onInit : function(component, event, helper) {
        helper.checkProfile(component, event, helper);
        console.log('accountFields ' + JSON.stringify(component.get("v.vehicleFields")));
        console.log('step: '+ component.get("v.selectedStep"));
        var myPageRef = component.get("v.pageReference");
        console.log('myPageRef ' + JSON.stringify(myPageRef));
        if (myPageRef != null){            
            var loadByUrl = myPageRef.state.c__loadByUrl;
            var placaChassi = myPageRef.state.c__Placa_Chassi;
            var step = myPageRef.state.c__selectedStep;
            console.log('loadByUrl ' + loadByUrl);
            if (loadByUrl == 'true'){  
                helper.getCompanyPicklistObject(component, event, helper);
                helper.getVehicle(component, event, helper, placaChassi, loadByUrl, step);
            }
        }
        component.set("v.showSpinner", false);

    }, 
    getVehicle : function (component, event, helper) {
        component.set("v.showSpinner", true);
        console.log('Entrou no Controller');
        var placaChassi = component.get("v.Placa_Chassi"); 
        console.log('teste 2 valor placaChassi: '+ placaChassi);
        if (placaChassi == null || placaChassi == undefined){
            

            console.log('Deu ruim');
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Erro",
                "message": "Digite um Chassi ou Placa válido.",
                "type":"error"
            });
            toastEvent.fire();
            component.set("v.showSpinner", false);
        }
        else{
            if(placaChassi.includes('-')){
                

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro",
                    "message": "Digite a placa sem caracteres especiais.",
                    "type":"error"
                });
                toastEvent.fire();
                component.set("v.showSpinner", false);
            }else{
                console.log('placaChassi veio preenchido: '+placaChassi +' vamos tentar entrar no helper');
                helper.getCompanyPicklistObject(component, event, helper);
                helper.getVehicle(component, event, helper, placaChassi, false, 'Step2');
            }
            
        }        
    }, 
    handleNext: function (component, event, helper) {
        component.set("v.showSpinner", true);

        var getselectedStep = component.get("v.selectedStep");
        var vehicleFields = component.get("v.vehicleFields");   
        var modalIsActive = component.get("v.modalActive");     
		if(getselectedStep == 'Step2'){

            //var step2Cmp = component.find("step2CmpId");
            //console.log('Passo1');
            //var notHasFieldError = step2Cmp.validateFieldsStepMethod();
            console.log('Passo2');
            //if(notHasFieldError) {
                if(vehicleFields.Name == null || vehicleFields.Name == undefined || vehicleFields.Name == '' ||
                    vehicleFields.plate__c == null || vehicleFields.plate__c == undefined || vehicleFields.plate__c == '' ||
                    vehicleFields.StandardVehicle__c == null || vehicleFields.StandardVehicle__c == undefined || vehicleFields.StandardVehicle__c == '' ||
                    vehicleFields.Color__c == null || vehicleFields.Color__c == undefined || vehicleFields.Color__c == '' ||
                    vehicleFields.TypeFuel__c == null || vehicleFields.TypeFuel__c == undefined || vehicleFields.TypeFuel__c == '' ||
                    vehicleFields.TypeAcquisition__c == null || vehicleFields.TypeAcquisition__c == undefined || vehicleFields.TypeAcquisition__c == '' ||
                    vehicleFields.YearManufacture__c == null || vehicleFields.YearManufacture__c == undefined || vehicleFields.YearManufacture__c == '' ||
                    vehicleFields.Provider__c == null || vehicleFields.Provider__c == undefined || vehicleFields.Provider__c == '' ||
                    vehicleFields.OwnerName__c == null || vehicleFields.OwnerName__c == undefined || vehicleFields.OwnerName__c == '' ||
                   	document.querySelector("[name='renavamCode']").value == null || document.querySelector("[name='renavamCode']").value == undefined || document.querySelector("[name='renavamCode']").value == '' ||
                    ((vehicleFields.TypeModal__c == null || vehicleFields.TypeModal__c == undefined || vehicleFields.TypeModal__c == '' ||
                    document.querySelector("[name='phoneRes']").value == null || document.querySelector("[name='phoneRes']").value == undefined || document.querySelector("[name='phoneRes']").value == '' ||
                    document.querySelector("[name='phoneMobile']").value == null || document.querySelector("[name='phoneMobile']").value == undefined || document.querySelector("[name='phoneMobile']").value == '' ||
                    vehicleFields.TypeRegistration__c == null || vehicleFields.TypeRegistration__c == undefined || vehicleFields.TypeRegistration__c == '' ||
                    vehicleFields.FinancingDate__c == null || vehicleFields.FinancingDate__c == undefined || vehicleFields.FinancingDate__c == '' || 
                    (vehicleFields.FinancingDate__c == 'Sim' && (vehicleFields.FinancingMonth__c == null || vehicleFields.FinancingMonth__c == undefined || vehicleFields.FinancingMonth__c == '' ||
                    vehicleFields.FinancingYear__c == null || vehicleFields.FinancingYear__c == undefined || vehicleFields.FinancingYear__c == '') )))) {
                    component.set("v.showSpinner", false);    
                    console.log('Caiu');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": "Para proseguir com o cadastro, preencha todos os campos dessa etapa.",
                            "type": "info"
                        });
                        toastEvent.fire();
                }
                else{
                    console.log('Não caiu');
                    if(vehicleFields.Chassi__c == null || vehicleFields.Chassi__c == undefined || vehicleFields.Chassi__c == ''){
                        component.set("v.showSpinner", false);
                        var toastEvent3 = $A.get("e.force:showToast");
                        toastEvent3.setParams({
                            "title": "Atenção",
                            "message": "Não é possível concluir o cadastro pois o campo Chassi está vazio",
                            "type": "warning"
                        });
                        toastEvent3.fire();
                    }else{
                        console.log('vehicleFields.StandardVehicle__c: '+vehicleFields.StandardVehicle__c)
                        if(vehicleFields.StandardVehicle__c == 'Sim'){
                            helper.updateVehicle(component, event, helper, false, 'Step3');
                        }else{
                            helper.updateVehicle(component, event, helper, true, 'Step3');
                        }                   
                    }
                }
            }
   
    },
    handleClose: function (component, event, helper) {
        
        component.set("v.vehicleFields", null);
        var orgDomain = $A.get("{!$Label.c.OrgDomain}");
        component.set("v.selectedStep", "Step1");
        var url = orgDomain + "/lightning/o/Vehicle__c/list?filterName=Recent" /*"/002"*/;
        window.location.href = url;
        
    },    
    finish: function (component, event, helper) {
        component.set("v.showSpinner", true);
        var vehicleFields = component.get("v.vehicleFields");
        console.log('vehicleFields: '+JSON.stringify(vehicleFields));

        if(vehicleFields.SurveyStatus__c == null || vehicleFields.SurveyStatus__c == undefined || vehicleFields.SurveyStatus__c == '' || (vehicleFields.SurveyStatus__c != 'Não necessario' &&
           (vehicleFields.DateLastSurvey__c == null || vehicleFields.DateLastSurvey__c == undefined || vehicleFields.DateLastSurvey__c == '')) ||
           vehicleFields.Nonstop__c == null || vehicleFields.Nonstop__c == undefined || vehicleFields.Nonstop__c == '' ||
            vehicleFields.Standardization__c == null || vehicleFields.Standardization__c == undefined || vehicleFields.Standardization__c == '' 
        ){
            component.set("v.showSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Atenção",
                    "message": "Para proseguir com o cadastro, preencha todos os campos dessa etapa.",
                    "type": "info"
                });
                toastEvent.fire();
        }else{
            component.set("v.showSpinner", true);
            helper.updateVehicle(component, event, helper, true, 'Step3');      
        }
    },
    selectStep1: function (component, event, helper) {
        var vehicleFields = component.get("v.vehicleFields");
        if (vehicleFields.Step__c == 'Step2' || vehicleFields.Step__c == 'Step3') {
            component.set("v.selectedStep", "Step1"); 
        }        
    },
    selectStep2: function (component, event, helper) {
        var vehicleFields = component.get("v.vehicleFields");
        if (vehicleFields.Step__c == 'Step2' || vehicleFields.Step__c == 'Step3') {
            component.set("v.selectedStep", "Step2");
        }
    },
    selectStep3: function (component, event, helper) {
        var vehicleFields = component.get("v.vehicleFields");
        if (vehicleFields.Step__c == 'Step3') {
            component.set("v.selectedStep", "Step3");
        }
    },
    optionsFinances : function(component, event, helper) {
		var listOptions = "[{'label': 'Sim', 'value': 'Sim'},{'label': 'Não', 'value': 'Não'}]";
        component.set("listOptions", listOptions);
    }
})