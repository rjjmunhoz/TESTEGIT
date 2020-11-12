/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Dados Cadastrais PF Serasa
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-01-31      Eduardo Costa           class created 
**************************************************************************************************************/
public with sharing class RegistrationDataSerasaPFWebService extends AWS_API {

	private static final Id BASE_EMPLOYEES_RECTYPE = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.BaseEmployeesRecordType).getRecordTypeId();
    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();
	
    private static final String RegistrationDataSerasaPF = Label.String_RegistrationDataSerasaPF;

    public String status;
	public String data_de_atualizacao;
	public String origem_informacao;
	public String logr_COMPLEMENTO2_ENR;
	public String logr_NOME1_ENR;
	public String logr_NOME2_ENR;
	public String cidade3_ENR;
	public String dddcel3_ENR;
	public String bairro3_ENR;
	public String cidade1_ENR;
	public String fone1_ENR;
	public String dddcel2_ENR;
	public String logr_TITULO2_ENR;
	public String cel3_ENR;
	public String cep3_ENR;
	public String cep2_ENR;
	public String logr_TITULO1_ENR;
	public String ddd3_ENR;
	public String ddd2_ENR;
	public String orgao_EMISSOR_ENR;
	public String logr_NUMERO2_ENR;
	public String fone2_ENR;
	public String logr_COMPLEMENTO1_ENR;
	public String uf1_ENR;
	public String fone3_ENR;
	public String endereco2_ENR;
	public String cpf_DIGITO;
	public String bairro2_ENR;
	public String nome_ENR;
	public String cel1_ENR;
	public String uf3_ENR;
	public String bairro1_ENR;
	public String dddcel1_ENR;
	public String endereco3_ENR;
	public String logr_TIPO2_ENR;
	public String cep1_ENR;
	public String nome_MAE_ENR;
	public String logr_COMPLEMENTO3_ENR;
	public String cel2_ENR;
	public String sexo_ENR;
	public String logr_TITULO3_ENR;
	public String logr_NOME3_ENR;
	public String cpf_RADICAL;
	public String ddd1_ENR;
	public String logr_TIPO1_ENR;
	public Date nascimento_ENR;
	public String logr_NUMERO3_ENR;
	public String uf_EMISSAO_ENR;
	public String logr_TIPO3_ENR;
	public String logr_NUMERO1_ENR;
	public String uf2_ENR;
	public String rg_ENR;
	public String endereco1_ENR;
	public String cidade2_ENR;

    public RegistrationDataSerasaPFWebService() {
        super(RegistrationDataSerasaPF);
    }

    public Contact getRegistrationDataSerasaPF(String aCPF){
		String lEndpoint = this.fReq.getEndpoint();
        List<Object> lParameters = new List<Object> {aCPF};
        this.fReq.setEndpoint(String.format(lEndpoint, lParameters));
		AWS_API.ResponseWrapper lResult =  this.doRequest();   
		system.debug('RegistrationDataSerasaPF Body: ' + lResult.response.getBody());                  
        if(!lResult.success) {
			//é pego o id da regra de atribuição de caso para se a integração quebrar, será criado um registro de caso e definido a regra de atribuição a ele. 
        	//(Regra de atribuição não roda sozinha quando o registro é criado via APEX) 
        	//https://help.salesforce.com/articleView?id=000338182&type=1&mode=1
        	List<AssignmentRule>  lAssigmentRuleIdLst = [SELECT Id FROM AssignmentRule WHERE SobjectType = :Label.SObjectNameCase and Active = true];
			Database.DMLOptions lDMLOptions = new Database.DMLOptions();
			lDMLOptions.EmailHeader.triggerUserEmail = true;
            lDMLOptions.assignmentRuleHeader.assignmentRuleId = lAssigmentRuleIdLst[0].Id;
            Case lCase = new Case(Subject = Label.String_StatusCode + ' ' + String.Valueof(lResult.response.getStatusCode()), Status = Label.String_OnHold , RecordCode__c = aCPF, Description = lResult.message, ObjectType__c = Label.FieldValueSearchCPF, RecordTypeId = SUPPORT_API, Origin = Label.FieldValueIntegrationFailure);
            lCase.setOptions(lDMLOptions);
            insert lCase;
            return null;
        }
        else {
            return getAccount((RegistrationDataSerasaPFWebService) System.JSON.deserialize(lResult.response.getBody(), RegistrationDataSerasaPFWebService.class));
        }  
	}

	public Contact getAccount(RegistrationDataSerasaPFWebService aContactInfos){
		Contact lContact = new Contact();
		lContact.CPF__c = aContactInfos.cpf_RADICAL + aContactInfos.cpf_DIGITO;	
		String lUpdateDate = String.isNotBlank(aContactInfos.data_de_atualizacao)?aContactInfos.data_de_atualizacao.split(' ')[0]:null;
		lContact.UpdateDate__c = String.isNotBlank(lUpdateDate)?Date.valueOf(lUpdateDate):null;
		lContact.CPFStatus__c = aContactInfos.status;
		//lContact.FatherName__c = aContactInfos.;
		lContact.MotherName__c = aContactInfos.nome_MAE_ENR;
		lContact.RG__c = aContactInfos.rg_ENR!=null?aContactInfos.rg_ENR.replaceAll('[^0-9]','').left(9):null;
		lContact.IssuingAgency__c = aContactInfos.orgao_EMISSOR_ENR;
		lContact.Birthdate = aContactInfos.nascimento_ENR;
		//lContact.Nationality__c = aContactInfos.;
		lContact.City__c = aContactInfos.cidade1_ENR;
		lContact.Uf__c = aContactInfos.uf1_ENR;
		lContact.Zip__c = aContactInfos.cep1_ENR;
		lContact.Complement__c = aContactInfos.logr_COMPLEMENTO1_ENR;
		lContact.Number__c = aContactInfos.logr_NUMERO1_ENR;
		lContact.Street__c = aContactInfos.logr_NOME1_ENR;
		lContact.Neighborhood__c = aContactInfos.bairro1_ENR;
		lContact.MobilePhone = aContactInfos.dddcel1_ENR + '' + aContactInfos.cel1_ENR;
		lContact.Phone = aContactInfos.dddcel1_ENR + '' + aContactInfos.fone1_ENR;

		if(!String.isBlank(aContactInfos.nome_ENR)){
			if(aContactInfos.nome_ENR.contains(' ') ) {
				lContact.FirstName = aContactInfos.nome_ENR.substringBefore(' ');
				lContact.LastName = aContactInfos.nome_ENR.substringAfter(' ');
			}
			else {
				lContact.LastName = aContactInfos.nome_ENR;
			}                
		}
		else{
			lContact.LastName = lContact.CPF__c;
		}
		lContact.RecordTypeId = BASE_EMPLOYEES_RECTYPE;
		return lContact;
	}
}