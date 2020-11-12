/**************************************************************************************************************
* Avanxo Brasil
* @author           Eduardo Costa (eborges@avanxo.com)
* Project:          Porto Socorro 
* Description:      Classe de teste do Scheduler/Batch que verifica os planos de seguro de vida dos Socorristas 
*                   com planos não ativos ou vigentes
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-03-26      Eduardo Costa           class created 
**************************************************************************************************************/
@isTest
public class ContactLifeInsuranceCheck_sch_bch_tst {
     
	private static final String RESCUER_ROLE = Label.RoleRescuer; 
	private static final String STATUS_IN_DEPLOYMENT = Label.Status_Deployment;
    private static final String STATUS_ACTIVE = Label.Status_Active;
    private static final String STATUS_RELEASED = 'L';
    private static final String PROVIDER_TYPE_DEFAULT = '1'; 

    @TestSetup
    static void makeData(){
        Account lAccount = AccountFactory.createAccountProvider();
        lAccount.ProviderType__c = PROVIDER_TYPE_DEFAULT;
        insert lAccount;
        
        Contact lContact = (Contact)new ContactFactory.BaseEmployees(lAccount.Id).getRecord();    
        lContact.Status__c = STATUS_IN_DEPLOYMENT;
        lContact.StatusRadar__c = STATUS_RELEASED;
        lContact.LifeInsurance__c = null;
        lContact.Role__c = RESCUER_ROLE;
        lContact.CPF__c = '601711548';
        lContact.LifeInsurance__c = null;
        lContact.StipulantNumber__c = null;
        lContact.StartTerm__c = null;
        insert lContact;
    }

    @isTest 
    static void contactLifeInsuranceCheckCurrent(){        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lSocorristasVidaConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SocorristasVida'];
        
        List<Object> lParameters = new List<Object> {'601711548'};
        String lSocorristasVidaEndpoint = String.format(lSocorristasVidaConf.EndPoint__c, lParameters);
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,'Token');
        lMultimock.setStaticResource(lSocorristasVidaEndpoint,'MockSocorristasVida');
        lMultimock.setStatusCode(200);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);

        ContactLifeInsuranceCheck_sch_bch lSb = new ContactLifeInsuranceCheck_sch_bch();
        String lSch = '0 0 0 * * ?';
        String jobID = system.schedule('Contact Life Insurance Check Test', lSch, lSb);

        Test.startTest();            
            ContactLifeInsuranceCheck_sch_bch lContactLifeInsuranceCheckBatch = new ContactLifeInsuranceCheck_sch_bch();
		    Database.executeBatch(lContactLifeInsuranceCheckBatch,10);
        Test.stopTest();

        System.assert(![SELECT Id FROM Contact WHERE CPF__c = '601711548' AND LifeInsurance__c != null AND StipulantNumber__c != null AND StartTerm__c != null].isEmpty(), 'Erro ao atribuir o seguro de vida ao colaborador');
    }
    
    @isTest 
    static void contactLifeInsuranceCheckCurrentError(){        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lSocorristasVidaConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SocorristasVida'];
        
        List<Object> lParameters = new List<Object> {'601711548'};
        String lSocorristasVidaEndpoint = String.format(lSocorristasVidaConf.EndPoint__c, lParameters);
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,'Token');
        lMultimock.setStaticResource(lSocorristasVidaEndpoint,'MockSocorristasVida');
        lMultimock.setStatusCode(501);
        lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);

        ContactLifeInsuranceCheck_sch_bch lSb = new ContactLifeInsuranceCheck_sch_bch();
        String lSch = '0 0 0 * * ?';
        String jobID = system.schedule('Contact Life Insurance Check Test', lSch, lSb);

        Test.startTest();            
            ContactLifeInsuranceCheck_sch_bch lContactLifeInsuranceCheckBatch = new ContactLifeInsuranceCheck_sch_bch();
		    Database.executeBatch(lContactLifeInsuranceCheckBatch,10);
        Test.stopTest();

    }

}