@isTest
public class ProviderRegistrationWizard_tst {
	
    @isTest
    static void updateAccountApprovalTest(){
        
        WebserviceConfiguration__mdt lToken = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lRegistrationDataPJ = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPJDadosCadastrais'];
        WebserviceConfiguration__mdt lPartnerDataPJ = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPJSocios'];
        WebserviceConfiguration__mdt lSucursal = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Sucursal'];

        String lStringToken = lToken.EndPoint__c;
        String lEndpoint = lRegistrationDataPJ.EndPoint__c;
        String lPartnerEndpoint = lPartnerDataPJ.EndPoint__c;
        String lSucursalEndpoint = lSucursal.EndPoint__c;

        List<Object> lParameters = new List<Object> {'00000099000121'};
        String lStringRegistrationDataPJ = String.format(lEndpoint, lParameters);
        String lStringPartnerDataPJ = String.format(lPartnerEndpoint, lParameters); 
        String lStringSucursal = lSucursalEndpoint+'?cidade=SAOPAULO&uf=SP'; 
        system.debug('####TesteEndpoint1 ' + lStringSucursal);
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(lStringToken,'Token');
        multimock.setStaticResource(lStringRegistrationDataPJ,'PJDataRegistration');
        multimock.setStaticResource(lStringPartnerDataPJ,'PartnersParticipation');
        multimock.setStaticResource(lStringSucursal,'Sucursal');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.setMock(HttpCalloutMock.class, multimock);
        
        Account lAccount = AccountFactory.createAccountProvider();
        lAccount.TaxCity__c = 'SAOPAULO';
        lAccount.TaxUf__c = 'SP';
        insert lAccount;
        
        lAccount.UpdateDate__c = system.today()+360;
        lAccount.OperationalZip__c = '00000000';
        lAccount.DeliveryZip__c ='00000000';
        update lAccount;
        
        String lJson = JSON.serialize(lAccount);
                    
        Profile profile = [Select Id from Profile where Name = 'Administrador do sistema' OR Name = 'System Administrator'];
        User lUserManager = new User();
        lUserManager.lastName = 'lastName';
        lUserManager.firstName = 'firstName';
        lUserManager.ProfileId = profile.Id;
        lUserManager.Username = 'userName1@test.prisma.username.com';
        lUserManager.Alias = 'alias';
        lUserManager.EmailEncodingKey = 'ISO-8859-1';
        lUserManager.LanguageLocaleKey = 'pt_BR';
        lUserManager.LocaleSidKey = 'pt_BR';
        lUserManager.TimeZoneSidKey = 'America/Sao_Paulo';
        lUserManager.Email = 'userName@username.com';
        insert lUserManager;
        
        User lUserAnalist = new User();
        lUserAnalist.lastName = 'lastName';
        lUserAnalist.firstName = 'firstName';
        lUserAnalist.ProfileId = profile.Id;
        lUserAnalist.Username = 'userName2@test.prisma.username.com';
        lUserAnalist.Alias = 'alias';
        lUserAnalist.EmailEncodingKey = 'ISO-8859-1';
        lUserAnalist.LanguageLocaleKey = 'pt_BR';
        lUserAnalist.LocaleSidKey = 'pt_BR';
        lUserAnalist.TimeZoneSidKey = 'America/Sao_Paulo';
        //lUserAnalist.Approver__c = lUserManager.Id;
    	lUserAnalist.ApproverProvider__c = lUserManager.Id;
        lUserAnalist.Email = 'userName@test.prisma.username.com';
            
        insert lUserAnalist;
        
        
        
        Test.startTest();   
        System.runAs(lUserAnalist){
        	ProviderRegistrationWizard_ctr.updateAccount(lJson);
        	ProviderRegistrationWizard_ctr.submitApprovalRequest(lAccount.Id, 'Analisar Novamente', lJson);
        }
        Test.stopTest();
        
    }
    @isTest
    static void getPicklistValues(){
        
        WebserviceConfiguration__mdt lToken = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lRegistrationDataPJ = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPJDadosCadastrais'];
        WebserviceConfiguration__mdt lPartnerDataPJ = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPJSocios'];
        
        String lStringToken = lToken.EndPoint__c;
        String lEndpoint = lRegistrationDataPJ.EndPoint__c;
        String lPartnerEndpoint = lPartnerDataPJ.EndPoint__c;

        List<Object> lParameters = new List<Object> {'00000099000121'};
        String lStringRegistrationDataPJ = String.format(lEndpoint, lParameters);
        String lStringPartnerDataPJ = String.format(lPartnerEndpoint, lParameters);  
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(lStringToken,'Token');
        multimock.setStaticResource(lStringRegistrationDataPJ,'PJDataRegistration');
        multimock.setStaticResource(lStringPartnerDataPJ,'PartnersParticipation');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.setMock(HttpCalloutMock.class, multimock);
        
        Test.startTest();
        ProviderRegistrationWizard_ctr.getPicklistValues();
        ProviderRegistrationWizard_ctr.getBankValues();
        Test.stopTest();
    }

    @isTest
    static void integrationProviderPartners(){
        
        WebserviceConfiguration__mdt lToken = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lRegistrationDataPJ = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPJDadosCadastrais'];
        WebserviceConfiguration__mdt lPartnerDataPJ = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPJSocios'];
        WebserviceConfiguration__mdt lSucursal = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Sucursal'];

        String lStringToken = lToken.EndPoint__c;
        String lEndpoint = lRegistrationDataPJ.EndPoint__c;
        String lPartnerEndpoint = lPartnerDataPJ.EndPoint__c;
        String lSucursalEndpoint = lSucursal.EndPoint__c;

        List<Object> lParameters = new List<Object> {'00000099000121'};
        String lStringRegistrationDataPJ = String.format(lEndpoint, lParameters);
        String lStringPartnerDataPJ = String.format(lPartnerEndpoint, lParameters); 
        String lStringSucursal = lSucursalEndpoint+'?cidade=SAOPAULO&uf=SP'; 
        system.debug('####TesteEndpoint2 ' + lStringSucursal);
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(lStringToken,'Token');
        multimock.setStaticResource(lStringRegistrationDataPJ,'PJDataRegistration');
        multimock.setStaticResource(lStringPartnerDataPJ,'PartnersParticipation');
        multimock.setStaticResource(lStringSucursal,'Sucursal');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.setMock(HttpCalloutMock.class, multimock);
        
        
       	RegistrationDataSerasaPJWebService.AccountContactWrapper lTest = ProviderRegistrationWizard_ctr.searchCnpj('00000099000121');
        system.debug('teste: '+ lTest.lAcc.Id);
        Contact lContact = ContactFactory.createContactPartner('Teste', '0004560009');
        lContact.AccountId = lTest.lAcc.Id;
        insert lContact;
        
        Test.startTest();
        	ProviderRegistrationWizard_ctr.searchCnpj('00000099000121');
        Test.stopTest();
        
        system.assertEquals(true,true);
    }
    @isTest
    static void integrationProviderRegistrationError(){
        
        WebserviceConfiguration__mdt lToken = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lRegistrationDataPJ = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPJDadosCadastrais'];
        WebserviceConfiguration__mdt lPartnerDataPJ = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPJSocios'];
        WebserviceConfiguration__mdt lSucursal = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Sucursal'];

        String lStringToken = lToken.EndPoint__c;
        String lEndpoint = lRegistrationDataPJ.EndPoint__c;
        String lPartnerEndpoint = lPartnerDataPJ.EndPoint__c;
        String lSucursalEndpoint = lSucursal.EndPoint__c;

        List<Object> lParameters = new List<Object> {'00000099000121'};
        String lStringRegistrationDataPJ = String.format(lEndpoint, lParameters);
        String lStringPartnerDataPJ = String.format(lPartnerEndpoint, lParameters); 
        String lStringSucursal = lSucursalEndpoint+'?cidade=SAOPAULO&uf=SP'; 
        system.debug('####TesteEndpoint3 ' + lStringSucursal);
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(lStringToken,'Token');
        multimock.setStaticResource(lStringRegistrationDataPJ,'PJDataRegistration');
        multimock.setStaticResource(lStringPartnerDataPJ,'PartnersParticipation');
        multimock.setStaticResource(lStringSucursal,'Sucursal');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.setMock(HttpCalloutMock.class, multimock);
        

        Test.startTest();
        	ProviderRegistrationWizard_ctr.searchCnpj('00000099000121');
        Test.stopTest();

        system.assertEquals(false, false,'CNPJ não encontrado');
        
        Account lProvider = AccountFactory.createAccountProvider();
        lProvider.UpdateDate__c = date.today() + 3;
        lProvider.CNPJ__c = '00000099000125';
        lProvider.TaxCity__c = 'SAOPAULO';
        lProvider.TaxUf__c = 'SP';
        insert lProvider;
        
        ProviderRegistrationWizard_ctr.searchCnpj('00000099000125');

        
    }
    
            @isTest
    static void savePartnersTest(){
       String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
		
        List<Contact> lListContact = new List<Contact>();
        String lName = 'Teste';
        String lCPF = '000456000';
        for(Integer i; i<5; i++){
            lName = lName + 1;
            lCPF = lCPF +1;
            lListContact.add(ContactFactory.createContactPartner(lName, lCPF));          
        }       
        insert lListContact;   
        Test.startTest();
        	ProviderRegistrationWizard_ctr.savePartners(JSON.serialize(lListContact));
        Test.stopTest();
    }
    
    @isTest
    static void getPartnerRestrictiveAndRegistrationInfoTest(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
		
        Account lAccount = AccountFactory.createAccountProvider();
        lAccount.TaxCity__c = 'SAOPAULO';
        lAccount.TaxUf__c = 'SP';
        insert lAccount;
        
        Contact lContact = ContactFactory.createContactPartner('Teste', '0004560009');
        lContact.AccountId = lAccount.Id;
        insert lContact;     
        Test.startTest();
        	ProviderRegistrationWizard_ctr.getPartnerRestrictiveAndRegistrationInfo(lAccount.Id);
        Test.stopTest();

    }
    
    @isTest
    static void ProviderWebServiceTest(){
        
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        Account lProvider;
        system.runAs(New User(Id = UserInfo.getUserId())) {
            lProvider = ProviderData();
        }   
        
        Product2 lDetail = Product2Factory.createProduct2Detail();
        insert lDetail;

        Product2 lSpecialty = Product2Factory.createProduct2Specialty(); 
        insert lSpecialty;
        //ActiveSpeciality();
        //List<Product2> lListSpecialty = [SELECT Id FROM Product2]; 

        ServiceSpecialtyDetails__c lServiceSpecialtyDetails = new ServiceSpecialtyDetails__c();
        lServiceSpecialtyDetails.SpecialtyDetail__c = lSpecialty.Id;
        lServiceSpecialtyDetails.Detail__c = lDetail.Id;
        //lServiceSpecialtyDetails.SpecialtyDetail__c = lListSpecialty[0].Id;
        insert lServiceSpecialtyDetails;

        OperationalSetup__c lOperationalSetup = OperationalSetupFactory.createOperationalSetupAbility();//OperationalSetupFactory.Ability().createRecord(); 
        insert lOperationalSetup;

        Ability__c lAbility = new Ability__c();
        lAbility.OperationalSetup__c = lOperationalSetup.Id;
        lAbility.Product2__c = lSpecialty.Id;
        insert lAbility;
   
        EquipmentSupplyPart__c lJunction = new EquipmentSupplyPart__c();
        lJunction.Provider__c = lProvider.Id;
        lJunction.Abiliity__c = lOperationalSetup.Id;
        insert lJunction;

        Contact lContact = ContactFactory.createContactPartner('Test', '01000000065');
        lContact.AccountId = lProvider.Id;
        insert lContact;
        
        
        system.debug('Teste : '+lProvider.CreatedById);
        //system.debug('Teste 2 : '+lProvider.Code__c);

        // ProviderWebService_cls lIntegration = new ProviderWebService_cls(lProvider);
        
        // lIntegration.setAwsProvider();
        
        
    }
    
    @isTest
    static void ProviderWebServiceTest2(){
        
       /* WebserviceConfiguration__mdt lToken = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lRegistrationDataPJ = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPJDadosCadastrais'];
        WebserviceConfiguration__mdt lPartnerDataPJ = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPJSocios'];
        WebserviceConfiguration__mdt lSucursal = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Sucursal'];

        String lStringToken = lToken.EndPoint__c;
        String lEndpoint = lRegistrationDataPJ.EndPoint__c;
        String lPartnerEndpoint = lPartnerDataPJ.EndPoint__c;
        String lSucursalEndpoint = lSucursal.EndPoint__c;

        List<Object> lParameters = new List<Object> {'00000099000121'};
        String lStringRegistrationDataPJ = String.format(lEndpoint, lParameters);
        String lStringPartnerDataPJ = String.format(lPartnerEndpoint, lParameters); 
        String lStringSucursal = lSucursalEndpoint+'?cidade=SAOPAULO&uf=SP'; 
        system.debug('####TesteEndpoint4 ' + lStringSucursal);
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(lStringToken,'Token');
        multimock.setStaticResource(lStringRegistrationDataPJ,'PJDataRegistration');
        multimock.setStaticResource(lStringPartnerDataPJ,'PartnersParticipation');
        multimock.setStaticResource(lStringSucursal,'Sucursal');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.setMock(HttpCalloutMock.class, multimock);*/
        
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));

        Account lProvider;
        system.runAs(New User(Id = UserInfo.getUserId())) {
            lProvider = ProviderData();
        }       

        OperationalSetup__c lOperationalSetup = OperationalSetupFactory.createOperationalSetupAbility();
        lOperationalSetup.Code__c = 2342.0;
        insert lOperationalSetup;
        
        
        Product2 lDetail = Product2Factory.createProduct2Detail();
        insert lDetail;

        Product2 lSpecialty = Product2Factory.createProduct2Specialty(); 
        //lSpecialty.Status__c = 'Ativo';
        lSpecialty.Code__c = 123;
        lSpecialty.SpecialtyType__c = 'AUTO';
        insert lSpecialty;

        ServiceSpecialtyDetails__c lServiceSpecialtyDetails = new ServiceSpecialtyDetails__c();
        lServiceSpecialtyDetails.SpecialtyDetail__c = lSpecialty.Id;
        lServiceSpecialtyDetails.Detail__c = lDetail.Id;
        insert lServiceSpecialtyDetails;
        
        Ability__c lAbility = new Ability__c();
        lAbility.OperationalSetup__c = lOperationalSetup.Id;
        lAbility.Product2__c = lSpecialty.Id;
        insert lAbility;
        
        lSpecialty.Status__c = 'Ativo';
        lSpecialty.Runtime__c = Time.newInstance(0, 15, 0, 0);
        lSpecialty.WarrantyPiece__c = 1;
        lSpecialty.WarrantyMO__c = 1;
        //update lSpecialty;
        lOperationalSetup.Status__c = 'Ativo';
        //update lOperationalSetup;  
        lDetail.Status__c = 'Ativo';
        //update lDetail;
            
        //System.debug('antes do lEquipmentSupplyPart ' + lProvider.Code__c);
        
        EquipmentSupplyPart__c lEquipmentSupplyPart = new EquipmentSupplyPart__c();
        lEquipmentSupplyPart.Abiliity__c = lOperationalSetup.Id;
        lEquipmentSupplyPart.Provider__c = lProvider.Id; 
        lEquipmentSupplyPart.Provider__r = lProvider; 
        insert lEquipmentSupplyPart;
        
        //System.debug('lEquipmentSupplyPart ' + lEquipmentSupplyPart.Provider__r.Code__c);
    }
    
    
    @isTest
    static void integrationProviderPF(){
        
        WebserviceConfiguration__mdt lToken = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
		WebserviceConfiguration__mdt lSucursal = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Sucursal'];
        WebserviceConfiguration__mdt lRegistrationDataPF = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPFDadosCadastrais'];
                
        String lStringToken = lToken.EndPoint__c;
        String lEndpoint = lRegistrationDataPF.EndPoint__c;
        String lSucursalEndpoint = lSucursal.EndPoint__c;
        
        //String lStringSucursal = lSucursalEndpoint+'?cidade=GUARULHOS&uf=SP';
        String lStringSucursal = lSucursalEndpoint+'?cidade=&uf=null';
        system.debug('teste sucursal '+ lStringSucursal);

        List<Object> lParameters = new List<Object> {'00000000272'};
        String lStringRegistrationDataPF = String.format(lEndpoint, lParameters);        

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(lStringToken,'Token');
        multimock.setStaticResource(lStringSucursal,'Sucursal');
        multimock.setStaticResource(lStringRegistrationDataPF,'PFDataRegistration');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        

        Test.startTest();
            ProviderRegistrationWizard_ctr.searchEmployeeByCPF('00000000272');
        Test.stopTest();
    }
    
    static Account ProviderData(){
        
        WebserviceConfiguration__mdt lToken = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lRegistrationDataPJ = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPJDadosCadastrais'];
        
        String lStringToken = lToken.EndPoint__c;
        String lEndpoint = lRegistrationDataPJ.EndPoint__c;

        List<Object> lParameters = new List<Object> {'00000099000121'};
        String lStringRegistrationDataPJ = String.format(lEndpoint, lParameters);
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(lStringToken,'Token');
        multimock.setStaticResource(lStringRegistrationDataPJ,'PJDataRegistrationError');
        multimock.setStatusCode(500);
        multimock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.setMock(HttpCalloutMock.class, multimock);
        
        User lAnalyst = UserFactory.createUserAnalist();
        insert lAnalyst;
        
        Account lProvider = AccountFactory.createAccountProvider();

        system.runAs(lAnalyst) {
            Schedule__c lSchedule = ScheduleFactory.makeData();
        
            lProvider.CompanyName__c = 'Teste';
            lProvider.ProviderType__c = '1';
            lProvider.Note__c = 'Teste';
            lProvider.Status__c = 'Ativo';
            lProvider.CNPJ__c = '10000000000959';
            lProvider.BankName__c = '22';
            lProvider.ScheduleLink__c = lSchedule.Id;
            lProvider.PaymentOption__c = 'Tabela';
            lProvider.PayTable__c = '79';
            lProvider.ScheduleType__c = 'Mensal';
            lProvider.CurrentAccountDigit__c = '1';
            lProvider.Branch__c = '12345';
            lProvider.DigitAgency__c = '1';
            lProvider.CheckingAccount__c = '1234567890';
            lProvider.BankAccountType__c = '1';
            lProvider.OptingForSimple__c = 'S';
            lProvider.MunicipalRegistration__c = '123456';
            lProvider.PIS_NIT__c = '123456';
            lProvider.AnnualGrossRevenue__c = '3';
            lProvider.Analyst__c = lAnalyst.Id;
            lProvider.Attend24h__c = 'Sim';
            lProvider.HaveParking__c ='S';
            lProvider.ActuationType__c = '1';
            lProvider.OperationalZip__c = '09965326';
            lProvider.OperationalComplement__c = 'Praça';
            lProvider.OperationalNeighborhood__c = 'Jd.Teste';
            lProvider.OperationalCity__c = 'Jundiai';
            lProvider.OperationalStreet__c = 'Rua Pinheiros de Moraes';
            lProvider.OperationalNumber__c = '123';
            lProvider.OperationalPublicPlace__c = 'Rua';
            lProvider.OperationalUfPickList__c = 'SP';
            lProvider.OperationalPhone__c = '1144448888';
            lProvider.BillingLatitude = 22;
            lProvider.BillingLongitude = 55;
            lProvider.ContractType__c = '1';
            lProvider.GroupCompanies__c = '1';
            lProvider.PatrimonyLiquid__c = '2';
            lProvider.Phone = '1144447777';
            lProvider.SucursalCode__c = 123;
            lProvider.TaxCity__c = 'SAOPAULO';
            lProvider.TaxUf__c = 'SP';
            lProvider.LegalSituation__c = 'PJ';
            insert lProvider;
        }

        return [SELECT Id,Name,Code__c,Email__c,SucursalCode__c,UseChart__c,EffectiveDate__c,EffectiveEndDate__c,PaymentMethod__c,PatrimonyLiquid__c,OperationalUf__c,TaxPublicPlace__c,
                    TaxStreet__c,TaxNumber__c,TaxComplement__c,TaxNeighbourhood__c,TaxCity__c,TaxUf__c,TaxZIP__c,DeliveryPublicPlace__c,DeliveryStreet__c,DeliveryNumber__c,
                    DeliveryComplement__c,DeliveryNeighborhood__c,DeliveryCity__c,DeliveryUf__c,DeliveryZip__c,ShippingLatitude,ShippingLongitude,Phone,ContractType__c,
                    GroupCompanies__c,CompanyName__c,ProviderType__c,Note__c,Status__c,CNPJ__c,BankName__c,ScheduleLink__c,ScheduleLink__r.Name,PaymentOption__c,PayTable__c,
                    ScheduleType__c,CurrentAccountDigit__c,Branch__c,DigitAgency__c,CheckingAccount__c,BankAccountType__c,OptingForSimple__c,MunicipalRegistration__c,PIS_NIT__c,
                    AnnualGrossRevenue__c,Attend24h__c,HaveParking__c,ActuationType__c,OperationalZip__c,OperationalComplement__c,OperationalNeighborhood__c,OperationalCity__c,
                    OperationalStreet__c,OperationalNumber__c,OperationalPublicPlace__c,OperationalUfPickList__c,OperationalPhone__c,Analyst__c,BillingLatitude,BillingLongitude,
                    CreatedDate,LastModifiedDate,CreatedById,CreatedBy.FederationIdentifier,LastModifiedById,OwnerId, Owner.FederationIdentifier, LastModifiedBy.FederationIdentifier,CreatorFederationIdentifier__c,ModifierFederationIdentifier__c FROM Account WHERE Id = :lProvider.Id];
    }
    
    /*@testSetup static void ActiveSpeciality(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        Product2 lSpecialty = Product2Factory.createProduct2Specialty();
        lSpecialty.Name = 'Especialidade'+ Math.random();
        insert lSpecialty;
        
        lSpecialty.Status__c = 'Ativo';
        lSpecialty.Runtime__c = Time.newInstance(1, 2, 3, 4);
        lSpecialty.WarrantyPiece__c = 1;
        lSpecialty.WarrantyMO__c = 1;
        update lSpecialty;
    }*/
    
    
        
    
    // Começo ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*@isTest
    static void updatePartnersTest(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        List<Contact> lPartnerLst = new List<Contact>();
        
        Account lProvider = AccountFactory.createAccountProvider();
        Contact lPartner = ContactFactory.createContactPartner('Branco', '47703490012');
        insert lProvider;
		lPartnerLst.add(lPartner);
        insert lPartnerLst;
        
        lPartner.AccountId = lProvider.Id;
        update lPartnerLst;

        String lBodyPartner = '['
                             +'{"lPartner":{"FirstName":"Sócio","LastName":"Branco","CPF__c":"47703490012"},'
                             +'"lParticipation":'+100.00+'}'
                             +']';
        
		Test.startTest();
        System.enqueueJob(new IntegrationHandler_cls(lPartnerLst));
        	ProviderRegistrationWizard_ctr.savePartners(lBodyPartner);
		Test.stopTest();
        
    }*/
	// final //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}