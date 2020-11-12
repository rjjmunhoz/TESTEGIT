@isTest
public class RescuerRegistrationWizard_tst {
    private static final String ROLE_GESTOR = Label.Role_Manager;   
    private static final String PROVIDER_TYPE_DEFAULT = '1'; 
    private static final String PROVIDER_TYPE_PREFERENTIAL = '2';    
    
	
    @isTest
    static void searchEmployeeByCPFTest1(){
        WebserviceConfiguration__mdt lToken = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lRegistrationDataPF = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SerasaPFDadosCadastrais'];
        
        String lStringToken = lToken.EndPoint__c;
        String lEndpoint = lRegistrationDataPF.EndPoint__c;

        List<Object> lParameters = new List<Object> {'0000000000'};
        String lStringRegistrationDataPF = String.format(lEndpoint, lParameters);        

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(lStringToken,'Token');
        multimock.setStaticResource(lStringRegistrationDataPF,'PJDataRegistration');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, multimock);

        Test.startTest();
            RescuerRegistrationWizard_ctr.searchEmployeeByCPF('0000000000');
        Test.stopTest();
		
    }
    @isTest
    static void searchEmployeeByCPFTest2(){
        
        String lBodyResponse = Label.BodyResponseCreated;  
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));

        Contact lContact = ContactFactory.createContactBaseEmployee();
        lContact.Role__c = ROLE_GESTOR;
        lContact.StepWizard__c = 3;
        lContact.CPF__c = '0000000000';
        insert lContact;
        lContact.UpdateDate__c = date.today();
        update lContact;

        Test.startTest();
            RescuerRegistrationWizard_ctr.searchEmployeeByCPF('0000000000');        
        Test.stopTest();
		
    }
    @isTest
    static void searchEmployeeByCPFTest3(){      
        
        String lBodyResponse = Label.BodyResponseServerError;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(500,Label.StatusInternalServerError,lBodyResponse));

        Test.startTest();
            RescuerRegistrationWizard_ctr.searchEmployeeByCPF('0000000002');
        Test.stopTest();
		
    }

    @TestSetup
    static void makeData(){
        Schedule__c lSchedule = ScheduleFactory.makeData();
        
        Account lAccount = AccountFactory.createAccountProvider();
        lAccount.Synced__c = true;
        lAccount.Phone = '1177777777';
        lAccount.Description__c = 'teste3';
        lAccount.SucursalCode__c = 153;
        lAccount.TaxCity__c = 'São Paulo';
        lAccount.TaxUf__c = 'SP';
        lAccount.ProviderType__c = '1';
        lAccount.ContractType__c = '1';
        lAccount.GroupCompanies__c = '1';
        lAccount.ScheduleLink__c = lSchedule.Id;
        lAccount.BankName__c = '1';
        lAccount.Branch__c = '11111';
        lAccount.DigitAgency__c = '1';
        lAccount.CheckingAccount__c = '1';
        lAccount.CurrentAccountDigit__c = '1';
        lAccount.PatrimonyLiquid__c = '1';
        lAccount.AnnualGrossRevenue__c = '1';
        lAccount.OptingForSimple__c = 'S';
        lAccount.MunicipalRegistration__c = '1';
        lAccount.PIS_NIT__c = '1';
        lAccount.OperationalPublicPlace__c = 'Rua';
        lAccount.OperationalStreet__c = '1';
        lAccount.OperationalNumber__c = '1';
        lAccount.OperationalComplement__c = '1';
        lAccount.OperationalNeighborhood__c = '1';
        lAccount.OperationalCity__c = '1';
        lAccount.OperationalUfPickList__c = 'SP';
        lAccount.OperationalZip__c = '11111111';
        lAccount.BillingLatitude = 1;
        lAccount.BillingLongitude = 1;
        lAccount.TaxPublicPlace__c = 'Rua';
        lAccount.TaxStreet__c = '1';
        lAccount.TaxNumber__c = 1;
        lAccount.TaxComplement__c = '1';
        lAccount.TaxNeighbourhood__c = '1';
        lAccount.TaxZIP__c = '11111111';
        lAccount.DeliveryPublicPlace__c = 'Rua';
        lAccount.DeliveryStreet__c = '1';
        lAccount.DeliveryNumber__c = '1';
        lAccount.DeliveryComplement__c = '1';
        lAccount.DeliveryNeighborhood__c = '1';
        lAccount.DeliveryCity__c = '1';
        lAccount.DeliveryUf__c = '1';
        lAccount.DeliveryZip__c = '11111111';
        lAccount.ShippingLatitude = 1;
        lAccount.ShippingLongitude = 1;
        insert lAccount;
    }

    @isTest
    static void saveContactTest1(){
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lSocorrista = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Socorrista];
        WebserviceConfiguration__mdt lSocorristasVidaConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.RescuerLifeEndPoint];
        
        List<Object> lParameters = new List<Object> {'601711548'};
        String lSocorristaEndpoint = String.format(lSocorrista.EndPoint__c, lParameters);
        String lSocorristasVidaEndpoint = String.format(lSocorristasVidaConf.EndPoint__c, lParameters);
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,Label.String_Token);
        lMultimock.setStaticResource(lSocorristaEndpoint,Label.SetResourceAWSSuccess);
        lMultimock.setStaticResource(lSocorristasVidaEndpoint,Label.SetResourceRescuerLife);
        lMultimock.setStatusCode(200);
        lMultimock.setHeader(Label.String_Content_Type, Label.String_Application_JSON);
        Test.setMock(HttpCalloutMock.class, lMultimock);

        Id ProviderRecType = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProviderRecordType).getRecordTypeId();
        List<Account> lAccountLst = [SELECT Id FROM Account];
        

        Contact lContact = ContactFactory.createContactBaseEmployee(lAccountLst[0].Id);
        lContact.FirstName = 'MARCELO';
        lContact.LastName = 'DE JESUS FREITAS';
        lContact.StepWizard__c = 3;
        lContact.Role__c = 'Socorrista';
        lContact.CPF__c = '601711548';
        insert lContact;      

        lContact.RisksStatus__c = Label.Status_Released;
        lContact.LifeInsurance__c =Label.String_A;
        //update lContact;        

        Contact lRescuer = [SELECT Id, StepWizard__c, ProviderType__c, FirstName, LastName, CPF__c, City__c, Role__c, AccountId FROM Contact WHERE Id =: lContact.Id];
        
        Test.startTest();
            RescuerRegistrationWizard_ctr.saveContact(JSON.serialize(lRescuer));
        Test.stopTest();        
    }
	/*
    @isTest
    static void saveContactTest2(){
        
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
             +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));    

        Account lAccount = AccountFactory.createAccountProvider();
        lAccount.ProviderType__c = PROVIDER_TYPE_PREFERENTIAL;
        insert lAccount;

        Contact lContact = ContactFactory.createContactBaseEmployee(lAccount.Id);
        lContact.StepWizard__c = 2;
        insert lContact;

        lContact.RisksStatus__c ='Liberado';
        lContact.LifeInsurance__c ='A';
        update lContact;        
        system.debug('Teste 0001');
        RescuerRegistrationWizard_ctr.saveContact(JSON.serialize(lContact));
        
        Contact lContact2 = ContactFactory.createContactBaseEmployee(lAccount.Id);
        lContact2.StepWizard__c = 3;
        lContact2.Role__c = ROLE_GESTOR;
        lContact2.RisksStatus__c ='Liberado';
        lContact2.LifeInsurance__c ='A';
        
        Test.startTest();
            RescuerRegistrationWizard_ctr.saveContact(JSON.serialize(lContact2));
        Test.stopTest();        
    }*/
}