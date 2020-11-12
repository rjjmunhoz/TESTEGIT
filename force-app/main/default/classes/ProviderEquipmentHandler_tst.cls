@isTest
public class ProviderEquipmentHandler_tst {
    
    @isTest
    static void DuplicateTest(){
        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lEquipmentConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Equipment];        
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,'Token');
        lMultimock.setStaticResource(lEquipmentConf.EndPoint__c,'MockAWSSuccess');
        lMultimock.setStatusCode(201);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
        
        Account lProvider = AccountFactory.createAccountProvider();
        Insert lProvider;
        
        OperationalSetup__c lEquipament = new OperationalSetup__c();
        Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        lEquipament.RecordTypeId = OSRecordType;
        lEquipament.Name = 'Equipamento de teste';
        lEquipament.EquipmentType__c = 'Acessórios';
        lEquipament.Description__c = 'teste';
        lEquipament.Brand__c = 'Mondial';
        lEquipament.SafetyEquipment__c = 'Sim';
        lEquipament.Quantity__c = 7;
        lEquipament.EquipmentReturned__c = 'Sim';
        lEquipament.Status__c = 'Ativo';
        insert lEquipament;
        
        ProviderEquipment__c lJunctionProvider = new ProviderEquipment__c();
        lJunctionProvider.Provider__c = lProvider.Id;
        lJunctionProvider.Equipment__c = lEquipament.Id;        
        insert lJunctionProvider; 
        
        ProviderEquipment__c lJunctionProvider2 = new ProviderEquipment__c();
        lJunctionProvider2.Provider__c = lProvider.Id;
        lJunctionProvider2.Equipment__c = lEquipament.Id;
        
        try{
            insert lJunctionProvider2; 
            System.assertEquals(true, false,'O teste deveria gerar erro!');
        }
        catch(Exception e){
            System.assert(e.getMessage().contains(Label.MessageError_JunctionProviderEquipment), true);
        }
        
        
    }

}