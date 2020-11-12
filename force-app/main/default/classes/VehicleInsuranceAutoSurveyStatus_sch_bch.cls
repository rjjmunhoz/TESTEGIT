/**************************************************************************************************************
* Avanxo Brasil
* @author           Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro 
* Description:      Scheduler/Batch que verifica os planos de seguro e vistoria de automóvel
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-03-24      Mariana Ribeiro           class created 
**************************************************************************************************************/
public class VehicleInsuranceAutoSurveyStatus_sch_bch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {
    
    private static final String STATUS_IN_DEPLOYMENT = Label.Status_Deployment;
    private static final String INSURANCE_AUTO = Label.Status_Inactive;
    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();
    
    /* VehicleInsuranceAutoSurveyStatus_sch_bch sb = new VehicleInsuranceAutoSurveyStatus_sch_bch();
	String sch = '0 0 6 * * ? * ';
	String jobID = system.schedule('Vehicle Insurance Auto and Survey Status', sch, sb);*/
  

	public void execute(SchedulableContext sc) {
		VehicleInsuranceAutoSurveyStatus_sch_bch lVehicleInsuranceAutoSurveyStatus = new VehicleInsuranceAutoSurveyStatus_sch_bch();
		Database.executeBatch(lVehicleInsuranceAutoSurveyStatus,10);
	}

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Code__c, InsuranceAuto__c, policy__c, BranchCode__c, InsuranceExpiration__c, ModelCode__c, plate__c, Chassi__c, VehicleStatus__c FROM Vehicle__c 
            WHERE  VehicleStatus__c = :STATUS_IN_DEPLOYMENT AND InsuranceAuto__c = :INSURANCE_AUTO]);
	}

   	public void execute(Database.BatchableContext BC, List<Vehicle__c> aVehicleLst) { 

        //é pego o id da regra de atribuição de caso para se a integração quebrar, será criado um registro de caso e definido a regra de atribuição a ele. 
        //(Regra de atribuição não roda sozinha quando o registro é criado via APEX) 
        //https://help.salesforce.com/articleView?id=000338182&type=1&mode=1
        List<AssignmentRule>  lAssigmentRuleIdLst = [SELECT Id FROM AssignmentRule WHERE SobjectType = :Label.SObjectNameCase and Active = true];
        Database.DMLOptions lDMLOptions = new Database.DMLOptions();
        lDMLOptions.EmailHeader.triggerUserEmail = true;
        lDMLOptions.assignmentRuleHeader.assignmentRuleId = lAssigmentRuleIdLst[0].Id;
        List<Case> lCaseToInsertLst = new List<Case>();

        for(Vehicle__c lVehicle :aVehicleLst) {
            try {
                Vehicle__c lVehicleInsuranceAuto = new VehicleInsuranceAutoWebService_cls().getInsuranceAutoStatus(lVehicle.plate__c,lVehicle.Chassi__c, lAssigmentRuleIdLst[0].Id, lVehicle.Code__c);

                if(lVehicleInsuranceAuto != null) {
                    lVehicle.InsuranceAuto__c = lVehicleInsuranceAuto.InsuranceAuto__c;
                    lVehicle.policy__c = lVehicleInsuranceAuto.policy__c;
                    lVehicle.BranchCode__c = lVehicleInsuranceAuto.BranchCode__c;
                    lVehicle.InsuranceExpiration__c = lVehicleInsuranceAuto.InsuranceExpiration__c;
                    lVehicle.ModelCode__c = lVehicleInsuranceAuto.ModelCode__c;
                }
            }
            catch(Exception e) {
                Case lCase = new Case(Subject = Label.String_StatusCode, Status = Label.String_OnHold , RecordCode__c = String.valueOf(lVehicle.Code__c), Description = 'Erro ao Pesquisar Seguro Auto', ObjectType__c = 'Pesquisa seguro auto (Vehicle__c)', RecordTypeId = SUPPORT_API, Origin = Label.FieldValueIntegrationFailure);
                lCase.setOptions(lDMLOptions);
                lCaseToInsertLst.add(lCase);
            }   
        }
        
        update aVehicleLst;

        if(!lCaseToInsertLst.isEmpty()) insert lCaseToInsertLst;
   		
	}
	
	public void finish(Database.BatchableContext BC) {}
}