/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de OperationalService
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-06-11      Mariana Ribeiro         class created 
**************************************************************************************************************/
@isTest
public class EquipamentVehicleHandler_tst {

    @isTest
    static void checkSurveyInsuranceAuto(){
        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lVeiculoConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Vehicle];
        WebserviceConfiguration__mdt lEquipmentConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Equipment];        
        WebserviceConfiguration__mdt lModalConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'Modal'];
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,'Token');
        lMultimock.setStaticResource(lVeiculoConf.EndPoint__c,'VehicleLegacy');
        lMultimock.setStaticResource(lEquipmentConf.EndPoint__c,'MockAWSSuccess');
        lMultimock.setStaticResource(lModalConf.EndPoint__c,'ModalLegacy');
        lMultimock.setStatusCode(201);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
       
        String lReturnMsg;//Mensagem de erro
        
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
        
        Vehicle__c lVehicle = new Vehicle__c();
        lVehicle.phone__c = '21967464736';
        lVehicle.secondaryphone__c = '1198987989';
        lVehicle.TypeModal__c = lModalLst[0].Id;
        lVehicle.Provider__c = lProvider.Id;
        lVehicle.TypeRegistration__c = '6';
        lVehicle.Company__c = '35;1;84';
        lVehicle.Name = 'HONDA CIVIC';
        lVehicle.YearManufacture__c = '1995';
        lVehicle.plate__c = 'CEI0781';
        lVehicle.Chassi__c = 'VF37CNFZ2SP733288';
        lVehicle.Color__c = '1';
        lVehicle.TypeFuel__c = '2';
        lVehicle.RenavamCode__c = '10293847564';
        lVehicle.TypeAcquisition__c = '2';
        lVehicle.IPVA__c = 'Pendente';
        lVehicle.TrafficFines__c = 'Consta';
        lVehicle.Restrictions__c = 'NADA CONSTA'; 
        lVehicle.Nonstop__c = 'Sim';
        lVehicle.Standardization__c ='Sim';
        lVehicle.Step__c = Label.String_Step4;
        lVehicle.SurveyStatus__c = Label.Status_Released;
        lVehicle.InsuranceAuto__c = Label.Status_Active;
        lVehicle.Standardization__c = Label.String_Yes;
        lVehicle.VehicleStatus__c = Label.Status_Active;
        insert lVehicle;
        
        lOPEquipament.Status__c = Label.Status_Active;
        update lOPEquipament;
        
        EquipamentVehicle__c lJunction = new EquipamentVehicle__c();
        lJunction.Vehicle__c = lVehicle.Id;
        lJunction.Equipament__c = lOPEquipament.Id;        
        
        
        Test.startTest();  
        	try{
            	insert lJunction;
        	}
        	catch(Exception e){
            	lReturnMsg = Label.String_Insert_Failed + ' ' + e.getMessage();
        	}
        Test.stopTest();
        system.assertEquals(Label.Status_Active, [SELECT VehicleStatus__c FROM Vehicle__c WHERE Id = :lVehicle.Id].VehicleStatus__c);
        
        EquipamentVehicle__c lJunctionTwo = new EquipamentVehicle__c();
        lJunctionTwo.Vehicle__c = lVehicle.Id;
        lJunctionTwo.Equipament__c = lOPEquipament.Id;  

        try{
            insert lJunctionTwo;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains(Label.MessageError_JunctionEquipamentVehicle) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    
    @isTest
    static void checkSurveyInsuranceAutoDelete(){
        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lVeiculoConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Vehicle];
        WebserviceConfiguration__mdt lEquipmentConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Equipment];        
        WebserviceConfiguration__mdt lModalConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :'Modal']; 
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,'Token');
        lMultimock.setStaticResource(lVeiculoConf.EndPoint__c,'VehicleLegacy');
        lMultimock.setStaticResource(lEquipmentConf.EndPoint__c,'MockAWSSuccess');
        lMultimock.setStaticResource(lModalConf.EndPoint__c,'ModalLegacy');
        lMultimock.setStaticResource( Url.getOrgDomainUrl().toExternalForm() + '/services/data/v46.0/actions/standard/customNotificationAction','BellNotification');
        lMultimock.setStatusCode(201);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
       
        String lReturnMsg;//Mensagem de erro
        
        Vehicle__c lVehicle = VehicleFactory.createVehicle();
        lVehicle.Step__c = Label.String_Step4;
        lVehicle.SurveyStatus__c = Label.Status_Released;
        lVehicle.InsuranceAuto__c = Label.Status_Active;
        lVehicle.VehicleStatus__c = Label.Status_Deployment;
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
        
        System.debug('lVehicle.VehicleStatus__c: '+lVehicle.VehicleStatus__c);
        
        
        Test.startTest();  
        	try{
            	delete lJunction;
        	}
        	catch(Exception e){
            	lReturnMsg = Label.String_Insert_Failed + ' ' + e.getMessage();
        	}
        Test.stopTest();
        system.assertEquals(Label.Status_Inactive, [SELECT VehicleStatus__c FROM Vehicle__c WHERE Id = :lVehicle.Id].VehicleStatus__c);
        
    }

    @isTest
    static void deleteJunctionProviderEquipament(){
        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lVeiculoConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Vehicle];
        WebserviceConfiguration__mdt lEquipmentConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Equipment];        
        WebserviceConfiguration__mdt lModalConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :'Modal']; 
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,'Token');
        lMultimock.setStaticResource(lVeiculoConf.EndPoint__c,'VehicleLegacy');
        lMultimock.setStaticResource(lEquipmentConf.EndPoint__c,'MockAWSSuccess');
        lMultimock.setStaticResource(lModalConf.EndPoint__c,'ModalLegacy');
        lMultimock.setStaticResource( Url.getOrgDomainUrl().toExternalForm() + '/services/data/v46.0/actions/standard/customNotificationAction','BellNotification');
        lMultimock.setStatusCode(201);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
       
        String lReturnMsg;//Mensagem de erro
        
        Vehicle__c lVehicle = VehicleFactory.createVehicle();
        lVehicle.Step__c = Label.String_Step4;
        lVehicle.SurveyStatus__c = Label.Status_Released;
        lVehicle.InsuranceAuto__c = Label.Status_Active;
        lVehicle.VehicleStatus__c = Label.Status_Deployment;
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

        /* ProviderEquipment__c lJunctionProvider = new ProviderEquipment__c();
        lJunctionProvider.Provider__c = lVehicle.Provider__c;
        lJunctionProvider.Equipment__c = lEquipament.Id;        
        insert lJunctionProvider; */
        
        EquipamentVehicle__c lJunction = new EquipamentVehicle__c();
        lJunction.Vehicle__c = lVehicle.Id;
        lJunction.Equipament__c = lEquipament.Id;        
        insert lJunction;

        lJunction.isActive__c = false;
        
        System.debug('lVehicle.VehicleStatus__c: '+lVehicle.VehicleStatus__c);
        
        
        Test.startTest();  
        	try{
            	update lJunction;
        	}
        	catch(Exception e){
            	lReturnMsg = Label.String_Insert_Failed + ' ' + e.getMessage();
        	}
        Test.stopTest();
        system.assertEquals(false, [SELECT isActive__c FROM ProviderEquipment__c WHERE Equipment__c = :lEquipament.Id AND Provider__c = : lVehicle.Provider__c].isActive__c);
        
    }

    @isTest
    static void deleteJunctionProviderEquipament2(){
        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lVeiculoConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Vehicle];
        WebserviceConfiguration__mdt lEquipmentConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_Equipment];        
        WebserviceConfiguration__mdt lModalConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :'Modal']; 
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,'Token');
        lMultimock.setStaticResource(lVeiculoConf.EndPoint__c,'VehicleLegacy');
        lMultimock.setStaticResource(lEquipmentConf.EndPoint__c,'MockAWSSuccess');
        lMultimock.setStaticResource(lModalConf.EndPoint__c,'ModalLegacy');
        lMultimock.setStaticResource( Url.getOrgDomainUrl().toExternalForm() + '/services/data/v46.0/actions/standard/customNotificationAction','BellNotification');
        lMultimock.setStatusCode(201);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
       
        String lReturnMsg;//Mensagem de erro
        
        Vehicle__c lVehicle = VehicleFactory.createVehicle();
        lVehicle.Step__c = Label.String_Step4;
        lVehicle.SurveyStatus__c = Label.Status_Released;
        lVehicle.InsuranceAuto__c = Label.Status_Active;
        lVehicle.VehicleStatus__c = Label.Status_Deployment;
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

        OperationalSetup__c lEquipament2 = new OperationalSetup__c();
        lEquipament2.RecordTypeId = OSRecordType;
        lEquipament2.Name = 'Equipamento de teste 2';
        lEquipament2.EquipmentType__c = 'Acessórios';
        lEquipament2.Description__c = 'teste2';
        lEquipament2.Brand__c = 'Mondial';
        lEquipament2.SafetyEquipment__c = 'Sim';
        lEquipament2.Quantity__c = 7;
        lEquipament2.EquipmentReturned__c = 'Sim';
        lEquipament2.Status__c = 'Ativo';
        insert lEquipament2;

        ProviderEquipment__c lJunctionProvider = new ProviderEquipment__c();
        lJunctionProvider.Provider__c = lVehicle.Provider__c;
        lJunctionProvider.Equipment__c = lEquipament.Id;        
        insert lJunctionProvider; 
        
        ProviderEquipment__c lJunctionProvider2 = new ProviderEquipment__c();
        lJunctionProvider2.Provider__c = lVehicle.Provider__c;
        lJunctionProvider2.Equipment__c = lEquipament2.Id;
        lJunctionProvider2.IsActive__c = false;
        insert lJunctionProvider2; 
        
        EquipamentVehicle__c lJunction = new EquipamentVehicle__c();
        lJunction.Vehicle__c = lVehicle.Id;
        lJunction.Equipament__c = lEquipament.Id;        
        insert lJunction;

        EquipamentVehicle__c lJunction2 = new EquipamentVehicle__c();
        lJunction2.Vehicle__c = lVehicle.Id;
        lJunction2.Equipament__c = lEquipament2.Id;
		lJunction2.IsActive__c = false;        
        insert lJunction2;

        List<EquipamentVehicle__c> lEquipVehicleLst = new List<EquipamentVehicle__c>();
        lEquipVehicleLst.add(lJunction);
        lEquipVehicleLst.add(lJunction2);

        System.debug('lVehicle.VehicleStatus__c: '+lVehicle.VehicleStatus__c);

        for(EquipamentVehicle__c lEquipamentVehicle: lEquipVehicleLst){
            if(lEquipamentVehicle.Equipament__c == lEquipament.Id){
                lEquipamentVehicle.isActive__c = false;
            }
            else{
                lEquipamentVehicle.isActive__c = true;
            }
        }
        
        Test.startTest();  
        	try{
            	update lEquipVehicleLst;
        	}
        	catch(Exception e){
            	lReturnMsg = Label.String_Insert_Failed + ' ' + e.getMessage();
        	}
        Test.stopTest();
        
        system.debug('teste primeiro assert: ' + [SELECT isActive__c FROM ProviderEquipment__c WHERE Equipment__c = :lEquipament.Id AND Provider__c = : lVehicle.Provider__c].isActive__c);
        system.debug('teste segundo assert: ' + [SELECT isActive__c FROM ProviderEquipment__c WHERE Equipment__c = :lEquipament2.Id AND Provider__c = : lVehicle.Provider__c].isActive__c);
        
        system.assertEquals(false, [SELECT isActive__c FROM ProviderEquipment__c WHERE Equipment__c = :lEquipament.Id AND Provider__c = : lVehicle.Provider__c].isActive__c);
        system.assertEquals(true, [SELECT isActive__c FROM ProviderEquipment__c WHERE Equipment__c = :lEquipament2.Id AND Provider__c = : lVehicle.Provider__c].isActive__c);
        
        
    }
}