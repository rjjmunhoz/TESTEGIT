({
    onInit: function (component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        
        if (myPageRef != null) {
            var loadByUrl = myPageRef.state.c__loadByUrl;
            var personType = myPageRef.state.c__personType;
            console.log('loadByUrl ' + loadByUrl);
            if (loadByUrl == 'true') {
                if(personType == 'PJ'){
                var cnpj = myPageRef.state.c__cnpj;
                    component.set("v.cnpj", cnpj);
                    console.log('cnpj ' + cnpj);
                    helper.searchProvider(component, event, helper, cnpj);
                }
                else{
                    var cpf = myPageRef.state.c__cpf;
                    component.set("v.cpf", cpf);
                    helper.doSearchEmployee(component, event, helper, cpf);
                }
            }
        }
        helper.doInit(component, event, helper);
    },
    searchAccount: function (component, event, helper) {
        var personType = component.get("v.accountFields.LegalSituation__c");
        console.log('Tipo de Pessoa ' + personType);
        
        if(personType == 'PJ'){
        cnpj = component.get("v.cnpj");
        cnpj = cnpj.replace(/[^\d]+/g, '');

        if (cnpj == '' || cnpj.length != 14){
            helper.cnpjError(component, event, helper);
            return;
        } 
        if (cnpj == "00000000000000" || cnpj == "11111111111111" ||
            cnpj == "22222222222222" || cnpj == "33333333333333" ||
            cnpj == "44444444444444" || cnpj == "55555555555555" ||
            cnpj == "66666666666666" || cnpj == "77777777777777" ||
            cnpj == "88888888888888" || cnpj == "99999999999999"){
                helper.cnpjError(component, event, helper);
                return;
            }
        
        var tamanho = cnpj.length - 2;
        var numeros = cnpj.substring(0, tamanho);
        var digitos = cnpj.substring(tamanho);
        var soma = 0;
        var pos = tamanho - 7;
        var i = 0;
        for (i = tamanho; i >= 1; i--) {
            soma += numeros.charAt(tamanho - i) * pos--;
            if (pos < 2){
                pos = 9;
            }
        }
        var resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
        if (resultado != digitos.charAt(0)){
                helper.cnpjError(component, event, helper);
                return;
            }
        tamanho = tamanho + 1;
        numeros = cnpj.substring(0, tamanho);
        soma = 0;
        pos = tamanho - 7;
        for (i = tamanho; i >= 1; i--) {
            soma += numeros.charAt(tamanho - i) * pos--;
            if (pos < 2){
                pos = 9;
            }
        }
        resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
        if (resultado != digitos.charAt(1)){
                helper.cnpjError(component, event, helper);
                return;
            }
        console.log('CNPJ válido');
            helper.searchProvider(component, event, helper, cnpj);
        }
        else if(personType == 'PF'/* && 1+1 ==3*/){
            cpf = component.get("v.cpf");
            cpf = cpf.replace(/[^\d]+/g, '');
            console.log('cpf '+cpf);

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
        } else {
            component.set("v.selectedStep", "step4");
            component.set("v.cardSituation", "true");
        }
    },
    handleNext: function (component, event, helper) {
        var getselectedStep = component.get("v.selectedStep");
        var accountFields = component.get("v.accountFields");

        if (getselectedStep == "step2") {
            var cardSituation = component.get("v.cardSituation");

            if ((accountFields.Name == null || accountFields.CompanyName__c == null || accountFields.UpdateDate__c == null || accountFields.CardSituation__c == null) && accountFields.CompanyName__c == 'PJ') {
                accountFields.StepWizard__c = '3';
                helper.handleVisibility(component, event, helper);
                accountFields.StepWizard__c = '2';
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "duration": "20000",
                    "mode": "pester",
                    "title": "Não é possível prosseguir com o cadastro!",
                    "message": "Para que seja possível prosseguir com o cadastro desse Prestador, é necessário que a Receita Federal informe o nome, razão social, situação do cartão CNPJ e data de atualização. Por favor, entre em contato com um administrador do sistema.",
                    "type": "error"
                });
                toastEvent.fire();
            }
            else if (!cardSituation && accountFields.LegalSituation__c == 'PJ') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Atenção",
                    "message": "Não é possível prosseguir com o cadastro de um Prestador que seu Cartão CNPJ não esteja ativo. Por favor, cancele o fluxo.",
                    "type": "error"
                });
                toastEvent.fire();
            }
            
            if ((accountFields.Name == null || accountFields.UpdateDate__c == null || accountFields.CardSituation__c == null) && accountFields.CompanyName__c == 'PF') {
                accountFields.StepWizard__c = '3';
                helper.handleVisibility(component, event, helper);
                accountFields.StepWizard__c = '2';
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "duration": "20000",
                    "mode": "pester",
                    "title": "Não é possível prosseguir com o cadastro!",
                    "message": "Para que seja possível prosseguir com o cadastro desse Prestador, é necessário que a Receita Federal informe o nome, situação do CPF e data de atualização. Por favor, entre em contato com um administrador do sistema.",
                    "type": "error"
                });
                toastEvent.fire();
            }
            else if (!cardSituation && accountFields.LegalSituation__c == 'PF') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Atenção",
                    "message": "Não é possível prosseguir com o cadastro de um Prestador que seu CPF não esteja ativo. Por favor, cancele o fluxo.",
                    "type": "error"
                });
                toastEvent.fire();
            }
            
            else if (cardSituation) {
                var fieldsError = '';
                if (accountFields.ContractType__c == null || accountFields.ContractType__c == undefined || accountFields.ContractType__c == '') fieldsError = 'Tipo de Contrato' + '\n';
                if (accountFields.GroupCompanies__c == null || accountFields.GroupCompanies__c == undefined || accountFields.GroupCompanies__c == '') fieldsError += 'Empresas do grupo' + '\n';
                if (component.get("v.paymentTable") == false && (accountFields.PayTable__c == undefined || accountFields.PayTable__c == '') && accountFields.LegalSituation__c == 'PJ') fieldsError += 'Tabela Pagamento RE' + '\n';
                if (accountFields.ActuationType__c == null || accountFields.ActuationType__c == undefined || accountFields.ActuationType__c == '') fieldsError += 'Tipo de acionamento' + '\n';
                if ((accountFields.HaveParking__c == null || accountFields.HaveParking__c == undefined || accountFields.HaveParking__c == '') && accountFields.LegalSituation__c == 'PJ') fieldsError += 'Possui Patio?' + '\n';
                if ((accountFields.Attend24h__c == null || accountFields.Attend24h__c == undefined || accountFields.Attend24h__c == '') && accountFields.LegalSituation__c == 'PF') fieldsError += 'Atende 24h?' + '\n';
                if (accountFields.UseChart__c == null || accountFields.UseChart__c == undefined || accountFields.UseChart__c == '') fieldsError += 'Usa tabela' + '\n';
                if (accountFields.ScheduleType__c == null || accountFields.ScheduleType__c == undefined || accountFields.ScheduleType__c == '') fieldsError += 'Tipo de pagamento' + '\n';
                if (accountFields.ScheduleLink__c == null || accountFields.ScheduleLink__c == undefined || accountFields.ScheduleLink__c == '') fieldsError += 'Cronograma' + '\n';
                if (accountFields.ProviderType__c == null || accountFields.ProviderType__c == undefined || accountFields.ProviderType__c == '') fieldsError += 'Tipo de Prestador' + '\n';
                if (accountFields.OperationalPhone__c == null || accountFields.OperationalPhone__c == undefined || accountFields.OperationalPhone__c == '') fieldsError += 'Telefone da Base' + '\n';
                if (accountFields.Email__c == null || accountFields.Email__c == undefined || (!accountFields.Email__c.includes("@") || !accountFields.Email__c.includes(".com"))) fieldsError += 'Email' + '\n';
                if (accountFields.Analyst__c == null || accountFields.Analyst__c == undefined || accountFields.Analyst__c == '') fieldsError += 'Analista' + '\n';
                if ((accountFields.MunicipalRegistration__c == null || accountFields.MunicipalRegistration__c == undefined || accountFields.MunicipalRegistration__c == '') && accountFields.LegalSituation__c == 'PJ') fieldsError += 'Inscrição Municipal' + '\n';
                if ((accountFields.StateRegistration__c == null || accountFields.StateRegistration__c == undefined || accountFields.StateRegistration__c == '') && accountFields.LegalSituation__c == 'PJ') fieldsError += 'Inscrição Estadual' + '\n';
                if ((accountFields.OptingForSimple__c == null || accountFields.OptingForSimple__c == undefined || accountFields.OptingForSimple__c == '') && accountFields.LegalSituation__c == 'PJ') fieldsError += 'Optante pelo simples' + '\n';
                if (accountFields.PatrimonyLiquid__c == null || accountFields.PatrimonyLiquid__c == undefined || accountFields.PatrimonyLiquid__c == '') fieldsError += 'Patrimônio Líquido' + '\n';
                if ((accountFields.PIS_NIT__c == null || accountFields.PIS_NIT__c == undefined || accountFields.PIS_NIT__c == '') && accountFields.LegalSituation__c == 'PF') fieldsError += 'PIS/NIT' + '\n';
                if (accountFields.AnnualGrossRevenue__c == null || accountFields.AnnualGrossRevenue__c == undefined || accountFields.AnnualGrossRevenue__c == '') fieldsError += 'Receita Bruta Anual';
                console.log('component.get("v.paymentTable") ' + component.get("v.paymentTable"));
                console.log('fieldsError ' + fieldsError);

                if (fieldsError != '' && fieldsError != null) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Atenção",
                        "message": "Para proseguir com o cadastro, é necessário preencher todos os campos abaixo:" + '\n' + '\n' + fieldsError,
                        "type": "warning",
                        "duration": 10000
                    });
                    toastEvent.fire();
                }
                else {
                    if (accountFields.StepWizard__c == '1' || accountFields.StepWizard__c == '2' || accountFields.StepWizard__c == undefined) {
                        
                        accountFields.StepWizard__c = '3';
                        accountFields.RadarShippingDate__c = null;
                        accountFields.RadarReturnDate__c = null;
                        accountFields.RadarDescription__c = null;
                        accountFields.RisksStatus__c = null;
                        accountFields.ReturnDateRisks__c = null;
                        accountFields.ReanalisysReason__c = null;
                        accountFields.Status__c = 'Em implantação';
                        accountFields.ChangeInactive__c = false;
                        accountFields.StatusRadar__c = 'Aguardando Radar';
                        component.set("v.radarStatus", accountFields.StatusRadar__c);
                        component.set("v.accountFields", accountFields);

                        // helper.updateProvider(component, event, helper);
                        // console.log('Aguardando radar updated');
                        component.set("v.loading", true);
                        var action = component.get('c.updateAccount');
                        action.setParams({ aProviderJson: JSON.stringify(accountFields) });
                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state == "SUCCESS") {
                                console.log('updated succefully');
                                helper.handleVisibility(component, event, helper);
                                component.set("v.selectedStep", "step3");
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
                                        accountFields.StepWizard__c = '2';
                                    }
                                }
                            }
                            component.set("v.loading", false);
                        });
                        $A.enqueueAction(action);
                    }
                }
            }

        }
        else if (getselectedStep == "step3") {
            if (accountFields.StepWizard__c != '4') {
                accountFields.StepWizard__c = '4';

                // helper.getPartners(component, event, helper);         
            }
            component.set("v.accountFields", accountFields);
            helper.updateProvider(component, event, helper);
            component.set("v.selectedStep", "step4");
            // component.set("v.disabledReanalisys", true); 
            helper.handleVisibility(component, event, helper);
        }
    },
    handleClose: function (component, event, helper) {
        var orgDomain = $A.get("{!$Label.c.OrgDomain}");
        var url = orgDomain + "/001";
        window.location.href = url;       
    },

    finish: function (component, event, helper) {
        var accountFields = component.get("v.accountFields");
        var deliveryAdress = component.get("v.deliveryAdress");
        var taxAdress = component.get("v.taxAdress");
        var partners = component.get("v.partners");

        console.log('1');
		console.log('taxAdress ' + taxAdress);
        console.log('delivery '+ deliveryAdress);
        // valida endereço operacional       
        var operationalAddressError = '';
        if (accountFields.OperationalNeighborhood__c == null || accountFields.OperationalNeighborhood__c == undefined || accountFields.OperationalNeighborhood__c == '') operationalAddressError = 'Bairro' + '\n';
        if (accountFields.OperationalCity__c == null || accountFields.OperationalCity__c == undefined || accountFields.OperationalCity__c == '') operationalAddressError += 'Cidade' + '\n';
        if (accountFields.OperationalStreet__c == null || accountFields.OperationalStreet__c == undefined || accountFields.OperationalStreet__c == '') operationalAddressError = 'Logradouro' + '\n';
        if (accountFields.OperationalZip__c == null || accountFields.OperationalZip__c == undefined || accountFields.OperationalZip__c == '') operationalAddressError += 'CEP' + '\n';
        if (accountFields.OperationalPublicPlace__c == null || accountFields.OperationalPublicPlace__c == undefined || accountFields.OperationalPublicPlace__c == '') operationalAddressError += 'Tipo Logradouro' + '\n';
        if (accountFields.OperationalNumber__c == null || accountFields.OperationalNumber__c == undefined || accountFields.OperationalNumber__c == '') operationalAddressError += 'Número' + '\n';
        if (accountFields.OperationalUfPickList__c == null || accountFields.OperationalUfPickList__c == undefined || accountFields.OperationalUfPickList__c == '') operationalAddressError += 'UF' + '\n';
        if (operationalAddressError != '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Atenção",
                "message": "Preencha todos os campos do Endereço Operacional:" + '\n' + '\n' + operationalAddressError,
                "type": "error",
                "duration": 10000
            });
            toastEvent.fire();
            return;
        }

        var deliveryAddressError = '';
        if ((accountFields.DeliveryStreet__c == null || accountFields.DeliveryStreet__c == undefined || accountFields.DeliveryStreet__c == '') && accountFields.LegalSituation__c == 'PJ') deliveryAddressError = 'Logradouro' + '\n';
        if ((accountFields.DeliveryPublicPlace__c == null || accountFields.DeliveryPublicPlace__c == undefined || accountFields.DeliveryPublicPlace__c == '') && accountFields.LegalSituation__c == 'PJ') deliveryAddressError += 'Tipo Logradouro' + '\n';
        if ((accountFields.DeliveryNeighborhood__c == null || accountFields.DeliveryNeighborhood__c == undefined || accountFields.DeliveryNeighborhood__c == '') && accountFields.LegalSituation__c == 'PJ') deliveryAddressError = 'Bairro' + '\n';
        if ((accountFields.DeliveryNumber__c == null || accountFields.DeliveryNumber__c == undefined || accountFields.DeliveryNumber__c == '') && accountFields.LegalSituation__c == 'PJ') deliveryAddressError += 'Número' + '\n';
        if ((accountFields.DeliveryZip__c == null || accountFields.DeliveryZip__c == undefined || accountFields.DeliveryZip__c == '') && accountFields.LegalSituation__c == 'PJ') deliveryAddressError += 'CEP' + '\n';
        if ((accountFields.DeliveryCity__c == null || accountFields.DeliveryCity__c == undefined || accountFields.DeliveryCity__c == '') && accountFields.LegalSituation__c == 'PJ') deliveryAddressError += 'Cidade' + '\n';
        if ((accountFields.DeliveryUf__c == null || accountFields.DeliveryUf__c == undefined || accountFields.DeliveryUf__c == '') && accountFields.LegalSituation__c == 'PJ') operationalAddressError += 'UF' + '\n';

        if (deliveryAdress == false && deliveryAddressError != '') {

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Atenção",
                "message": "Preencha todos os campos do Endereço de Entrega:" + '\n' + '\n' + deliveryAddressError,
                "type": "error",
                "duration": 10000
            });
            toastEvent.fire();
            return;
        }
        else if (deliveryAdress == true && accountFields.LegalSituation__c == 'PJ') {
            accountFields.DeliveryPublicPlace__c = accountFields.OperationalPublicPlace__c;
            accountFields.DeliveryNeighborhood__c = accountFields.OperationalNeighborhood__c;
            accountFields.DeliveryComplement__c = accountFields.OperationalComplement__c;
            accountFields.DeliveryNumber__c = accountFields.OperationalNumber__c;
            accountFields.DeliveryZip__c = accountFields.OperationalZip__c;
            accountFields.DeliveryCity__c = accountFields.OperationalCity__c;
            accountFields.DeliveryUf__c = accountFields.OperationalUfPickList__c;
            accountFields.DeliveryStreet__c = accountFields.OperationalStreet__c;
        }
        
         var taxAddressError = '';
        if ((accountFields.TaxStreet__c == null || accountFields.TaxStreet__c == undefined || accountFields.TaxStreet__c == '') && accountFields.LegalSituation__c == 'PF') taxAddressError = 'Logradouro' + '\n';
        if ((accountFields.TaxPublicPlace__c == null || accountFields.TaxPublicPlace__c == undefined || accountFields.TaxPublicPlace__c == '') && accountFields.LegalSituation__c == 'PF') taxAddressError += 'Tipo Logradouro' + '\n';
        if ((accountFields.TaxNeighbourhood__c == null || accountFields.TaxNeighbourhood__c == undefined || accountFields.TaxNeighbourhood__c == '') && accountFields.LegalSituation__c == 'PF') taxAddressError = 'Bairro' + '\n';
        if ((accountFields.TaxNumber__c == null || accountFields.TaxNumber__c == undefined || accountFields.TaxNumber__c == '') && accountFields.LegalSituation__c == 'PF') taxAddressError += 'Número' + '\n';
        if ((accountFields.TaxZip__c == null || accountFields.TaxZip__c == undefined || accountFields.TaxZip__c == '') && accountFields.LegalSituation__c == 'PF') taxAddressError += 'CEP' + '\n';
        if ((accountFields.TaxCity__c == null || accountFields.TaxCity__c == undefined || accountFields.TaxCity__c == '') && accountFields.LegalSituation__c == 'PF') taxAddressError += 'Cidade' + '\n';
        if ((accountFields.TaxUf__c == null || accountFields.TaxUf__c == undefined || accountFields.TaxUf__c == '') && accountFields.LegalSituation__c == 'PF') taxAddressError += 'UF' + '\n';

        if (taxAdress == false && taxAddressError != '') {

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Atenção",
                "message": "Preencha todos os campos do Endereço Fiscal:" + '\n' + '\n' + taxAddressError,
                "type": "error",
                "duration": 10000
            });
            toastEvent.fire();
            return;
        }
        else if (taxAdress == true && accountFields.LegalSituation__c == 'PF') {
            accountFields.TaxPublicPlace__c = accountFields.OperationalPublicPlace__c;
            accountFields.TaxNeighbourhood__c = accountFields.OperationalNeighborhood__c;
            accountFields.TaxComplement__c = accountFields.OperationalComplement__c;
            accountFields.TaxNumber__c = accountFields.OperationalNumber__c;
            accountFields.TaxZip__c = accountFields.OperationalZip__c;
            accountFields.TaxCity__c = accountFields.OperationalCity__c;
            accountFields.TaxUf__c = accountFields.OperationalUfPickList__c;
            accountFields.TaxStreet__c = accountFields.OperationalStreet__c;   
        }
        // valida conta bancária
        var bankError = '';
        if ((accountFields.BankAccountType__c == null || accountFields.BankAccountType__c == undefined || accountFields.BankAccountType__c == '') && accountFields.LegalSituation__c == 'PF') bankError = 'Tipo de conta' + '\n';
        if (accountFields.BankName__c == null || accountFields.BankName__c == undefined || accountFields.BankName__c == '') bankError += 'Nome do Banco' + '\n';
        if (accountFields.Branch__c == null || accountFields.Branch__c == undefined || accountFields.Branch__c == '') bankError += 'Agência' + '\n';
        if (accountFields.CurrentAccountDigit__c == null || accountFields.CurrentAccountDigit__c == undefined || accountFields.CurrentAccountDigit__c == '') bankError += 'Dígito da Conta' + '\n';
        if (accountFields.CheckingAccount__c == null || accountFields.CheckingAccount__c == undefined || accountFields.CheckingAccount__c == '') bankError += 'Conta' + '\n';
        
        console.log('Tipo de conta '+ accountFields.BankAccountType__c);


        if (bankError != '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Atenção",
                "message": "Preencha todos os campos de informação bancária." + '\n' + '\n' + bankError,
                "type": "error",
                "duration": 10000
            });
            toastEvent.fire();
            return;
        }

        // valida campos dos sócios
        var i;
        for (i = 0; i < partners.length; i++) {
            if (partners[i].PEP__c == null || partners[i].PEP__c == '' || partners[i].PEP__c == undefined) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Atenção",
                    "message": "Preencha o campo PEP para todos os Sócios.",
                    "type": "error"
                });
                toastEvent.fire();
                return;
            }
        }
        
        for (i = 0; i < partners.length; i++) {
            if (partners[i].Email == null || partners[i].Email == '' || partners[i].Email == undefined) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Atenção",
                    "message": "Preencha o campo Email para todos os Sócios.",
                    "type": "error"
                });
                toastEvent.fire();
                return;
            }
        }

        helper.savePartners(component, event, helper);
        // accountFields.Status__c = 'Em implantação';
        accountFields.StepWizard__c = '1';
        accountFields.Synced__c = true;
        accountFields.EffectiveDate__c = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        console.log('accountFields.EffectiveDate__c ' + accountFields.EffectiveDate__c);
        component.set("v.accountFields", accountFields);
        var json = component.get('v.accountFields');
        console.log('json ' + JSON.stringify(json));
        // helper.updateProvider(component, event, helper);

        component.set("v.loading", true);
        var accountFields = component.get("v.accountFields");
        var action = component.get('c.updateAccount');
        action.setParams({ aProviderJson: JSON.stringify(accountFields) });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                console.log('updated succefully');
                helper.redirectToProvider(component, event, helper);
                console.log('####DONE!!!');
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
    selectStep1: function (component, event, helper) {
        var accountFields = component.get("v.accountFields");
        if (accountFields.StepWizard__c == '2' || accountFields.StepWizard__c == '3' || accountFields.StepWizard__c == '4' || accountFields.StepWizard__c == '5') {
            helper.updateProvider(component, event, helper);
            component.set("v.selectedStep", "step1");
        }
    },
    selectStep2: function (component, event, helper) {
        var accountFields = component.get("v.accountFields");
        if (accountFields.StepWizard__c == '2' || accountFields.StepWizard__c == '3' || accountFields.StepWizard__c == '4' || accountFields.StepWizard__c == '5') {
            helper.updateProvider(component, event, helper);
            component.set("v.selectedStep", "step2");
        }
    },
    selectStep3: function (component, event, helper) {
        var accountFields = component.get("v.accountFields");
        if (accountFields.StepWizard__c == '3' || accountFields.StepWizard__c == '4' || accountFields.StepWizard__c == '5') {
            helper.handleVisibility(component, event, helper);
            helper.updateProvider(component, event, helper);
            component.set("v.selectedStep", "step3");
        }
    },
    selectStep4: function (component, event, helper) {
        var accountFields = component.get("v.accountFields");
        if (accountFields.StepWizard__c == '4' || accountFields.StepWizard__c == '5') {
            helper.updateProvider(component, event, helper);
            component.set("v.selectedStep", "step4");
        }
    },
    selectStep5: function (component, event, helper) {
        var accountFields = component.get("v.accountFields");
        if (accountFields.StepWizard__c == '5') {
            helper.updateProvider(component, event, helper);
            component.set("v.selectedStep", "step5");
        }
    },
    openCancelModal: function (component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    closeCancelModal: function (component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    closeNotAllowedModal: function (component, event, helper) {
        var cmpTarget = component.find('NotAllowed');
        var cmpBack = component.find('ModalNotAllowed');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    cancelProviderFlow: function (component, event, helper) {
        var accountFields = component.get("v.accountFields");
        accountFields.Status__c = 'Inativo';
        accountFields.StepWizard__c = '1';
        component.set("v.accountFields", accountFields);
        helper.updateProvider(component, event, helper);
        helper.redirectToProvider(component, event, helper);
    },
    redirectToProvider: function (component, event, helper) {
        helper.redirectToProvider(component, event, helper);
    },
    updateProvider: function (component, event, helper) {
        helper.updateProvider(component, event, helper);
    },
    approvalProcess: function (component, event, helper) {
        var accountFields = component.get("v.accountFields");
        if (accountFields.ReanalisysReason__c == null || accountFields.ReanalisysReason__c == undefined || accountFields.ReanalisysReason__c == '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Atenção",
                "message": "Preencha o campo 'Justificativa da Reanálise' para enviar o cadastro para reanálise.",
                "type": "warning"
            });
            toastEvent.fire();
        }
        else if (accountFields.StatusRadar__c != 'Aguardando Radar') {
            component.set("v.loading", true);

            var insideAction = component.get('c.submitApprovalRequest');
            insideAction.setParams({ 'aAccountId': accountFields.Id, 'aCommentaries': accountFields.ReanalisysReason__c, aProviderJson: JSON.stringify(accountFields) });
            insideAction.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    component.set("v.disableTypeReanalysisReason", true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Sucesso",
                        "message": "Prestador enviado para reanálise com sucesso. Aguarde o retorno da área de Gestão de Custos e Riscos.",
                        "type": "success"
                    });
                    toastEvent.fire();
                    component.set("v.disabledReanalisys", true);
                    // component.set("v.renderReanalyStatus", true);
                    accountFields.RisksStatus__c = 'Aguardando Gestão de Custos e Riscos';
                    component.set("v.accountFields", accountFields);
                    component.set("v.renderReanalyStatus", false);
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
            $A.enqueueAction(insideAction);
        }
    },
    integrationPartners: function (component, event, helper) {

        component.set("v.loading", true);
        cnpj = component.get("v.cnpj");

        var action = component.get('c.calloutPartners');
        action.setParams({
            'aCnpj': cnpj
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                if (response.getReturnValue() != null) {
                    var partners = response.getReturnValue();
                    component.set("v.partners", partners);
                    console.log('Partners Records ' + JSON.stringify(response.getReturnValue()));
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Erro",
                        "message": "Nenhum sócio localizado. Entre em contato com o administrador do sistema para mais informações.",
                        "type": "error"
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

    redirectTest: function (component, event, helper) {
        helper.redirectToProvider(component, event, helper);
    }
})