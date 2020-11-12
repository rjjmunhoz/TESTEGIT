({
    onInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        if (myPageRef != null){    
            var cpf = myPageRef.state.c__cpf;
            component.set("v.cpf", cpf);
            component.set("v.resetStepWizard", true);
        }
    },     
    onRender : function(component, event, helper) {
        var cpf = component.get("v.cpf");
        if(cpf != null && cpf != "") {
            component.find("cpf_field").getElement().value = component.get("v.cpf");
        }        
    },      
    onSearchEmployee : function(component, event, helper) {
    	
        var cpf = component.get("v.cpf");
        cpf = cpf.replace(/[^\d]+/g,'');	
        if(cpf == ''|| cpf == undefined|| cpf.length != 11){
            helper.cpfError(component, event, helper);
            return;
        }	
		if (cpf == "00000000000" || cpf == "11111111111" || 
			cpf == "22222222222" || cpf == "33333333333" || 
			cpf == "44444444444" || cpf == "55555555555" || 
			cpf == "66666666666" || cpf == "77777777777" || 
    	    cpf == "88888888888" || cpf == "99999999999"){
            helper.cpfError(component, event, helper);
    	    return;	
    	}
		var add = 0;
        var rev = 0;
        var i = 0;
    	for (i=0; i < 9; i ++){	
			add += parseInt(cpf.charAt(i)) * (10 - i);	
        }
		rev = 11 - (add % 11);	
    	if (rev == 10 || rev == 11){
    	   rev = 0;
        }
    	if (rev != parseInt(cpf.charAt(9))){
           helper.cpfError(component, event, helper);
    	   return;
    	}					 		
			
		add = 0;	
    	for (i = 0; i < 10; i ++){
    	    add += parseInt(cpf.charAt(i)) * (11 - i);
    	}				
		rev = 11 - (add % 11);	
    	if (rev == 10 || rev == 11){
    	    rev = 0;
        }		
    	if (rev != parseInt(cpf.charAt(10))){
           	helper.cpfError(component, event, helper);
    	    return;
    	}
        console.log('CPF válido');
    	helper.doSearchEmployee(component, event, helper);
        
    },
    loadJquery: function (component, event, helper) {
        jQuery(document).ready(function () {
            $('.cpf_field').mask('999.999.999-99');
        });
    },
    handleCPF: function (component, event, helper) {
        var cpf = component.find("cpf_field").getElement().value;
        component.set("v.cpf", cpf);
    },
    selectStep1: function (component, event, helper) {
        component.set("v.selectedStep", 'step1');        
    },
    selectStep2: function (component, event, helper) {
        if(helper.ableToNextStep(component, 'step2')) {
            component.set("v.selectedStep", 'step2'); 
        }                    
    },
    selectStep3: function (component, event, helper) {
        if(helper.ableToNextStep(component, 'step3')) {
            component.set("v.selectedStep", 'step3'); 
        }              
    },
    handleNext: function (component, event, helper) {
        var step = component.get("v.selectedStep");
        var contact = component.get("v.contact");  
        if(step == 'step2') {      
            var hasError = false;   
            var isSalesforcePlatformUser = component.get("v.isSalesforcePlatformUser");
            if(isSalesforcePlatformUser && contact.AccountId == null) {
                hasError = true; 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Campos Obrigatórios(Prestador)",
                    "type": "info"
                });
                toastEvent.fire();
            }            
            var step2Cmp = component.find("step2CmpId");
            if(!hasError && step2Cmp.validateFieldsStepMethod()) {
                helper.doSaveContact(component, event, helper);
            }             
        }   
        else if(step == 'step3') {
            var step3Cmp = component.find("step3CmpId");
            var notHasFieldError = step3Cmp.validateFieldsStepMethod();
            if(notHasFieldError) {
                component.set("v.contact.Status__c", 'Ativo'); 
                helper.doSaveContact(component, event, helper);
            } 
        }   
    },
    redirectToRescuer: function (component, event, helper) {
        helper.redirectToRescuer(component, event, helper);
    },    
    onCloseWizard : function (component, event, helper) {
        helper.doCloseWizard(component, event, helper);
    },
    onOpenNotAllowedModal : function (component, event, helper) {
        helper.doOpenNotAllowedModal(component, event, helper);
    },
    onCloseNotAllowedModal : function (component, event, helper) {
        helper.doCloseNotAllowedModal(component, event, helper);
    },
    openCancelModal : function (component, event, helper) {
        helper.doOpenCancelModal(component, event, helper);
    },
    closeCancelModal : function (component, event, helper) {
        helper.doCloseCancelModal(component, event, helper);
    },
    cancelBaseEmployeesFlow: function (component, event, helper) {
        var contactFields = component.get("v.contact");
        contactFields.Status__c = 'Cancelado';
        contactFields.StepWizard__c = '2';
        component.set("v.contact",contactFields);
        helper.doSaveContact(component, event, helper);   
        helper.redirectToRescuer(component, event, helper);
    },
})