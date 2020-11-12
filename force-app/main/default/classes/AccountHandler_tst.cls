@isTest
public class AccountHandler_tst {
    
    @TestSetup
    static void makeData(){
        //Equipamento
        String lBodyResponse = Label.BodyResponseCreated;  
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        
        OperationalSetup__c lOPEquipament = OperationalSetupFactory.createOperationalSetupEquipamento();
		insert lOPEquipament;
        //Peças
        OperationalSetup__c lPart = OperationalSetupFactory.createOperationalSetupPart();
        insert lPart;
        //Insumos
        OperationalSetup__c lSupply = OperationalSetupFactory.createOperationalSetupSupply();
        insert lSupply;
        
        /*Schedule__c lSchedule = new Schedule__c();
        lSchedule.Frequency__c = '10 dias';
        Insert lSchedule;*/
        
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
      
        Contact lContact = ContactFactory.createContactPartner('Test','00000000044');
        lContact.AccountId = lAccount.Id;
        insert lContact;
        
        OperationalSetup__c lOperationalSetup = OperationalSetupFactory.createOperationalSetupAbility();
        insert lOperationalSetup;

        EquipmentSupplyPart__c lEquipmentSupplyPart = new EquipmentSupplyPart__c();
        lEquipmentSupplyPart.Abiliity__c = lOperationalSetup.Id;
        lEquipmentSupplyPart.Part__c = lPart.Id;
        lEquipmentSupplyPart.Provider__c = lAccount.Id;
        insert lEquipmentSupplyPart;
 
      
    }
    @isTest
    static void providerGeoCodeChangeTst(){

        WebserviceConfiguration__mdt lToken = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lSucursal = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Sucursal'];
        WebserviceConfiguration__mdt lPrestador = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Prestador'];

        String lStringToken = lToken.EndPoint__c;
        String lSucursalEndpoint = lSucursal.EndPoint__c;
        String llPrestadorEndpoint = lPrestador.EndPoint__c;

        String lStringSucursal = lSucursalEndpoint+'?cidade=SaoPaulo&uf=SP'; 
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(lStringToken,'Token');
        multimock.setStaticResource(lStringSucursal,'Sucursal');
        multimock.setStaticResource(llPrestadorEndpoint,'MockAWSSuccess');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.setMock(HttpCalloutMock.class, multimock);
        
        Schedule__c lSchedule = ScheduleFactory.makeData();
        
        Account lAccount = [SELECT Id FROM Account LIMIT 1];
      	lAccount.OperationalUfPickList__c = 'SP';
     	lAccount.DeliveryUf__c = 'SP';
     	lAccount.TaxUf__c = 'SP';
        lAccount.TaxCity__c = 'São Paulo';
     	lAccount.Synced__c = true;
     	lAccount.ProviderType__c = '1';
     	lAccount.ContractType__c = '1';
     	lAccount.GroupCompanies__c ='1';
     	lAccount.ScheduleLink__c = lSchedule.Id;
     	lAccount.Branch__c = '00000';
     	lAccount.PatrimonyLiquid__c = '1';
        lAccount.AnnualGrossRevenue__c = '1';
        lAccount.SucursalCode__c = null;
     	update lAccount;
        
        // EquipmentSupplyPart__c lEquipmentSupplyPart = [SELECT Id, Provider__r.Code__c, Provider__r.OwnerId, Provider__r.Owner.FederationIdentifier,
        //                                                Provider__r.CreatedDate, Provider__r.LastModifiedBy.FederationIdentifier, Provider__r.LastModifiedDate
        //                                                FROM EquipmentSupplyPart__c LIMIT 1];
        // ProviderWebService_cls lIntegration = new ProviderWebService_cls(lEquipmentSupplyPart);
    }
    
    @isTest
    static void contactPFProvider(){
        
        //List<Contact> lRescuerList = [SELECT Id FROM Contact];
        //delete lRescuerList;
        
        List<Account> lProviderList = [SELECT Id FROM Account];
        delete lProviderList;
        
        Account lProviderPF = AccountFactory.createAccountProviderPF();
        insert lProviderPF;
        
        Contact lRescuer = ContactFactory.createContactBaseEmployee(lProviderPF.Id);
        lRescuer.CPF__c = lProviderPF.CNPJ__c;
        insert lRescuer;
        
        //lProviderPF.Status__c = 'Ativo';
        lProviderPF.StatusRadar__c = 'L';
        update lProviderPF;
        
        lRescuer = [SELECT Id, StatusRadar__c FROM Contact WHERE Id =: lRescuer.Id LIMIT 1];
        
        System.assertEquals(lProviderPF.StatusRadar__c == lRescuer.StatusRadar__c, true);
        
    }
    
    
    //Cobertura refernte ao fornecedor comentada
   /* @isTest
    static void AccountHandlerTest(){        
        
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        //List<Account> lAccountLst = new List<Account>();
        //lAccountLst.add(AccountFactory.createAccountProduct());
        //lAccountLst.add(AccountFactory.createAccountProvider());
        //lAccountLst.add(AccountFactory.createAccountSupplier());
        //insert lAccountLst;

        Account lAccount = AccountFactory.createAccountSupplier();
        insert lAccount;
        
        //update lAccountLst;
        update lAccount;
    }  
  
    @isTest 
    static void accountithoutPartSupplyEquipment(){
        Account lSupplier = AccountFactory.createAccountSupplier();
        insert lSupplier;
        System.assertEquals(lSupplier.Status__c, 'Em implantação');

        try{
            lSupplier.Status__c = 'Ativo';
            update lSupplier;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains('Para ativar esse Fornecedor será necessário cadastrar ou vincular Equipamentos, Peças ou Insumos.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }

    @isTest 
    static void accountWithPart(){
        Account lSupplier = AccountFactory.createAccountSupplier();
        insert lSupplier;
        OperationalSetup__c lPart = [SELECT Name, Status__c FROM OperationalSetup__c WHERE RecordType.DeveloperName = 'Part'];
        System.assertEquals(lSupplier.Status__c, 'Em implantação');
        System.assertEquals(lPart.Status__c, 'Em implantação');

        Id EquipmentRecType = SObjectType.EquipmentSupplyPart__c.getRecordTypeInfosByDeveloperName().get('Parts').getRecordTypeId();
        EquipmentSupplyPart__c Part = new EquipmentSupplyPart__c();
        Part.ProviderPart__c = lSupplier.Id;
        Part.Part__c = lPart.Id;
        insert Part;

        try{
            lSupplier.Status__c = 'Ativo';
            update lSupplier;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains('Para ativar esse Fornecedor será necessário cadastrar ou vincular Equipamentos, Peças ou Insumos.') ? true : false;
        }
        System.assertEquals(lSupplier.Status__c,'Ativo');
    }

    @isTest 
    static void accountWithEquipment(){
        Account lSupplier = AccountFactory.createAccountSupplier();
        insert lSupplier;
        OperationalSetup__c lEquipment = [SELECT Name, Status__c FROM OperationalSetup__c WHERE RecordType.DeveloperName = 'Equipment' LIMIT 1];
        System.assertEquals(lSupplier.Status__c, 'Em implantação');
        System.assertEquals(lEquipment.Status__c, 'Em implantação');

        Id EquipmentRecType = SObjectType.EquipmentSupplyPart__c.getRecordTypeInfosByDeveloperName().get('Equipments').getRecordTypeId();
        EquipmentSupplyPart__c Equipment = new EquipmentSupplyPart__c();
        Equipment.Account__c = lSupplier.Id;
        Equipment.OperationalSetup__c = lEquipment.Id;
        Equipment.RecordTypeId = EquipmentRecType;
        insert Equipment;

        try{
            lSupplier.Status__c = 'Ativo';
            update lSupplier;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains('Para ativar esse Fornecedor será necessário cadastrar ou vincular Equipamentos, Peças ou Insumos.') ? true : false;
        }
        System.assertEquals(lSupplier.Status__c, 'Ativo');
    }

    @isTest 
    static void accountWithSupply(){
        Account lSupplier = AccountFactory.createAccountSupplier();
        insert lSupplier;
        OperationalSetup__c lSupply = [SELECT Name, Status__c FROM OperationalSetup__c WHERE RecordType.DeveloperName = 'Supply' LIMIT 1];
        System.assertEquals(lSupplier.Status__c, 'Em implantação');
        System.assertEquals(lSupply.Status__c, 'Em implantação');

        Id SupplyRecType = SObjectType.EquipmentSupplyPart__c.getRecordTypeInfosByDeveloperName().get('Inputs').getRecordTypeId();
        EquipmentSupplyPart__c Supply = new EquipmentSupplyPart__c();
        Supply.ProviderInputs__c = lSupplier.Id;
        Supply.Input__c = lSupply.Id;
        Supply.RecordTypeId = SupplyRecType;
        insert Supply;

        try{
            lSupplier.Status__c = 'Ativo';
            update lSupplier;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains('Para ativar esse Fornecedor será necessário cadastrar ou vincular Equipamentos, Peças ou Insumos.') ? true : false;
        }
        System.assertEquals(lSupplier.Status__c,'Ativo');
    }*/
}