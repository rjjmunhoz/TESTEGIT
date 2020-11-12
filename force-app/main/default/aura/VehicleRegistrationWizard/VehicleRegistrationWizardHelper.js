({
    getVehicle : function(component, event, helper, aPlateChassi, loadByUrl, step) {        
        var action = component.get("c.searchVehicle");
        action.setParams({
            'aPlateChassi' : aPlateChassi
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var vehicleFields = response.getReturnValue();
                if(vehicleFields !== null){
                    component.set("v.vehicleFields", vehicleFields);
                    if(vehicleFields.Step__c == 'Step4'){
                        this.finish(component, event, helper);
                    }else{

                        var section = {'brand': true , 'plate': true, 'color': true , 'fuel': true , 'manufacture': true , 'yearModel': true};
                        if(vehicleFields.Name == undefined || vehicleFields.Name == null || vehicleFields.Name == ''){
                            section.brand = false;
                        }
                        if(vehicleFields.plate__c == undefined || vehicleFields.plate__c == null || vehicleFields.plate__c == ''){
                            section.plate = false;
                        }
                        if(vehicleFields.Color__c == undefined || vehicleFields.Color__c == null || vehicleFields.Color__c == '' || vehicleFields.Color__c == '0'){
                            section.color = false;
                        }
                        if(vehicleFields.TypeFuel__c == undefined || vehicleFields.TypeFuel__c == null || vehicleFields.TypeFuel__c == ''){
                            section.fuel = false;
                        }
                        if(vehicleFields.YearManufacture__c == undefined || vehicleFields.YearManufacture__c == null || vehicleFields.YearManufacture__c == ''){
                            section.manufacture = false;
                        }
                        console.log('vehicleFields.TypeModal__c: '+ vehicleFields.TypeModal__c);
                        var profile = component.get("v.profile");
                        if((vehicleFields.TypeModal__c == undefined || vehicleFields.TypeModal__c == null || vehicleFields.TypeModal__c == '')){
                            if(profile == 'Relacionamento' || profile == 'Projetos e Sustentação'){
                                component.set("v.tipoModal", false);
                            }
                        }else{
                            if(vehicleFields.TypeModal__r.Status__c != 'Ativo'){
                                vehicleFields.TypeModal__c = null;
                            }
                        } 
                        component.set("v.sectionDisabled", section);
                        if(loadByUrl){
                            this.changeCompany(component, event, helper, vehicleFields);
                        }
                        if(vehicleFields.Step__c !== 'Step1'){
                            step = vehicleFields.Step__c;
                            this.changeCompany(component, event, helper, vehicleFields);
                        }
                        if(vehicleFields.phone__c == undefined ){
                        }else{
                            document.querySelector("[name='phoneRes']").value = vehicleFields.phone__c;
                        }
                        
                        if(vehicleFields.secondaryphone__c == undefined){
                        }else{
                            document.querySelector("[name='phoneMobile']").value = vehicleFields.secondaryphone__c;
                        }
                        
                        if(vehicleFields.RenavamCode__c == undefined){
                        }else{
                            document.querySelector("[name='renavamCode']").value = vehicleFields.RenavamCode__c;
                        }
                        component.set("v.selectedStep", step);
                        component.set("v.vehicleFields", vehicleFields);
                    }
                    
                }else{
                    var toastEventErro = $A.get("e.force:showToast");
                    toastEventErro.setParams({
                        "title": "Erro",
                        "message": 'Nenhuma placa ou chassi foi encontrado',
                        "type": "error"
                    });
                    toastEventErro.fire();
                    component.set("v.selectedStep", 'Step1');
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
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
        
    },
    getCompanyPicklistObject: function(component, event, helper){
        var action = component.get("c.getCompanyPicklistObj");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var options = response.getReturnValue();
                component.set("v.companyList", options);
                var values = [];
                var i;
                for( i = 0; i<options.length; i++){
                    console.log('i ' + i);
                    values.push(options[i].value);

                }
                //console.log('values ' + values);
                component.set("v.companyListValues",values);
                //console.log('response ', response.getReturnValue());

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
        });
        $A.enqueueAction(action);
    },
    updateVehicle: function (component, event, helper, finish, step) {
        var vehicleFields = component.get("v.vehicleFields");
        var selectedStep = component.get("v.selectedStep");
        var profile = component.get("v.profile");
        var companyListValues = component.get("v.companyListValues");
        var action = component.get('c.saveVehicle');
        action.setParams({ 
            aVehicleJson: JSON.stringify(vehicleFields),
            step: selectedStep,
            valuesCompany: companyListValues
        });
        component.set("v.selectedStep", step); 
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var vehicle = response.getReturnValue();
                //console.log('vehicle: '+ vehicle.Step__c);
                component.set("v.vehicleFields", vehicle);                        
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
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
        if(finish){

            var recordId = component.get("v.vehicleFields.Id");
            var orgDomain = $A.get("{!$Label.c.OrgDomain}");
            var url = orgDomain + "/" + recordId;

            window.location.href = url;
        }else{
            component.set("v.textInfoStep3", 'O Veículo cadastrado está na fila. Aguarde o retorno da área de Gestão de Insumos.');
        }
    },
    changeCompany : function(component, event, helper, vehicleFields) {
        var value = component.get("v.companyListValues");
        var action = component.get("c.updateCompanyLoad");
        action.setParams({
            'aVehicleJson' : JSON.stringify(vehicleFields),
            'lValuesCompany' : value
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var options = response.getReturnValue();
                var values = [];
                var i;
                for( i = 0; i<options.length; i++){
                    console.log('i ' + options[i].value);
                    values.push(options[i].value);
                }
                component.set("v.companyListValues",values);
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
        });
        $A.enqueueAction(action);
       

    },
    checkProfile : function(component, event, helper) {
        var action = component.get("c.getProfileName");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var profile = response.getReturnValue();
                var sectionStep2 = {'ipva': true , 'provider': true, 'typeRegistration': true , 'phone': true , 'secondaryPhone': true , 'typeModal': true, 'financingDate': true, 'company':true, 'renavam': true, 'traffic': true, 'nameOwner': true, 'standardVehicle': true, 'typeAcquisition': true};
                var sectionStep3 = {'semParar': true , 'standardization': true, 'vehicleStatus': true, 'dataSurvey': true, 'statusSurvey': true};
                if(profile == 'Relacionamento' || profile == 'Projetos e Sustentação'){
                    sectionStep2.ipva = false;
                    sectionStep2.provider = false;
                    sectionStep2.typeRegistration = false;
                    sectionStep2.phone = false;
                    sectionStep2.secondaryPhone = false;
                    sectionStep2.financingDate = false;
                    sectionStep2.company = false;
                    sectionStep2.traffic = false;
                    sectionStep2.renavam = false;
                    sectionStep2.nameOwner = false;
                    sectionStep2.typeAcquisition = false;
                    sectionStep2.standardVehicle = false;
                    component.set("v.disabledButton1", false);
                    component.set("v.disabledButton2", false);
                    component.set("v.disabledButton3", true);
                    component.set("v.textInfoStep3", 'O Veículo cadastrado está na fila. Aguarde o retorno da área de Gestão de Insumos.');
                }else if(profile == 'Gestão de Insumos'){
                    sectionStep3.semParar = false;
                    sectionStep3.standardization = false;
                    sectionStep3.dataSurvey = false;
                    sectionStep3.statusSurvey = false;
                    component.set("v.disabledButton1", true);
                    component.set("v.disabledButton2", true);
                    component.set("v.disabledButton3", false);
                    component.set("v.tipoModal", true);
                    component.set("v.disableFinanc", true);
                    component.set("v.textInfoStep1", 'Você não tem permissão para editar este veículo nesta fase, aguarde a área de Relacionamento ou finalize o cadastro.');
                    component.set("v.textInfoStep2", 'Você não tem permissão para editar este veículo nesta fase, aguarde a área de Relacionamento ou finalize o cadastro.');
                }else if(profile == 'Administrador do sistema'){
                    sectionStep2.ipva = false;
                    sectionStep2.provider = false;
                    sectionStep2.typeRegistration = false;
                    sectionStep2.phone = false;
                    sectionStep2.secondaryPhone = false;
                    sectionStep2.typeModal = false;
                    sectionStep2.financingDate = false;
                    sectionStep2.company = false;
                    sectionStep2.renavam = false;
                    sectionStep3.semParar = false;
                    sectionStep3.dataSurvey = false;
                    sectionStep3.statusSurvey = false;
                    sectionStep2.typeAcquisition = false;
                    sectionStep3.standardization = false;
                    sectionStep2.traffic = false;
                    sectionStep3.vehicleStatus = false;
                    sectionStep2.standardVehicle = false;
                    sectionStep2.nameOwner = false;
                    component.set("v.disabledButton1", false);
                    component.set("v.disabledButton2", false);
                    component.set("v.disabledButton3", false);
                    component.set("v.tipoModal", false);
                } else{
                    component.set("v.disabledStep1", true);
                    component.set("v.disabledStep2", true);
                    component.set("v.disabledStep3", true);
                    component.set("v.disabledButton1", true);
                    component.set("v.disabledButton2", true);
                    component.set("v.disabledButton3", true);
                }
                component.set("v.sectionDisabledStep2", sectionStep2);
                component.set("v.sectionDisabledStep3", sectionStep3);
                component.set("v.profile", profile);
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
                component.set("v.disabledStep1", true);
                component.set("v.disabledStep2", true);
                component.set("v.disabledStep3", true);
                component.set("v.disabledButton1", true);
                component.set("v.disabledButton2", true);
                component.set("v.disabledButton3", true);
            }
        });
        $A.enqueueAction(action);
    }, 
    finish : function(component, event, helper){
        var recordId = component.get("v.vehicleFields.Id");
        var orgDomain = $A.get("{!$Label.c.OrgDomain}");
        var url = orgDomain + "/" + recordId;

        window.location.href = url;
    }
})