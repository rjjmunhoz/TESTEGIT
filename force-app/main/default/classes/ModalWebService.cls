/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Modal
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-01-20      Jean Sganzerla          class created 
*            1.1    2020-06-20      Jean Sganzerla          FederationIdentifier Alteration
**************************************************************************************************************/

public with sharing class ModalWebService extends AWS_API{
    private static final String MODAL = Label.ObjectModal;
    private static String fRecordCode;
    private static String fAssigmentRuleId;
    
    private static final Map<String,String> statusMap {
        get {
            if(statusMap != null) {
                return statusMap;
            }
            else {
                statusMap = new Map<String,String>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'ModalStatus' AND IsActive__c = true]) {
                    statusMap.put(lLegacyDomainTableValue.Key__c, lLegacyDomainTableValue.Value__c);
                }
                return statusMap;
            }            
        }
        set;
    }
    public Integer codigoModal;
    public String nomeModal;
    public String siglaModal;
    public String categoriaCnh;
    public String itensObrigatorios;
    public String codigoTipoModal;
    public String descricaoModal;
    public String descricaoVeiculo;
    public String descricaoVistoria;
    public String descricaoSeguro;
    public String dataAtualizacao;
    public String FlagRodizio;
    public String Status;
    public String owner;

    public ModalWebService(SObject aModal) {
        super(MODAL);
        Modal__c lModal = (Modal__c)aModal;
        this.codigoModal = String.isNotBlank(lModal.Name) ? Integer.valueOf(lModal.Name) : null;
        this.nomeModal = lModal.Name__c;
        this.siglaModal = lModal.Initials__c;
        this.categoriaCnh = lModal.CNHCategory__c;
        this.itensObrigatorios = lModal.RequiredItems__c;
        this.codigoTipoModal =lModal.ModalType__c;
        this.descricaoModal = String.isNotBlank(lModal.Description__c)? lModal.Description__c.stripHtmlTags() : null;
        this.descricaoVeiculo = lModal.Vehicle__c;
        this.descricaoVistoria = lModal.Survey__c;
        this.descricaoSeguro = lModal.Safe__c;
        this.dataAtualizacao = lModal.LastModifiedDate != null ? String.valueOf(lModal.LastModifiedDate) : null;
        this.FlagRodizio = lModal.ModalSubjectRotation__c == Label.String_Yes ? Label.String_S : Label.String_N;
        this.Status = lModal.Status__c == Label.Status_Active ? String.valueOf(statusMap.get(Label.Status_Active)) : String.valueOf(statusMap.get(Label.Status_Inactive));
        this.owner = lModal.LoggedUserFederationIdentifier__c;
    }

    public AWS_API.ResponseWrapper setAwsModal(){
		this.fReq.setBody(JSON.serialize(this));
		AWS_API.ResponseWrapper lResult =  this.doRequest();        
        return lResult;
    }
    
    public static List<SObject> getModalToIntegration(List<SObject> aSObjectLst) {
        
        TriggerCheck.assert();

        List<SObject> lSObjectToIntegrate = new List<SObject>();
        for(SObject lSObj :aSObjectLst) {
            if(TriggerCheck.isChanged(lSObj, Modal__c.Name__c) ||
                    TriggerCheck.isChanged(lSObj, Modal__c.Initials__c) ||                      
                    TriggerCheck.isChanged(lSObj, Modal__c.CNHCategory__c) ||
                    TriggerCheck.isChanged(lSObj, Modal__c.RequiredItems__c) ||
                    TriggerCheck.isChanged(lSObj, Modal__c.ModalType__c) ||
                    TriggerCheck.isChanged(lSObj, Modal__c.Description__c) ||
                    TriggerCheck.isChanged(lSObj, Modal__c.Vehicle__c) ||
                    TriggerCheck.isChanged(lSObj, Modal__c.Survey__c) ||
                    TriggerCheck.isChanged(lSObj, Modal__c.OperatingTime__c) ||
                    TriggerCheck.isChanged(lSObj, Modal__c.ModalSubjectRotation__c) ||
                    TriggerCheck.isChanged(lSObj, Modal__c.Status__c) ||
                    TriggerCheck.isChanged(lSObj, Modal__c.Safe__c)){ 
                    // Adicionar a verificação de todos os campos utilizados na integração
                lSObjectToIntegrate.add(lSObj);
            }            
        }
        return lSObjectToIntegrate;
    }
}