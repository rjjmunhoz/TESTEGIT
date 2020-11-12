/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para gerar a cobertura das classes IntegrationHandler_cls
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0     2019-03-20      Matheus Branco          class created 
**************************************************************************************************************/

@isTest
public class IntegrationHandler_tst {
    @testSetup
    static void makeData(){
        
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        //OperationalSetup__c-------------------------------------------------------------------------------------------------
        List<OperationalSetup__c> lAbilityLst = new List<OperationalSetup__c>();
        Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Ability').getRecordTypeId();
        for(Integer i = 0; i < 10; i++){
            OperationalSetup__c lAbility = new OperationalSetup__c();
            lAbility.Name = 'Nova Habilidade '+i;
            lAbility.Perfil__c = 'Básico';
            lAbility.Description__c = 'teste3';
            lAbility.RecordTypeId = OSRecordType;
            
            lAbilityLst.add(lAbility);
        }
        insert lAbilityLst;
        
		List<OperationalSetup__c> lEquipmentLst = new List<OperationalSetup__c>();
        OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        for(Integer i = 0; i < 10; i++){
            OperationalSetup__c lEquipment = new OperationalSetup__c();
            lEquipment.Name = 'Novo Equipamento '+i;
            lEquipment.Perfil__c = 'Básico';
            lEquipment.Description__c = 'teste3';
            lEquipment.RecordTypeId = OSRecordType;
            
            lEquipmentLst.add(lEquipment);
        }
        insert lEquipmentLst;  
        //--------------------------------------------------------------------------------------------------------------------
        //Modal__c------------------------------------------------------------------------------------------------------------
        List<Modal__c> lModalLst = new List<Modal__c>();
        for(Integer i = 0; i < 10; i++){
            Modal__c lModal = new Modal__c();
            lModal.Description__c = 'teste3';
            lModal.Name__c = 'Novo Modal '+i;
            
            lModalLst.add(lModal);
        }
        insert lModalLst;
        //--------------------------------------------------------------------------------------------------------------------
        //Product2------------------------------------------------------------------------------------------------------------
        List<Product2> lSpecialtyLst = new List<Product2>();
        OSRecordType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Specialty').getRecordTypeId();
        for(Integer i = 0; i < 10; i++){
            Product2 lSpecialty = new Product2();
            lSpecialty.Name = 'Novo Especialidade '+i;
            lSpecialty.Description__c = 'teste3';
            lSpecialty.RecordTypeId = OSRecordType;
            lSpecialty.ReasonGroup__c = '153';
            
            lSpecialtyLst.add(lSpecialty);
        }
        insert lSpecialtyLst;  
        
        List<Product2> lDetailLst = new List<Product2>();
        OSRecordType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Detail').getRecordTypeId();
        for(Integer i = 0; i < 10; i++){
            Product2 lDetail = new Product2();
            lDetail.Name = 'Novo Motivo '+i;
            lDetail.Description__c = 'teste3';
            lDetail.RecordTypeId = OSRecordType;
            lDetail.ReasonGroup__c = '153';
            
            lDetailLst.add(lDetail);
        }
        insert lDetailLst;
        //--------------------------------------------------------------------------------------------------------------------
        //Account-------------------------------------------------------------------------------------------------------------
        List<Account> lAccountLst = new List<Account>();
        OSRecordType = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Provider').getRecordTypeId();    

        Schedule__c lSchedule = ScheduleFactory.makeData();
        
        Account lAccount = new Account();
        lAccount.Name = 'Novo Conta ';
        lAccount.Description__c = 'teste3';
        lAccount.RecordTypeId = OSRecordType;
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
        lAccount.TaxCity__c = '1';
        lAccount.TaxUf__c = '1';
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
        lAccount.LegalSituation__c = 'PJ';
        insert lAccount;
        
        Contact lContact = ContactFactory.createContactPartner('Teste', '14714714785');
        lContact.AccountId = lAccount.Id;
        lContact.City__c = 'São Paulo';
        insert lContact;
        
        Account lAccountSucNull = new Account();
        lAccountSucNull.Name = 'Novo ContaSucNull ';
        lAccountSucNull.Description__c = 'teste3';
        lAccountSucNull.RecordTypeId = OSRecordType;
        lAccountSucNull.TaxCity__c = 'São Paulo';
        lAccountSucNull.TaxUf__c = 'SP';
        lAccountSucNull.ProviderType__c = '1';
        lAccountSucNull.ContractType__c = '1';
        lAccountSucNull.GroupCompanies__c = '1';
        lAccountSucNull.ScheduleLink__c = lSchedule.Id;
        lAccountSucNull.BankName__c = '1';
        lAccountSucNull.Branch__c = '11111';
        lAccountSucNull.DigitAgency__c = '1';
        lAccountSucNull.CheckingAccount__c = '1';
        lAccountSucNull.CurrentAccountDigit__c = '1';
        lAccountSucNull.PatrimonyLiquid__c = '1';
        lAccountSucNull.AnnualGrossRevenue__c = '1';
        lAccountSucNull.OptingForSimple__c = 'S';
        lAccountSucNull.MunicipalRegistration__c = '1';
        lAccountSucNull.PIS_NIT__c = '1';
        lAccountSucNull.OperationalPublicPlace__c = 'Rua';
        lAccountSucNull.OperationalStreet__c = '1';
        lAccountSucNull.OperationalNumber__c = '1';
        lAccountSucNull.OperationalComplement__c = '1';
        lAccountSucNull.OperationalNeighborhood__c = '1';
        lAccountSucNull.OperationalCity__c = '1';
        lAccountSucNull.OperationalUfPickList__c = 'SP';
        lAccountSucNull.OperationalZip__c = '11111111';
        lAccountSucNull.BillingLatitude = 1;
        lAccountSucNull.BillingLongitude = 1;
        lAccountSucNull.TaxPublicPlace__c = 'Rua';
        lAccountSucNull.TaxStreet__c = '1';
        lAccountSucNull.TaxNumber__c = 1;
        lAccountSucNull.TaxComplement__c = '1';
        lAccountSucNull.TaxNeighbourhood__c = '1';
        lAccountSucNull.TaxCity__c = '1';
        lAccountSucNull.TaxUf__c = '1';
        lAccountSucNull.TaxZIP__c = '11111111';
        lAccountSucNull.DeliveryPublicPlace__c = 'Rua';
        lAccountSucNull.DeliveryStreet__c = '1';
        lAccountSucNull.DeliveryNumber__c = '1';
        lAccountSucNull.DeliveryComplement__c = '1';
        lAccountSucNull.DeliveryNeighborhood__c = '1';
        lAccountSucNull.DeliveryCity__c = '1';
        lAccountSucNull.DeliveryUf__c = '1';
        lAccountSucNull.DeliveryZip__c = '11111111';
        lAccountSucNull.ShippingLatitude = 1;
        lAccountSucNull.ShippingLongitude = 1;
        lAccountSucNull.LegalSituation__c = 'PJ';
        insert lAccountSucNull;

        Contact lContactSucNull = new Contact();
        lContactSucNull.AccountId = lAccountSucNull.Id;
        lContactSucNull.City__c = 'São Paulo';
		lContactSucNull.FirstName = 'Sócio';
        lContactSucNull.LastName = 'testeSucNull';
        lContactSucNull.CPF__c = '25698745632';
        lContactSucNull.Phone = '912345678';
        lContactSucNull.MobilePhone = '912345678';
        insert lContactSucNull;
        
    }
    
    @isTest()
    static void OperationalSetupIntegrationTest(){
        
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));

        
        OperationalSetup__c lAbility = new OperationalSetup__c();
        
        Map<Id,Integer> fTotalSendMap = new Map<Id,Integer>();
        List<OperationalSetup__c> lAbilityLst = [SELECT Id, Name, RecordTypeId, Code__c, Perfil__c, Brand__c, UnitaryValue__c, SafetyEquipment__c,
                                                 SerialCode__c, Quantity__c, EquipmentReturned__c, RequestDate__c, UseTime__c, EntryDate__c,
                                                 WarrantyTime__c, Description__c, LastModifiedDate, Status__c,LoggedUserFederationIdentifier__c FROM OperationalSetup__c];
		System.debug('OperationalSetup quantidade' + lAbilityLst.toString());
        IntegrationHandler_cls lIntegration = new IntegrationHandler_cls(lAbilityLst);
        IntegrationHandler_cls lIntegration2 = new IntegrationHandler_cls(lAbilityLst,fTotalSendMap,null,null,null,null,null,null);
        
        Test.startTest();
        System.enqueueJob(lIntegration);
        System.enqueueJob(lIntegration2);
        Test.stopTest();
    }
    @isTest()
    static void OperationalSetupIntegrationTestError(){
        
        String lBodyResponse = '{'
            +'\"statusCode\": 200,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200,'Sucess',lBodyResponse));
        
        OperationalSetup__c lAbility = new OperationalSetup__c();
        
        Map<Id,Integer> fTotalSendMap = new Map<Id,Integer>();
        List<OperationalSetup__c> lAbilityLst = [SELECT Id, Name, RecordTypeId, Code__c, Perfil__c, Brand__c, UnitaryValue__c, SafetyEquipment__c,
                                                 SerialCode__c, Quantity__c, EquipmentReturned__c, RequestDate__c, UseTime__c, EntryDate__c,
                                                 WarrantyTime__c, Description__c, LastModifiedDate, Status__c FROM OperationalSetup__c];
		System.debug('OperationalSetup quantidade' + lAbilityLst.toString());
        IntegrationHandler_cls lIntegration = new IntegrationHandler_cls(lAbilityLst);
        fTotalSendMap.put(lAbilityLst[0].Id,3);
        // IntegrationHandler_cls lIntegration2 = new IntegrationHandler_cls(lAbilityLst,fTotalSendMap);
        
        Test.startTest();
        // System.enqueueJob(lIntegration);
        // IntegrationHandler_cls lIntegrationHandler = new IntegrationHandler_cls(lIntegration);
        lIntegration.validateToRetrieve(lAbilityLst[0],lAbilityLst);
        Test.stopTest();
    }
    
    @isTest()
    static void ModalIntegrationTest(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        Modal__c lModal = new Modal__c();
        
        Map<Id,Integer> fTotalSendMap = new Map<Id,Integer>();
        List<Modal__c> lModalLst = [SELECT Id, Name, RecordTypeId, Name__c, Initials__c, CNHCategory__c, RequiredItems__c, ModalType__c, Vehicle__c, 
                                    Survey__c, Safe__c, ModalSubjectRotation__c, Description__c, LastModifiedDate, Status__c,LoggedUserFederationIdentifier__c FROM Modal__c];
		System.debug('Modal quantidade' + lModalLst.toString());
        IntegrationHandler_cls lIntegration = new IntegrationHandler_cls(lModalLst,fTotalSendMap,null,null,null,null,null,null);
        
        Test.startTest();
        System.enqueueJob(lIntegration);
        Test.stopTest();
    }
    
    @isTest()
    static void Product2IntegrationTest(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        Product2 lSpecialty = new Product2();
        
        Map<Id,Integer> fTotalSendMap = new Map<Id,Integer>();
        List<Product2> lSpecialtyLst = [SELECT Id, Name, RecordTypeId, Code__c, SpecialtyType__c, AttendedAsset__c, WarrantyMO__c, WarrantyPiece__c,
                                        NumberReasonsAllowed__c, OperationalService__c, Description__c, Status__c, ScheduleType__c, SpecialtiesGroup__c,
                                        LastModifiedDate, ScheduledProvider__c, Runtime__c, ReasonGroup__c,LoggedUserFederationIdentifier__c FROM Product2];
		System.debug('Product2 quantidade' + lSpecialtyLst.toString());
        IntegrationHandler_cls lIntegration = new IntegrationHandler_cls(lSpecialtyLst,fTotalSendMap,null,null,null,null,null,null);
        
        Test.startTest();
        System.enqueueJob(lIntegration);
        Test.stopTest();
    }
    
    
    @isTest()
    static void AccountIntegrationTest(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        Account lAccount = new Account();
        
        Map<Id,Integer> fTotalSendMap = new Map<Id,Integer>();
        List<Account> lAccountLst = [SELECT Id, Name,Synced__c, RecordTypeId, SucursalCode__c, Code__c, CNPJ__c, Status__c, Note__c, PaymentMethod__c, ProviderType__c, Phone,
                                     CompanyName__c, ContractType__c, GroupCompanies__c, Email__c, Attend24h__c, HaveParking__c, ActuationType__c, ScheduleLink__c, ScheduleLink__r.Name, OwnerId,
                                     PayTable__c, UseChart__c, BankName__c, BankAccountType__c, Branch__c, DigitAgency__c, CheckingAccount__c, CurrentAccountDigit__c,
                                     EffectiveDate__c, EffectiveEndDate__c, PatrimonyLiquid__c, MunicipalRegistration__c,PIS_NIT__c, AnnualGrossRevenue__c, OptingForSimple__c,
                                     OperationalPublicPlace__c, OperationalStreet__c, OperationalNumber__c, OperationalComplement__c, OperationalNeighborhood__c,
                                     OperationalCity__c, OperationalUfPickList__c, OperationalPhone__c, OperationalZip__c, BillingLatitude, BillingLongitude, TaxPublicPlace__c, TaxStreet__c, 
                                     TaxNumber__c, TaxComplement__c, TaxNeighbourhood__c, TaxCity__c, TaxUf__c, TaxZIP__c , DeliveryPublicPlace__c,
                                     DeliveryStreet__c, DeliveryNumber__c,DeliveryComplement__c, DeliveryNeighborhood__c, DeliveryCity__c,  DeliveryUf__c, DeliveryZip__c, 
                                     ShippingLatitude, ShippingLongitude, LastModifiedById, CreatedDate, LastModifiedDate,CreatorFederationIdentifier__c,ModifierFederationIdentifier__c FROM Account];
        System.debug('Conta quantidade' + lAccountLst.toString());
        
        lAccountLst[0].Name = 'Name Alteration';
        lAccountLst[0].Synced__c = true;

        update lAccountLst;

       OperationalSetup__c lAbility = new OperationalSetup__c();//OperationalSetupFactory.createOperationalSetupAbility();
		Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Ability').getRecordTypeId();
        lAbility.RecordTypeId = OSRecordType;
        lAbility.Name = 'teste3';
        lAbility.Perfil__c = 'Básico';
        lAbility.Description__c = 'teste3';
        lAbility.Status__c = 'Em implantação';
        insert lAbility;

        lAbility.Status__c = 'Ativo';
        update lAbility;

        EquipmentSupplyPart__c lProviderAbility = new EquipmentSupplyPart__c();
        lProviderAbility.Provider__c =  lAccountLst[0].Id;
        lProviderAbility.Abiliity__c = lAbility.Id;
        lProviderAbility.IsActive__c = true;
        insert lProviderAbility;

        Product2 lProduct2DuplicateSpecialty = Product2Factory.createProduct2Specialty();
        lProduct2DuplicateSpecialty.Status__c = 'Ativo';
        insert lProduct2DuplicateSpecialty;  

        Ability__c lSpecialtyAbility = new Ability__c();
        lSpecialtyAbility.Product2__c = lProduct2DuplicateSpecialty.Id;
        lSpecialtyAbility.OperationalSetup__c = lAbility.Id;
        lSpecialtyAbility.IsActive__c = true;
        
        insert lSpecialtyAbility;

        lAccountLst[0].CNPJ__c = '12345678987654';
        update lAccountLst;

        // IntegrationHandler_cls lIntegration = new IntegrationHandler_cls(lAccountLst,fTotalSendMap,null,null,null);
        
        // Test.startTest();
        // System.enqueueJob(lIntegration);
        // Test.stopTest();
    }

    
    
    
    @isTest()
    static void ContactIntegrationTest(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        Contact lSpecialty = new Contact();
        
        Map<Id,Integer> fTotalSendMap = new Map<Id,Integer>();
        List<Contact> lContactLst = [SELECT Id, FirstName, LastName, RecordTypeId, OwnerId, LastModifiedById, QRA__c, Status__c, CPF__c, RG__c, Birthdate,
                                       FatherName__c, MotherName__c, Nationality__c, Uf__c, Gender__c, MaritalStatus__c, Email, MobilePhone, Height__c,
                                       Weight__c, Shirt__c, Pants__c, Boot__c, StatusRadar__c, RadarReturnDate__c,RadarShippingDate__c, CreatedDate, CreatedById, Street__c,
                                       Complement__c, Number__c, Neighborhood__c, City__c, Zip__c, HomePhone, CompanyCode__c, AccountId, WorkRegisterBookletSeries__c, 
                                       WorkRegisterBookletNumber__c, CNHExpirationDate__c, DateOfFirstCNH__c, CNHCategory__c, CNHNumber__c, Role__c
                                       FROM Contact];
		System.debug('Contact quantidade' + lContactLst.toString());
        List<Account> lProvider = [SELECT Id FROM Account LIMIT 1];
        lContactLst[0].RecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('BaseEmployees').getRecordTypeId();
        lContactLst[0].SyncAPI__c = true;
        lContactLst[0].QRA__c = 10;
        lContactLst[0].CNHCategory__c = 'B';
        lContactLst[0].AccountId = lProvider[0].Id;

        update lContactLst;

        lContactLst[0].CNHNumber__c = '10203040501';
        update lContactLst;

        OperationalSetup__c lAbility = new OperationalSetup__c();//OperationalSetupFactory.createOperationalSetupAbility();
		Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Ability').getRecordTypeId();
        lAbility.RecordTypeId = OSRecordType;
        lAbility.Name = 'teste3';
        lAbility.Perfil__c = 'Básico';
        lAbility.Description__c = 'teste3';
        lAbility.Status__c = 'Em implantação';
        insert lAbility;

        lAbility.Status__c = 'Ativo';
        update lAbility;


        Product2 lProduct2DuplicateSpecialty = Product2Factory.createProduct2Specialty();
        lProduct2DuplicateSpecialty.Status__c = 'Ativo';
        insert lProduct2DuplicateSpecialty;  

        Ability__c lSpecialtyAbility = new Ability__c();
        lSpecialtyAbility.Product2__c = lProduct2DuplicateSpecialty.Id;
        lSpecialtyAbility.OperationalSetup__c = lAbility.Id;
        lSpecialtyAbility.IsActive__c = true;        
        insert lSpecialtyAbility;


        Ability__c lRescuerAbility = new Ability__c();
        lRescuerAbility.RescuerId__c =  lContactLst[0].Id;
        lRescuerAbility.Ability__c = lAbility.Id;
        lRescuerAbility.IsActive__c = true;
        insert lRescuerAbility;
        lContactLst[0].CNHNumber__c = '10203040502';
        update lContactLst;



        
        // IntegrationHandler_cls lIntegration = new IntegrationHandler_cls(lContactLst,fTotalSendMap,null,null,null);
        
        // Test.startTest();
        // System.enqueueJob(lIntegration);
        // Test.stopTest();
    }
    
    @isTest()
    static void ContactIntegrationTestError(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        
        Map<Id,Integer> fTotalSendMap = new Map<Id,Integer>();
        Contact lContact = ContactFactory.createContactBaseEmployee();
        lContact.LastName = 'TesteERROR';
        insert lContact;
        
        List<Account> lProvider = [SELECT Id FROM Account LIMIT 1];
        lContact.RecordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('BaseEmployees').getRecordTypeId();
        lContact.SyncAPI__c = true;
        lContact.QRA__c = 10;
        lContact.CNHCategory__c = 'B';
        lContact.AccountId = lProvider[0].Id;

        update lContact;

        lContact.CNHNumber__c = '10203040501';
        update lContact;

        OperationalSetup__c lAbility = new OperationalSetup__c();
		Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Ability').getRecordTypeId();
        lAbility.RecordTypeId = OSRecordType;
        lAbility.Name = 'teste3';
        lAbility.Perfil__c = 'Básico';
        lAbility.Description__c = 'teste3';
        lAbility.Status__c = 'Em implantação';
        insert lAbility;

        lAbility.Status__c = 'Ativo';
        update lAbility;


        Product2 lProduct2DuplicateSpecialty = Product2Factory.createProduct2Specialty();
        lProduct2DuplicateSpecialty.Status__c = 'Ativo';
        insert lProduct2DuplicateSpecialty;  

        Ability__c lSpecialtyAbility = new Ability__c();
        lSpecialtyAbility.Product2__c = lProduct2DuplicateSpecialty.Id;
        lSpecialtyAbility.OperationalSetup__c = lAbility.Id;
        lSpecialtyAbility.IsActive__c = true;        
        insert lSpecialtyAbility;


        Ability__c lRescuerAbility = new Ability__c();
        lRescuerAbility.RescuerId__c =  lContact.Id;
        lRescuerAbility.Ability__c = lAbility.Id;
        lRescuerAbility.IsActive__c = true;
        insert lRescuerAbility;
        lContact.CNHNumber__c = '10203040502';
        update lContact;
    }
}