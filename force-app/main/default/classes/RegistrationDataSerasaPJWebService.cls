/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Dados Cadastrais PJ Serasa
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-01-30      Eduardo Costa           class created 
**************************************************************************************************************/
public with sharing class RegistrationDataSerasaPJWebService extends AWS_API {

    private static final String RegistrationDataSerasaPJ = Label.String_SerasaPJDadosCadastrais;
	private static final Id PARTNER_RECTYPE = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();

    public String data_de_atualizacao;

	public String cep1_ENR;
	public String cep2_ENR;
	public String cep3_ENR;

	public String cidade1_ENR;
	public String cidade2_ENR;
	public String cidade3_ENR;

	public String cnpj_DIGITO;
	public String cnpj_ORDEM;
	public String cnpj_RADICAL;

	public String data_FUNDACAO_ENR;

	public String endereco1_ENR;
	public String endereco2_ENR;
	public String endereco3_ENR;

	public String natureza_JURIDICA_ENR;

	public String nome_FANTASIA_ENR;

	public String razao_SOCIAL_ENR;
	public String status_receita;

	public String uf1_ENR;
	public String uf2_ENR;
	public String uf3_ENR;

	public String cnae_DESCRICAO_ENR;
	public String cnae_ENR;
	public String cnae_SECUNDARIO1_DESC_ENR;
	public String cnae_SECUNDARIO1_ENR;
	public String cnae_SECUNDARIO2_DESC_ENR;
	public String cnae_SECUNDARIO2_ENR;
	public String cnae_SECUNDARIO3_DESC_ENR;
	public String cnae_SECUNDARIO3_ENR;
	public String cnae_SECUNDARIO4_DESC_ENR;
	public String cnae_SECUNDARIO4_ENR;
	public String cnae_SECUNDARIO5_DESC_ENR;
	public String cnae_SECUNDARIO5_ENR;
	public String cnae_SECUNDARIO6_DESC_ENR;
	public String cnae_SECUNDARIO6_ENR;
	public String cnae_SECUNDARIO7_DESC_ENR;
	public String cnae_SECUNDARIO7_ENR;
	public String cnae_SECUNDARIO8_DESC_ENR;
	public String cnae_SECUNDARIO8_ENR;
	public String cnae_SECUNDARIO9_DESC_ENR;
	public String cnae_SECUNDARIO9_ENR;
	public String cnae_SECUNDARIO10_DESC_ENR;
	public String cnae_SECUNDARIO10_ENR;

	//Sócios (Contatos)
	public String cpf_CNPJ_SOCIO1_ENR;
	public String cpf_CNPJ_SOCIO2_ENR;
	public String cpf_CNPJ_SOCIO3_ENR;
	public String cpf_CNPJ_SOCIO4_ENR;
	public String cpf_CNPJ_SOCIO5_ENR;
	public String cpf_CNPJ_SOCIO6_ENR;
	public String cpf_CNPJ_SOCIO7_ENR;
	public String cpf_CNPJ_SOCIO8_ENR;
	public String cpf_CNPJ_SOCIO9_ENR;
	public String cpf_CNPJ_SOCIO10_ENR;

	public String nome_RAZAO_SOCIO1_ENR;
	public String nome_RAZAO_SOCIO2_ENR;
	public String nome_RAZAO_SOCIO3_ENR;
	public String nome_RAZAO_SOCIO4_ENR;
	public String nome_RAZAO_SOCIO5_ENR;
	public String nome_RAZAO_SOCIO6_ENR;
	public String nome_RAZAO_SOCIO7_ENR;
	public String nome_RAZAO_SOCIO8_ENR;
	public String nome_RAZAO_SOCIO9_ENR;
	public String nome_RAZAO_SOCIO10_ENR;
	
	public String participacao_SOCIO1_ENR;
	public String participacao_SOCIO2_ENR;
	public String participacao_SOCIO3_ENR;
	public String participacao_SOCIO4_ENR;
	public String participacao_SOCIO5_ENR;
	public String participacao_SOCIO6_ENR;
	public String participacao_SOCIO7_ENR;
	public String participacao_SOCIO8_ENR;
	public String participacao_SOCIO9_ENR;
	public String participacao_SOCIO10_ENR;
	
    public RegistrationDataSerasaPJWebService() {
        super(RegistrationDataSerasaPJ);
    }

    public AccountContactWrapper getRegistrationDataSerasaPJ(String aCNPJ){
		String lEndpoint = this.fReq.getEndpoint();
        List<Object> lParameters = new List<Object> {aCNPJ};
        this.fReq.setEndpoint(String.format(lEndpoint, lParameters));
		AWS_API.ResponseWrapper lResult =  this.doRequest();     
		system.debug('RegistrationDataSerasaPJ Body: ' + lResult.response.getBody());
        if(!lResult.success) {
			//é pego o id da regra de atribuição de caso para se a integração quebrar, será criado um registro de caso e definido a regra de atribuição a ele. 
        	//(Regra de atribuição não roda sozinha quando o registro é criado via APEX) 
        	//https://help.salesforce.com/articleView?id=000338182&type=1&mode=1
        	List<AssignmentRule>  lAssigmentRuleIdLst = [SELECT Id FROM AssignmentRule WHERE SobjectType = :Label.SObjectNameCase and Active = true];
			Database.DMLOptions lDMLOptions = new Database.DMLOptions();
        	lDMLOptions.EmailHeader.triggerUserEmail = true;
            lDMLOptions.assignmentRuleHeader.assignmentRuleId = lAssigmentRuleIdLst[0].Id;
            Case lCase = new Case(Subject = Label.String_StatusCode + ' ' + String.Valueof(lResult.response.getStatusCode()), Status = Label.String_OnHold , RecordCode__c = aCNPJ, Description = lResult.message, ObjectType__c = Label.FieldValueSearchCNPJ, RecordTypeId = SUPPORT_API, Origin = Label.FieldValueIntegrationFailure);
            lCase.setOptions(lDMLOptions);
            insert lCase;
            return null;
        }
        else {
			AccountContactWrapper lAccountReturn = getAccount((RegistrationDataSerasaPJWebService) System.JSON.deserialize(lResult.response.getBody(), RegistrationDataSerasaPJWebService.class), aCNPJ);
			// System.debug('lAccountReturn ' + lAccountReturn);
			return lAccountReturn;
			// return (RegistrationDataSerasaPJWebService) System.JSON.deserialize(lResult.response.getBody(), RegistrationDataSerasaPJWebService.class);
        }  
	}

	public AccountContactWrapper getAccount(RegistrationDataSerasaPJWebService aAccountInfos, String aCNPJ){
		AccountContactWrapper lReturn = new AccountContactWrapper();

		lReturn.lAcc.UpdateDate__c = aAccountInfos.data_de_atualizacao != null? Date.ValueOf(aAccountInfos.data_de_atualizacao) : null; 
		lReturn.lAcc.TaxZIP__c = aAccountInfos.cep1_ENR;
		lReturn.lAcc.TaxCity__c = aAccountInfos.cidade1_ENR;
		lReturn.lAcc.CNPJ__c = aCNPJ;
		lReturn.lAcc.CompanyStartDate__c = aAccountInfos.data_FUNDACAO_ENR != null? Date.ValueOf(aAccountInfos.data_FUNDACAO_ENR) : null; 
		lReturn.lAcc.TaxStreet__c = aAccountInfos.endereco1_ENR; 
		lReturn.lAcc.CompanyName__c = aAccountInfos.razao_SOCIAL_ENR;
		lReturn.lAcc.Name = String.isNotBlank(aAccountInfos.nome_FANTASIA_ENR)?aAccountInfos.nome_FANTASIA_ENR:aAccountInfos.razao_SOCIAL_ENR;
		lReturn.lAcc.CardSituation__c = aAccountInfos.status_receita != null? aAccountInfos.status_receita.capitalize() : aAccountInfos.status_receita;
		lReturn.lAcc.TaxUf__c = aAccountInfos.uf1_ENR;

		lReturn.lAcc.CNAE__c = aAccountInfos.cnae_ENR + '\n' + '\n';
		lReturn.lAcc.CNAE__c = aAccountInfos.cnae_SECUNDARIO1_ENR != null? lReturn.lAcc.CNAE__c + aAccountInfos.cnae_SECUNDARIO1_ENR + '\n' : lReturn.lAcc.CNAE__c;
		lReturn.lAcc.CNAE__c = aAccountInfos.cnae_SECUNDARIO2_ENR != null? lReturn.lAcc.CNAE__c + aAccountInfos.cnae_SECUNDARIO2_ENR + '\n' : lReturn.lAcc.CNAE__c;
		lReturn.lAcc.CNAE__c = aAccountInfos.cnae_SECUNDARIO3_ENR != null? lReturn.lAcc.CNAE__c + aAccountInfos.cnae_SECUNDARIO3_ENR + '\n' : lReturn.lAcc.CNAE__c;
		lReturn.lAcc.CNAE__c = aAccountInfos.cnae_SECUNDARIO4_ENR != null? lReturn.lAcc.CNAE__c + aAccountInfos.cnae_SECUNDARIO4_ENR + '\n' : lReturn.lAcc.CNAE__c;
		lReturn.lAcc.CNAE__c = aAccountInfos.cnae_SECUNDARIO5_ENR != null? lReturn.lAcc.CNAE__c + aAccountInfos.cnae_SECUNDARIO5_ENR + '\n' : lReturn.lAcc.CNAE__c;
		lReturn.lAcc.CNAE__c = aAccountInfos.cnae_SECUNDARIO6_ENR != null? lReturn.lAcc.CNAE__c + aAccountInfos.cnae_SECUNDARIO6_ENR + '\n' : lReturn.lAcc.CNAE__c;
		lReturn.lAcc.CNAE__c = aAccountInfos.cnae_SECUNDARIO7_ENR != null? lReturn.lAcc.CNAE__c + aAccountInfos.cnae_SECUNDARIO7_ENR + '\n' : lReturn.lAcc.CNAE__c;
		lReturn.lAcc.CNAE__c = aAccountInfos.cnae_SECUNDARIO8_ENR != null? lReturn.lAcc.CNAE__c + aAccountInfos.cnae_SECUNDARIO8_ENR + '\n' : lReturn.lAcc.CNAE__c;
		lReturn.lAcc.CNAE__c = aAccountInfos.cnae_SECUNDARIO9_ENR != null? lReturn.lAcc.CNAE__c + aAccountInfos.cnae_SECUNDARIO9_ENR + '\n' : lReturn.lAcc.CNAE__c;
		lReturn.lAcc.CNAE__c = aAccountInfos.cnae_SECUNDARIO10_ENR != null? lReturn.lAcc.CNAE__c + aAccountInfos.cnae_SECUNDARIO10_ENR + '\n' : lReturn.lAcc.CNAE__c;

		lReturn.lAcc.CNAEDescription__c = aAccountInfos.cnae_DESCRICAO_ENR + '\n' + '\n';
		lReturn.lAcc.CNAEDescription__c = aAccountInfos.cnae_SECUNDARIO1_DESC_ENR != null? lReturn.lAcc.CNAEDescription__c + aAccountInfos.cnae_SECUNDARIO1_DESC_ENR + '\n' + '\n' : lReturn.lAcc.CNAEDescription__c;
		lReturn.lAcc.CNAEDescription__c = aAccountInfos.cnae_SECUNDARIO2_DESC_ENR != null? lReturn.lAcc.CNAEDescription__c + aAccountInfos.cnae_SECUNDARIO2_DESC_ENR + '\n' + '\n' : lReturn.lAcc.CNAEDescription__c;
		lReturn.lAcc.CNAEDescription__c = aAccountInfos.cnae_SECUNDARIO3_DESC_ENR != null? lReturn.lAcc.CNAEDescription__c + aAccountInfos.cnae_SECUNDARIO3_DESC_ENR + '\n' + '\n' : lReturn.lAcc.CNAEDescription__c;
		lReturn.lAcc.CNAEDescription__c = aAccountInfos.cnae_SECUNDARIO4_DESC_ENR != null? lReturn.lAcc.CNAEDescription__c + aAccountInfos.cnae_SECUNDARIO4_DESC_ENR + '\n' + '\n' : lReturn.lAcc.CNAEDescription__c;
		lReturn.lAcc.CNAEDescription__c = aAccountInfos.cnae_SECUNDARIO5_DESC_ENR != null? lReturn.lAcc.CNAEDescription__c + aAccountInfos.cnae_SECUNDARIO5_DESC_ENR + '\n' + '\n' : lReturn.lAcc.CNAEDescription__c;
		lReturn.lAcc.CNAEDescription__c = aAccountInfos.cnae_SECUNDARIO6_DESC_ENR != null? lReturn.lAcc.CNAEDescription__c + aAccountInfos.cnae_SECUNDARIO6_DESC_ENR + '\n' + '\n' : lReturn.lAcc.CNAEDescription__c;
		lReturn.lAcc.CNAEDescription__c = aAccountInfos.cnae_SECUNDARIO7_DESC_ENR != null? lReturn.lAcc.CNAEDescription__c + aAccountInfos.cnae_SECUNDARIO7_DESC_ENR + '\n' + '\n' : lReturn.lAcc.CNAEDescription__c;
		lReturn.lAcc.CNAEDescription__c = aAccountInfos.cnae_SECUNDARIO8_DESC_ENR != null? lReturn.lAcc.CNAEDescription__c + aAccountInfos.cnae_SECUNDARIO8_DESC_ENR + '\n' + '\n' : lReturn.lAcc.CNAEDescription__c;
		lReturn.lAcc.CNAEDescription__c = aAccountInfos.cnae_SECUNDARIO9_DESC_ENR != null? lReturn.lAcc.CNAEDescription__c + aAccountInfos.cnae_SECUNDARIO9_DESC_ENR + '\n' + '\n' : lReturn.lAcc.CNAEDescription__c;
		lReturn.lAcc.CNAEDescription__c = aAccountInfos.cnae_SECUNDARIO10_DESC_ENR != null? lReturn.lAcc.CNAEDescription__c + aAccountInfos.cnae_SECUNDARIO10_DESC_ENR + '\n' + '\n' : lReturn.lAcc.CNAEDescription__c;

		//Coloca todos os CPFs, Nomes e Participações em uma lista, para criar os Contatos dinamicamente
		List<String> lContactInfosIntegration = new List<String>();
		lContactInfosIntegration.add(String.isNotBlank(aAccountInfos.cpf_CNPJ_SOCIO1_ENR) ? aAccountInfos.cpf_CNPJ_SOCIO1_ENR + ';' + aAccountInfos.nome_RAZAO_SOCIO1_ENR + ';' + aAccountInfos.participacao_SOCIO1_ENR : '');
		lContactInfosIntegration.add(String.isNotBlank(aAccountInfos.cpf_CNPJ_SOCIO2_ENR) ? aAccountInfos.cpf_CNPJ_SOCIO2_ENR + ';' + aAccountInfos.nome_RAZAO_SOCIO2_ENR + ';' + aAccountInfos.participacao_SOCIO2_ENR : '');
		lContactInfosIntegration.add(String.isNotBlank(aAccountInfos.cpf_CNPJ_SOCIO3_ENR) ? aAccountInfos.cpf_CNPJ_SOCIO3_ENR + ';' + aAccountInfos.nome_RAZAO_SOCIO3_ENR + ';' + aAccountInfos.participacao_SOCIO3_ENR : '');
		lContactInfosIntegration.add(String.isNotBlank(aAccountInfos.cpf_CNPJ_SOCIO4_ENR) ? aAccountInfos.cpf_CNPJ_SOCIO4_ENR + ';' + aAccountInfos.nome_RAZAO_SOCIO4_ENR + ';' + aAccountInfos.participacao_SOCIO4_ENR : '');
		lContactInfosIntegration.add(String.isNotBlank(aAccountInfos.cpf_CNPJ_SOCIO5_ENR) ? aAccountInfos.cpf_CNPJ_SOCIO5_ENR + ';' + aAccountInfos.nome_RAZAO_SOCIO5_ENR + ';' + aAccountInfos.participacao_SOCIO5_ENR : '');
		lContactInfosIntegration.add(String.isNotBlank(aAccountInfos.cpf_CNPJ_SOCIO6_ENR) ? aAccountInfos.cpf_CNPJ_SOCIO6_ENR + ';' + aAccountInfos.nome_RAZAO_SOCIO6_ENR + ';' + aAccountInfos.participacao_SOCIO6_ENR : '');
		lContactInfosIntegration.add(String.isNotBlank(aAccountInfos.cpf_CNPJ_SOCIO7_ENR) ? aAccountInfos.cpf_CNPJ_SOCIO7_ENR + ';' + aAccountInfos.nome_RAZAO_SOCIO7_ENR + ';' + aAccountInfos.participacao_SOCIO7_ENR : '');
		lContactInfosIntegration.add(String.isNotBlank(aAccountInfos.cpf_CNPJ_SOCIO8_ENR) ? aAccountInfos.cpf_CNPJ_SOCIO8_ENR + ';' + aAccountInfos.nome_RAZAO_SOCIO8_ENR + ';' + aAccountInfos.participacao_SOCIO8_ENR : '');
		lContactInfosIntegration.add(String.isNotBlank(aAccountInfos.cpf_CNPJ_SOCIO9_ENR) ? aAccountInfos.cpf_CNPJ_SOCIO9_ENR + ';' + aAccountInfos.nome_RAZAO_SOCIO9_ENR + ';' + aAccountInfos.participacao_SOCIO9_ENR : '');
		lContactInfosIntegration.add(String.isNotBlank(aAccountInfos.cpf_CNPJ_SOCIO10_ENR) ? aAccountInfos.cpf_CNPJ_SOCIO10_ENR + ';' + aAccountInfos.nome_RAZAO_SOCIO10_ENR + ';' + aAccountInfos.participacao_SOCIO10_ENR : '');	
		
		for(String lCpf :lContactInfosIntegration){
			List<String> lInfosLst = lCpf.split(';');
			Contact lContact = new Contact();
			system.debug('lInfosLst ' + lInfosLst);
			//verifica se o nome não está vazio e quebra em nome e sobrenome. Se estiver vazio, preenche o LastName com CPF
			if(String.isNotBlank(lInfosLst[0])){
				lContact.CPF__c = lInfosLst[0];				
				lContact.RecordTypeId = PARTNER_RECTYPE;

				if(String.isNotBlank(lInfosLst[1])){
					if(lInfosLst[1].contains(' ')) {
						lContact.FirstName = lInfosLst[1].substringBefore(' ');
						lContact.LastName = lInfosLst[1].substringAfter(' ');
					}
					else {
						lContact.LastName = lInfosLst[1];
					}                
				}
				else{
					lContact.LastName = lInfosLst[0];
				}
				lReturn.lContactLst.add(lContact);

				//verifica se o campo de participação é nulo e retorna zero. Caso não seja nulo, envia o valor retornado da integração;
				if(String.isNotBlank(lInfosLst[2]) && lInfosLst[2]!='null'){
					String lPercent = lInfosLst[2].replace(',','.');
					lReturn.lParticipation.add(Decimal.ValueOf(lPercent));
				}
				else{
					lReturn.lParticipation.add(0);
				}	
			}	
		}
		// system.debug('lReturn.lAcc ' + lReturn.lAcc);
		// system.debug('lReturn.lContactLst ' + lReturn.lContactLst);
		// system.debug('lReturn.lParticipation ' + lReturn.lParticipation);
		return lReturn;
	}

	public class AccountContactWrapper{
		@AuraEnabled public Account lAcc = new Account();
		@AuraEnabled public List<Contact> lContactLst = new List<Contact>();
		@AuraEnabled public List<Decimal> lParticipation = new List<Decimal>();
	}
}