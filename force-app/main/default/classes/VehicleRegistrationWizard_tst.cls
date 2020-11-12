/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste da classe VehicleRegistrationWizard_ctr
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-15      Mariana Ribeiro         class created 
**************************************************************************************************************/
@isTest
public with sharing class VehicleRegistrationWizard_tst {
    private static final String STATUS_IN_DEPLOYMENT = 'Em implantação';
	private static final String SURVEY_STATUS = 'Não liberado';
    private static final String INSURANCE_AUTO = 'Inativo';
    
    @isTest
    static void searchVehicle(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        Test.startTest();     
        	Vehicle__c lVehicle = VehicleRegistrationWizard_ctr.searchVehicle('MUN2007');
        Test.stopTest();
        System.assertEquals(lVehicle.Step__c, 'Step2');        
    }

    @isTest
    static void saveVehicle(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        Vehicle__c lVehicle = VehicleFactory.createVehicle();
        lVehicle.Step__c = 'Step3';
        insert lVehicle;
        
        String lJson = JSON.serialize(lVehicle);
        
        Test.startTest();     
            Vehicle__c lResult = VehicleRegistrationWizard_ctr.saveVehicle(lJson,lVehicle.Step__c, lVehicle.Company__c.split(';'));
            Vehicle__c lResult2 = VehicleRegistrationWizard_ctr.updateCompany(lJson, lVehicle.Company__c.split(';'));
            String ProfileName = VehicleRegistrationWizard_ctr.getProfileName();
            List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> lCompanyValues = VehicleRegistrationWizard_ctr.updateCompanyLoad(lJson, lVehicle.Company__c.split(';'));
            List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> lCompanyValues2 = VehicleRegistrationWizard_ctr.getCompanyPicklistObj();
        Test.stopTest();
        System.assertEquals(lResult.Step__c, 'Step4');
        
    }
    
    @isTest
    static void saveVehicleStep2(){
       String lPlate = 'CEI0781';
        String lChassi = 'VF37CNFZ2SP733288';
        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lSeguroVeiculoConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SeguroVeiculo'];
		WebserviceConfiguration__mdt lEquipmentConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Equipment];        
        WebserviceConfiguration__mdt lVeiculoConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Vehicle];
        WebserviceConfiguration__mdt lModalConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Modal']; 
        
		String lParametersInsurance = '?placa=' + lPlate + '&chassi=' + lChassi;        
        String lInsuranceEndpoint = lSeguroVeiculoConf.EndPoint__c+lParametersInsurance;
        System.debug('lInsuranceEndpoint: '+lInsuranceEndpoint);
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,'Token');
        lMultimock.setStaticResource(lInsuranceEndpoint,'InsuranceAuto');
        lMultimock.setStaticResource(lEquipmentConf.EndPoint__c,'MockAWSSuccess');
        lMultimock.setStaticResource(lModalConf.EndPoint__c,'ModalLegacy');
        lMultimock.setStaticResource(lVeiculoConf.EndPoint__c,'VehicleLegacy');
        lMultimock.setStatusCode(201);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
                
        
        Account lProvider = AccountFactory.createAccountProvider();
        Insert lProvider;
        
        Group lQueue = new Group(Name='Sustentação', Type='Queue');
		insert lQueue;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = lQueue.id, SObjectType = 'Vehicle__c');
            insert testQueue;
        } 
        
        Vehicle__c lVehicle = new Vehicle__c();
        lVehicle.phone__c = '21967464736';
        lVehicle.secondaryphone__c = '1198987989';
        lVehicle.TypeModal__c = null;
        lVehicle.Provider__c = lProvider.Id;
        lVehicle.TypeRegistration__c = '6';
        lVehicle.Company__c = '35;1;84';
        lVehicle.Name = 'HONDA CIVIC';
        lVehicle.YearManufacture__c = '1995';
        lVehicle.plate__c = lPlate;
        lVehicle.Chassi__c = lChassi;
        lVehicle.Color__c = '1';
        lVehicle.TypeFuel__c = '2';
        lVehicle.RenavamCode__c = '10293847564';
        lVehicle.TypeAcquisition__c = '2';
        lVehicle.IPVA__c = 'Pendente';
        lVehicle.TrafficFines__c = 'Consta';
        //lVehicle.OwnerId = lQueue.Id;
        lVehicle.Restrictions__c = 'NADA CONSTA'; 
        lVehicle.Nonstop__c = 'Sim';
        lVehicle.StandardVehicle__c = 'Sim';
        lVehicle.Step__c = 'Step2';
        lVehicle.VehicleStatus__c = STATUS_IN_DEPLOYMENT;
        lVehicle.InsuranceAuto__c = INSURANCE_AUTO;
        lVehicle.SurveyStatus__c = SURVEY_STATUS;
        insert lVehicle;
        
        String lJson = JSON.serialize(lVehicle);
        
        Test.startTest();     
        	Vehicle__c lResult = VehicleRegistrationWizard_ctr.saveVehicle(lJson,lVehicle.Step__c, lVehicle.Company__c.split(';'));
        Test.stopTest();
        System.assert(lResult.Step__c == 'Step3', 'Esperava-se Spep3 mas retornou: ' + lResult.Step__c);
        
    }
    
    /*
    @isTest
    static void saveVehicleStep2Standard(){
        
        String lPlate = 'CEI0781';
        String lChassi = 'VF37CNFZ2SP733288';
        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lSeguroVeiculoConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SeguroVeiculo'];
		WebserviceConfiguration__mdt lEquipmentConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Equipment];        
        WebserviceConfiguration__mdt lVeiculoConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Vehicle];
        WebserviceConfiguration__mdt lModalConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Modal']; 
        
		String lParametersInsurance = '?placa=' + lPlate + '&chassi=' + lChassi;        
        String lInsuranceEndpoint = lSeguroVeiculoConf.EndPoint__c+lParametersInsurance;
        System.debug('lInsuranceEndpoint: '+lInsuranceEndpoint);
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,'Token');
        lMultimock.setStaticResource(lInsuranceEndpoint,'InsuranceAuto');
        lMultimock.setStaticResource(lEquipmentConf.EndPoint__c,'MockAWSSuccess');
        lMultimock.setStaticResource(lModalConf.EndPoint__c,'ModalLegacy');
        lMultimock.setStaticResource(lVeiculoConf.EndPoint__c,'VehicleLegacy');
        lMultimock.setStatusCode(201);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
        
        List<Modal__c> lModalLst = new List<Modal__c>();
        lModalLst.add(ModalFactory.createModalMotorcycle('Modal'));
        lModalLst.add(ModalFactory.createModalResidential('Modal1'));
        lModalLst.add(ModalFactory.createModalSustainable('Modal2'));
        lModalLst.add(ModalFactory.createModalTaxi('Modal3'));
        insert lModalLst;
        
        OperationalSetup__c lOPEquipament = OperationalSetupFactory.createOperationalSetupEquipamento();
		insert lOPEquipament;

        OperationalSetup__c lOPSupply = OperationalSetupFactory.createOperationalSetupSupply();
        insert lOPSupply;

        List<Equipment__c> lEquipmentLst = new List<Equipment__c>();
        List<Supply__c> lSupplyLst = new List<Supply__c>();
        
        for(Modal__c lModal: lModalLst){
            Equipment__c lEquipament = new Equipment__c();
        	lEquipament.Modal__c = lModal.Id;
            lEquipament.OperationalSetup__c = lOPEquipament.Id;
            lEquipmentLst.add(lEquipament);
            
            Supply__c lSupply = new Supply__c();
            lSupply.Modal__c = lModal.Id;
            lSupply.OperationalSetup__c = lOPSupply.Id;
            lSupplyLst.add(lSupply);
            
            lModal.Status__c = Label.Status_Active;

        }
        insert lEquipmentLst;
        insert lSupplyLst;
        
        update lModalLst;
        
        Account lProvider = AccountFactory.createAccountProvider();
        Insert lProvider;
        
        Group lQueue = new Group(Name='Sustentação', Type='Queue');
		insert lQueue;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = lQueue.id, SObjectType = 'Vehicle__c');
            insert testQueue;
        }

        
        Vehicle__c lVehicle = new Vehicle__c();
        lVehicle.phone__c = '21967464736';
        lVehicle.secondaryphone__c = '1198987989';
        lVehicle.TypeModal__c = lModalLst[0].Id;
        lVehicle.Provider__c = lProvider.Id;
        lVehicle.TypeRegistration__c = '6';
        lVehicle.Company__c = '35;1;84';
        lVehicle.Name = 'HONDA CIVIC';
        lVehicle.YearManufacture__c = '1995';
        lVehicle.plate__c = lPlate;
        lVehicle.Chassi__c = lChassi;
        lVehicle.Color__c = '1';
        lVehicle.TypeFuel__c = '2';
        lVehicle.RenavamCode__c = '10293847564';
        lVehicle.TypeAcquisition__c = '2';
        lVehicle.IPVA__c = 'Pendente';
        lVehicle.TrafficFines__c = 'Consta';
        //lVehicle.OwnerId = lQueue.Id;
        lVehicle.Restrictions__c = 'NADA CONSTA'; 
        lVehicle.Nonstop__c = 'Sim';
        lVehicle.StandardVehicle__c = 'Não';
        lVehicle.Step__c = 'Step3';
        lVehicle.VehicleStatus__c = STATUS_IN_DEPLOYMENT;
        lVehicle.InsuranceAuto__c = INSURANCE_AUTO;
        lVehicle.SurveyStatus__c = SURVEY_STATUS;
        insert lVehicle;
        
        
        String lJson = JSON.serialize(lVehicle);
        
        Test.startTest();     
        	Vehicle__c lResult = VehicleRegistrationWizard_ctr.saveVehicle(lJson,lVehicle.Step__c, lVehicle.Company__c.split(';'));
        Test.stopTest();
        System.assertEquals(lResult.Step__c, 'Step4');        
    }
	*/
}