@isTest
public class VehicleHandler_tst {
	
    @isTest
    static void checkSurveyInsuranceAutoTest(){
        
        String lBodyResponse = Label.BodyResponseCreated;  
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        Vehicle__c lVehicle = VehicleFactory.createVehicle();
        insert lVehicle;
        
        OperationalSetup__c lEquipament = new OperationalSetup__c();
        Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        lEquipament.RecordTypeId = OSRecordType;
        lEquipament.Name = 'Equipamento de teste';
        lEquipament.EquipmentType__c = 'Acessórios';
        lEquipament.Description__c = 'teste2';
        lEquipament.Brand__c = 'Mondial';
        lEquipament.SafetyEquipment__c = 'Sim';
        lEquipament.Quantity__c = 7;
        lEquipament.EquipmentReturned__c = 'Sim';
        lEquipament.Status__c = 'Ativo';
        insert lEquipament;
        
        EquipamentVehicle__c lJunction = new EquipamentVehicle__c();
        lJunction.Equipament__c = lEquipament.Id;
        lJunction.Vehicle__c = lVehicle.Id;
        insert lJunction;
            
        lVehicle.phone__c = '1123242453';
        lVehicle.VehicleStatus__c = Label.Status_Deployment;
        lVehicle.InsuranceAuto__c = Label.Status_Active;
        lVehicle.SurveyStatus__c = Label.Status_Released;
        update lVehicle;
        
    }

    @isTest
    static void deleteJunctions(){
        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lVeiculoConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Vehicle];
        WebserviceConfiguration__mdt lEquipmentConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Equipment];        
        WebserviceConfiguration__mdt lModalConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :'Modal'];
        WebserviceConfiguration__mdt lPrestadorConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Prestador'];
        
        String llPrestadorEndpoint = lPrestadorConf.EndPoint__c + '/' + 1234 + '/equipamentos';

        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,'Token');
        lMultimock.setStaticResource(lVeiculoConf.EndPoint__c,'VehicleLegacy');
        lMultimock.setStaticResource(lEquipmentConf.EndPoint__c,'MockAWSSuccess');
        lMultimock.setStaticResource(lModalConf.EndPoint__c,'ModalLegacy');
        lMultimock.setStaticResource( Url.getOrgDomainUrl().toExternalForm() + '/services/data/v46.0/actions/standard/customNotificationAction','BellNotification');
        lMultimock.setStaticResource(llPrestadorEndpoint,'MockAWSSuccess'); 
        lMultimock.setStatusCode(201);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
       
        String lReturnMsg;//Mensagem de erro
        
        Vehicle__c lVehicle = VehicleFactory.createVehicle();
        lVehicle.Step__c = Label.String_Step4;
        lVehicle.SurveyStatus__c = Label.Status_Released;
        lVehicle.InsuranceAuto__c = Label.Status_Active;
        lVehicle.VehicleStatus__c = Label.Status_Active;
        lVehicle.Standardization__c = Label.String_Yes;
        insert lVehicle;
        
        /*OperationalSetup__c lEquipament = OperationalSetupFactory.createOperationalSetupEquipamento();
        insert lEquipament;
        lEquipament.Status__c = Label.Status_Active;
        update lEquipament;*/
        OperationalSetup__c lEquipament = new OperationalSetup__c();
        Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        lEquipament.RecordTypeId = OSRecordType;
        lEquipament.Name = 'Equipamento de teste';
        lEquipament.EquipmentType__c = 'Acessórios';
        lEquipament.Description__c = 'teste2';
        lEquipament.Brand__c = 'Mondial';
        lEquipament.SafetyEquipment__c = 'Sim';
        lEquipament.Quantity__c = 7;
        lEquipament.EquipmentReturned__c = 'Sim';
        lEquipament.Status__c = 'Ativo';
        insert lEquipament;
        
        EquipamentVehicle__c lJunction = new EquipamentVehicle__c();
        lJunction.Vehicle__c = lVehicle.Id;
        lJunction.Equipament__c = lEquipament.Id;        
        insert lJunction;
        
        List<ProviderEquipment__c> lListDelete = [SELECT Id FROM ProviderEquipment__c WHERE Equipment__c =: lEquipament.Id];
        if(!lListDelete.isEmpty()) delete lListDelete;
        

        ProviderEquipment__c lJunctionProvider = new ProviderEquipment__c();
        lJunctionProvider.Provider__c = lVehicle.Provider__c;
        lJunctionProvider.Equipment__c = lEquipament.Id;        
        insert lJunctionProvider;

        System.debug('lVehicle.VehicleStatus__c: '+lVehicle.VehicleStatus__c);
        
        Test.startTest();  
        	try{
                lVehicle.VehicleStatus__c = 'Cancelado';
            	update lVehicle;
        	}
        	catch(Exception e){
            	lReturnMsg = Label.String_Insert_Failed + ' ' + e.getMessage();
        	}
        Test.stopTest();
        system.assertEquals('Cancelado', [SELECT VehicleStatus__c FROM Vehicle__c WHERE Id = :lVehicle.Id].VehicleStatus__c);
        
    }
}