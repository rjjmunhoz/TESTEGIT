@istest
public class ProviderEquipmentWebService_tst {
	
    @istest
    static void equipmentProviderTest(){
        
        makeData('1');
        OperationalSetup__c lEquipment = [SELECT Id FROM OperationalSetup__c LIMIT 1];
        Account lProvider = [SELECT Id, Code__c FROM Account LIMIT 1];
        
        Mockcreate(200,lProvider.Code__c);
        
        ProviderEquipment__c lProviderEquipment = new ProviderEquipment__c();
        lProviderEquipment.Provider__c = [SELECT Id FROM Account LIMIT 1].Id;
        lProviderEquipment.Equipment__c = [SELECT Id FROM OperationalSetup__c LIMIT 1].Id;
        lProviderEquipment.IsActive__c = true;
        insert lProviderEquipment;
        
        deleteData();
    }

    static void makeData(String aKey){
        
        Account lProvider = AccountFactory.createAccountProvider();
        lProvider.Synced__c = true;
        lProvider.Code__c = 1;
        lProvider.SucursalCode__c = 2;
        insert lProvider;
        lProvider.Status__c = 'Ativo';
        update lProvider;
        
        if(aKey.contains('1')){
            
            Modal__c lModal = ModalFactory.createModalMotorcycle('MotoPorto');
            insert lModal;
            OperationalSetup__c lEquipment = OperationalSetupFactory.createOperationalSetupEquipamento();
        	insert lEquipment;
            Equipment__c lJunction = new Equipment__c();
            lJunction.Modal__c = lModal.Id;
            lJunction.OperationalSetup__c = lEquipment.Id;
            insert lJunction;
            lEquipment.Status__c = 'Ativo';
            lEquipment.Code__c = 1;
            update lEquipment;
        }
    }
    
    static void deleteData(){
        
        List<OperationalSetup__c> lEquipment = [SELECT Id FROM OperationalSetup__c];
        if(lEquipment != null){
        	delete lEquipment;
        }
        
        List<Account> lProvider = [SELECT Id FROM Account];
        if(lProvider != null){
            delete lProvider;
        }
    }
    
    static void Mockcreate(Integer aCode, Decimal aProviderCode){
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lPrestadorConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Prestador'];
        WebserviceConfiguration__mdt lEquipmentConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Equipment];        

        
        String llPrestadorEndpoint = lPrestadorConf.EndPoint__c + '/' + aProviderCode + '/equipamentos';
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,Label.String_Token);
		lMultimock.setStaticResource(lPrestadorConf.EndPoint__c,'MockAWSSuccess');        
		lMultimock.setStaticResource(llPrestadorEndpoint,'MockAWSSuccess');  
        lMultimock.setStaticResource(lEquipmentConf.EndPoint__c,'MockAWSSuccess');
		lMultimock.setStatusCode(aCode);
        lMultimock.setHeader(Label.String_Content_Type, Label.String_Application_JSON);
        
        Test.setMock(HttpCalloutMock.class, lMultimock);
    }
}