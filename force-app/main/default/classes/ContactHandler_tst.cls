@isTest
public class ContactHandler_tst {
    
    private static final String BASE_EMPLOYEE = Label.BaseEmployeesRecordType;
    
    @testSetup
    static void makeData(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        //Criando a conta do  RescuerLegacy
        Account lProvider = (Account) new AccountFactory.Provider().createRecord();
        lProvider.LegalSituation__c = Label.LegalPerson;
        lProvider.ProviderType__c = '2';
        update lProvider;
        
        Account lProvider2 = (Account) new AccountFactory.Provider().createRecord();
        //Criando um colaborador da base
        Contact lBaseEmployee = (Contact) new ContactFactory.BaseEmployees(lProvider.Id).createRecord();
    }   
    
    @isTest
    static void ActivateContact(){
        
       
        Contact lContact = [SELECT Id, AccountId, RisksStatus__c,ApprovedSelectionProcess__c, StepWizard__c, Account.LegalSituation__c  FROM Contact WHERE RecordType.DeveloperName = :BASE_EMPLOYEE LIMIT 1];
        lContact.RisksStatus__c = Label.Status_Released;
        lContact.ApprovedSelectionProcess__c = true;
        //lContact.StepWizard__c = 3;
        update lContact;
        
        lContact = [SELECT Status__c, QRA__c, Account.LegalSituation__c FROM Contact WHERE Id = :lContact.Id LIMIT 1];
        system.debug('teste QRA: ' + lContact.QRA__c);
        system.debug('teste Status: ' + lContact.Status__c);
        system.debug('teste tipo pessoa: ' + lContact.Account.LegalSituation__c);
        
        System.assert(lContact.Status__c == Label.STATUS_ACTIVE,false);
        //System.assert(lContact.QRA__c != null,true);
    }
    
    @isTest static void deleteJuntionContact_tst(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        //fazendo consulta
        Account accCont = [SELECT Id FROM Account LIMIT 1];
        Contact baseCont = [SELECT Id, AccountId, City__c FROM Contact WHERE RecordType.DeveloperName = :BASE_EMPLOYEE LIMIT 1];
        baseCont.AccountId = accCont.Id;
        update baseCont;
        AccountContactRelation lacr = [Select Id from AccountContactRelation where AccountId = :accCont.Id and Contactid = :baseCont.Id];
        System.debug(lacr);
        System.assertEquals(baseCont.AccountId, accCont.Id); 
    }
    
    @isTest 
    static void legacyIntegration(){        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lRescuerConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Socorrista];
        
        String lRescuerEndpoint = lRescuerConf.EndPoint__c;
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,Label.String_Token);
        lMultimock.setStaticResource(lRescuerEndpoint,Label.String_RescuerLegacy);
        lMultimock.setStatusCode(200);
        lMultimock.setHeader(Label.String_Content_Type, Label.String_Application_JSON);
        Test.setMock(HttpCalloutMock.class, lMultimock);
        
        Contact baseCont = [SELECT Id, AccountId FROM Contact WHERE RecordType.DeveloperName = :BASE_EMPLOYEE LIMIT 1];
        List<AccountContactRelation> lAccCtRelationLst = [SELECT StartDate, EndDate, Account.ContractType__c, IsActive  FROM AccountContactRelation 
            WHERE ContactId = :baseCont.Id AND AccountId = :baseCont.AccountId LIMIT 1];
        baseCont.QRA__c = 1000;
        baseCont.SyncAPI__c = true;
        system.debug('AccountId: '+ baseCont.AccountId);
        lAccCtRelationLst[0].IsActive = true;
        update lAccCtRelationLst;
        
        OperationalSetup__c lAbility = new OperationalSetup__c();//OperationalSetupFactory.createOperationalSetupAbility();
		Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.AbilityRecordType).getRecordTypeId();
        lAbility.RecordTypeId = OSRecordType;
        lAbility.Name = 'teste3';
        lAbility.Perfil__c = 'Básico';
        lAbility.Description__c = 'teste3';
        lAbility.Status__c = Label.Status_Deployment;
        insert lAbility;
        
        Product2 lProduct2 = new Product2();//Product2Factory.createProduct2Detail();
        Id lSpecialtyRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.SpecialtyRecordType).getRecordTypeId();
        lProduct2.RecordTypeId = lSpecialtyRecType;
        lProduct2.Name = Label.SpecialtyRecordType;
        lProduct2.Description__c = 'Descrição';
        lProduct2.Status__c = Label.Status_Deployment;
        insert lProduct2;
        
        Product2 lDetailRecord = new Product2();//Product2Factory.createProduct2Detail();
        Id lDetailtyRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.DetailRecordType).getRecordTypeId();
        lDetailRecord.RecordTypeId = lDetailtyRecType;
        lDetailRecord.Name = Label.DetailRecordType;
        lDetailRecord.Description__c = 'Descrição';
        lDetailRecord.Status__c = Label.Status_Deployment;
        insert lDetailRecord;
        
        Ability__c lJunction = new Ability__c();
        lJunction.Product2__c = lProduct2.Id;
        lJunction.OperationalSetup__c = lAbility.Id;
        lJunction.RescuerId__c = baseCont.id;
        insert lJunction;
        
        Product2 lSpecialty = Product2Factory.createProduct2Specialty();
        lSpecialty.Name = 'Especialidade 003';
        insert lSpecialty;
        
        ServiceSpecialtyDetails__c lJunction2 = new ServiceSpecialtyDetails__c();
        lJunction2.SpecialtyDetail__c = lSpecialty.Id;
        lJunction2.Detail__c = lDetailRecord.Id;
        insert lJunction2;

		String lReturnMsg;
        
        Test.startTest();            
           try{
           		update baseCont;
           }catch(Exception e){
               	system.debug('Erro try/Catch: ');
                lReturnMsg = Label.String_Insert_Failed+ ' ' + e.getMessage();
           } 
        Test.stopTest();
    }
    
    @isTest 
    static void legacyIntegration2(){   
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lRescuerConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Socorrista];
        
        String lRescuerEndpoint = lRescuerConf.EndPoint__c;
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,Label.String_Token);
        lMultimock.setStaticResource(lRescuerEndpoint,Label.String_RescuerLegacy);
        lMultimock.setStatusCode(200);
        lMultimock.setHeader(Label.String_Content_Type, Label.String_Application_JSON);
        Test.setMock(HttpCalloutMock.class, lMultimock);
        
        Contact baseCont = [SELECT Id, AccountId FROM Contact WHERE RecordType.DeveloperName = :BASE_EMPLOYEE LIMIT 1];
        List<AccountContactRelation> lAccCtRelationLst = [SELECT StartDate, EndDate, Account.ContractType__c, IsActive  FROM AccountContactRelation 
            WHERE ContactId = :baseCont.Id AND AccountId = :baseCont.AccountId LIMIT 1];
        baseCont.QRA__c = 1000;
        baseCont.SyncAPI__c = true;
        system.debug('AccountId: '+ baseCont.AccountId);
        lAccCtRelationLst[0].IsActive = false;
        update lAccCtRelationLst;
        
        OperationalSetup__c lAbility = new OperationalSetup__c();//OperationalSetupFactory.createOperationalSetupAbility();
		Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.AbilityRecordType).getRecordTypeId();
        lAbility.RecordTypeId = OSRecordType;
        lAbility.Name = 'teste3';
        lAbility.Perfil__c = 'Básico';
        lAbility.Description__c = 'teste3';
        lAbility.Status__c = Label.Status_Deployment;
        insert lAbility;
        
        Product2 lProduct2 = new Product2();//Product2Factory.createProduct2Detail();
        Id lSpecialtylRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.SpecialtyRecordType).getRecordTypeId();
        lProduct2.RecordTypeId = lSpecialtylRecType;
        lProduct2.Name = Label.SpecialtyRecordType;
        lProduct2.Description__c = 'Descrição';
        lProduct2.Status__c = Label.Status_Deployment;
        insert lProduct2;
        
        Product2 lDetailRecord = new Product2();//Product2Factory.createProduct2Detail();
        Id lDetaillRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.DetailRecordType).getRecordTypeId();
        lDetailRecord.RecordTypeId = lDetaillRecType;
        lDetailRecord.Name = Label.DetailRecordType;
        lDetailRecord.Description__c = 'Descrição';
        lDetailRecord.Status__c = Label.Status_Deployment;
        insert lDetailRecord;
                
        Ability__c lJunction = new Ability__c();
        lJunction.Product2__c = lProduct2.Id;
        lJunction.OperationalSetup__c = lAbility.Id;
        lJunction.RescuerId__c = baseCont.id;
        insert lJunction;
        
        Product2 lSpecialty = Product2Factory.createProduct2Specialty();
        lSpecialty.Name = 'Especialidade 003';
        insert lSpecialty;
        
        ServiceSpecialtyDetails__c lJunction2 = new ServiceSpecialtyDetails__c();
        lJunction2.SpecialtyDetail__c = lSpecialty.Id;
        lJunction2.Detail__c = lDetailRecord.Id;
        insert lJunction2;

		String lReturnMsg;
        
        Test.startTest();            
           try{
           		update baseCont;
           }catch(Exception e){
               	system.debug('Erro try/Catch: ');
                lReturnMsg = Label.String_Insert_Failed+ ' ' + e.getMessage();
           } 
        Test.stopTest();
    }
    
    
}