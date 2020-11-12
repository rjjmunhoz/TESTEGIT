@isTest
public with sharing class VehicleInsuranceAutoSurveyStatus_bch_tst {
    private static final String STATUS_IN_DEPLOYMENT = Label.Status_Deployment ;
	private static final String SURVEY_STATUS = Label.Status_NotReleased;
    private static final String INSURANCE_AUTO = Label.Status_Inactive;

    @TestSetup
    static void makeData(){
        Vehicle__c lVehicle = VehicleFactory.createVehicle();
        lVehicle.plate__c = 'FSB7222';
        lVehicle.chassi__c = '9BM979028DS020620';
        lVehicle.VehicleStatus__c = STATUS_IN_DEPLOYMENT;
        lVehicle.InsuranceAuto__c = INSURANCE_AUTO;
        lVehicle.SurveyStatus__c = SURVEY_STATUS;
        insert lVehicle;
    }

    @isTest 
    static void vehicleInsuranceAutoSurveyStatus(){        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lSeguroVeiculoConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.String_VehicleInsurance];
        
        String lParametersInsurance = 'FSB72229BM979028DS020620';
        String lInsuranceEndpoint = lSeguroVeiculoConf.EndPoint__c+lParametersInsurance;
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,Label.String_Token);
        lMultimock.setStaticResource(lInsuranceEndpoint,Label.SetResourceInsuranceAuto);
        lMultimock.setStatusCode(201);
        lMultimock.setHeader(Label.String_Content_Type, Label.String_Application_JSON);
        Test.setMock(HttpCalloutMock.class, lMultimock);

        VehicleInsuranceAutoSurveyStatus_sch_bch lSb = new VehicleInsuranceAutoSurveyStatus_sch_bch();
	    String sch = '0 0 6/12/18 * * ? * ';
	    String jobID = system.schedule('Vehicle Insurance Auto and Survey Status', sch, lSb);

        Test.startTest();            
            VehicleInsuranceAutoSurveyStatus_sch_bch lVehicleInsuranceAutoSurveyStatus = new VehicleInsuranceAutoSurveyStatus_sch_bch();
		    Database.executeBatch(lVehicleInsuranceAutoSurveyStatus,10);
        Test.stopTest();

        System.assertEquals([SELECT chassi__c FROM Vehicle__c WHERE chassi__c = '9BM979028DS020620'].size(), 1);
    }
}