/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Socios PJ Serasa
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-01-31      Eduardo Costa           class created 
**************************************************************************************************************/
public with sharing class PartnersSerasaPJWebService extends AWS_API {

    private static final String PartnersSerasaPJ = Label.String_SerasaPJPartner;
    private static final Id PARTNER_RECTYPE = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.PartnerRecordType).getRecordTypeId();
    public List<Sociedades> sociedades;
	public String cpf_CNPJ_PESQUISA;

	public class Sociedades implements Comparable {
		public String nome;
		public String tipoPessoa;
		public String documento;
        public Decimal participacao; 
        
        public Integer compareTo(Object compareTo) {
            Sociedades compareToEmp = (Sociedades)compareTo;
            Decimal lPart = participacao!=null?participacao:0;
            Decimal lPartCompare = compareToEmp.participacao!=null?compareToEmp.participacao:0;
            if (lPart == lPartCompare) return 0;
            if (lPart < lPartCompare) return 1;
            return -1;        
        }
	}

    public PartnersSerasaPJWebService() {
        super(PartnersSerasaPJ);
    }

    public List<PartnerWrapper> getPartnersSerasaPJ(String aCNPJ){
		String lEndpoint = this.fReq.getEndpoint();
        List<Object> lParameters = new List<Object> {aCNPJ};
        this.fReq.setEndpoint(String.format(lEndpoint, lParameters));
		system.debug('PartnersSerasaPJ Endpoint: ' + this.fReq.getEndpoint());   
		AWS_API.ResponseWrapper lResult =  this.doRequest();     
		system.debug('PartnersSerasaPJ lResult: ' + lResult);  
		system.debug('PartnersSerasaPJ Body: ' + lResult.response.getBody());                   
        if(!lResult.success) {
            insert new Log__c(Message__c = lResult.message, Object__c = Label.String_SerasaPJPartner, ObjectId__c = aCNPJ);
            return null;
        }
        else {
            PartnersSerasaPJWebService lPartSerasaPJ = (PartnersSerasaPJWebService) System.JSON.deserialize(lResult.response.getBody(), PartnersSerasaPJWebService.class);
            system.debug('lPartners -----> ' + lPartSerasaPJ);
            List<PartnerWrapper> lPartners = getPartner(lPartSerasaPJ);
            system.debug('lPartners -----> ' + lPartners);
            return lPartners;
        }  
    }
    
    public List<PartnerWrapper> getPartner(PartnersSerasaPJWebService aContactInfos){
        List<PartnerWrapper> lPartnerLst = new List<PartnerWrapper>();

        for(Sociedades lContactInfos :aContactInfos.sociedades){
            PartnerWrapper lContact = new PartnerWrapper(lContactInfos.participacao);
            if(!String.isBlank(lContactInfos.nome)){
                if(lContactInfos.nome.contains(' ') ) {
                    lContact.lPartner.FirstName = lContactInfos.nome.substringBefore(' ');
                    lContact.lPartner.LastName = lContactInfos.nome.substringAfter(' ');
                }
                else {
                    lContact.lPartner.LastName = lContactInfos.nome;
                }                
            }
            else{
                lContact.lPartner.LastName = lContactInfos.documento;
            }
            lContact.lPartner.CPF__c = lContactInfos.documento;   
            lContact.lPartner.RecordTypeId = PARTNER_RECTYPE;
            lPartnerLst.add(lContact);
        }
        return lPartnerLst;
    }    

    public class PartnerWrapper{
        @AuraEnabled public Contact lPartner;
        @AuraEnabled public Decimal lParticipation;

        public PartnerWrapper(Decimal aParticipation){
            this.lPartner = new Contact();
            this.lParticipation = aParticipation;
        }
    }
}