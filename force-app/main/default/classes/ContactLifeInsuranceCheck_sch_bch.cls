/**************************************************************************************************************
* Avanxo Brasil
* @author           Eduardo Costa (eborges@avanxo.com)
* Project:          Porto Socorro 
* Description:      Scheduler/Batch que verifica os planos de seguro de vida dos Socorristas com planos não ativos ou vigentes
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-08-03      Eduardo Costa           class created 
**************************************************************************************************************/
public class ContactLifeInsuranceCheck_sch_bch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {
    
    private static final Id BASE_EMPLOYEES_RECTYPE = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.BaseEmployeesRecordType).getRecordTypeId();    
    private static final String PROVIDER_TYPE_DEFAULT = Label.ProviderTypeDefault;   
    private static final String ROLE_GESTOR = Label.RoleGestor;    
	private static final String ROLE_RESCUER = Label.RoleRescuer; 
    private static final String ROLE_ADMINISTRATIVO = Label.RoleAdministrative;  
	private static final String STATUS_IN_DEPLOYMENT = Label.Status_Deployment;
    private static final String STATUS_ACTIVE = Label.Status_Active;
    private static final String STATUS_RELEASED = Label.Status_Released;
    private static final String STATUS_RELEASED_RADAR = Label.String_L;
    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();

	/* ContactLifeInsuranceCheck_sch_bch lSb = new ContactLifeInsuranceCheck_sch_bch();
	String lSch = '0 0 12 * * ? * ';
	String jobID = system.schedule('Contact Life Insurance Check', lSch, lSb);*/

	public void execute(SchedulableContext sc) {
		ContactLifeInsuranceCheck_sch_bch lContactLifeInsuranceCheckBatch = new ContactLifeInsuranceCheck_sch_bch();
		Database.executeBatch(lContactLifeInsuranceCheckBatch,10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT CPF__c, StartTerm__c FROM Contact 
            WHERE CPF__c != null 
            AND LifeInsurance__c != :Label.String_A
            AND ProviderType__c = :PROVIDER_TYPE_DEFAULT
            AND Role__c NOT IN (:ROLE_GESTOR, :ROLE_ADMINISTRATIVO)
            AND RecordTypeId = :BASE_EMPLOYEES_RECTYPE
            AND Status__c IN (:STATUS_ACTIVE,:STATUS_IN_DEPLOYMENT)
            AND (StatusRadar__c = :STATUS_RELEASED_RADAR OR RisksStatus__c = :STATUS_RELEASED)]);
	}

   	public void execute(Database.BatchableContext BC, List<Contact> aContactLst) { 

        //é pego o id da regra de atribuição de caso para se a integração quebrar, será criado um registro de caso e definido a regra de atribuição a ele. 
        //(Regra de atribuição não roda sozinha quando o registro é criado via APEX) 
        //https://help.salesforce.com/articleView?id=000338182&type=1&mode=1
        List<AssignmentRule>  lAssigmentRuleIdLst = [SELECT Id FROM AssignmentRule WHERE SobjectType = :Label.SObjectNameCase and Active = true];
        List<Case> lLogToInsertLst = new List<Case>();
        for(Contact lContact :aContactLst) {
            try {
                List<ContactLifeInsuranceWebService.ContactLifeInsurance> lContactLifeInsuranceLst = new ContactLifeInsuranceWebService().getContactLifeInsurance(lContact.CPF__c,lAssigmentRuleIdLst[0].Id);

                if(lContactLifeInsuranceLst != null && !lContactLifeInsuranceLst.isEmpty()) {
                    // Orderna pelos planos ativos mais recentes
                    lContactLifeInsuranceLst.sort();
                    if(String.isNotBlank(lContactLifeInsuranceLst[0].DataInicioVigenciaSegurado)) {
                        lContact.StartTerm__c = Date.valueOf(lContactLifeInsuranceLst[0].DataInicioVigenciaSegurado.split('T')[0]);
                    }
                    else {
                        lContact.StartTerm__c = null;
                    }   
                    lContact.LifeInsurance__c = lContactLifeInsuranceLst[0].StatusSegurado;
                    lContact.StipulantNumber__c = lContactLifeInsuranceLst[0].NumeroEstipulante;
                }
            }
            catch(Exception e) {
                Database.DMLOptions lDMLOptions = new Database.DMLOptions();
                lDMLOptions.EmailHeader.triggerUserEmail = true;
                lDMLOptions.assignmentRuleHeader.assignmentRuleId = lAssigmentRuleIdLst[0].Id;
                Case lCase = new Case(Subject = Label.String_StatusCode + ' ' + e.getCause(), Status = Label.String_OnHold , RecordCode__c = lContact.CPF__c, Description = e.getMessage(), ObjectType__c = Label.ObjectLifeRescuer, RecordTypeId = SUPPORT_API, Origin = Label.FieldValueIntegrationFailure);
                lCase.setOptions(lDMLOptions);

                lLogToInsertLst.add(lCase);
            }   
        }
        
        update aContactLst;

        if(!lLogToInsertLst.isEmpty()) insert lLogToInsertLst;
   		
	}
	
	public void finish(Database.BatchableContext BC) {}
}