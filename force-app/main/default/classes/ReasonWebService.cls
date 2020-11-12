/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Motivo (Problema)
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-01-20      Jean Sganzerla          class created 
             1.1    2020-04-22      Matheus Branco          add grupoProblema fields
*            1.2    2020-06-20      Jean Sganzerla          FederationIdentifier Alteration
**************************************************************************************************************/
public with sharing class ReasonWebService extends AWS_API {
    private static final String REASON = Label.String_Detail;
    private static final String ACTIVE = Label.Status_Active;

    private static final Map<String,String> statusMap {
        get {
            if(statusMap != null) {
                return statusMap;
            }
            else {
                statusMap = new Map<String,String>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'ReasonStatus' AND IsActive__c = true]) {
                    statusMap.put(lLegacyDomainTableValue.Key__c, lLegacyDomainTableValue.Value__c);
                }
                return statusMap;
            }            
        }
        set;
    }
    public Integer codigoProblema;
    public String nomeProblema;
    public String descricaoProblema;
    public String dataAtualizacao;
    public String status;
    public String owner;
    public Integer grupoProblema;

    public ReasonWebService(SObject aReason) {
        super(REASON);
        Product2 lReason = (Product2)aReason;
        this.codigoProblema = lReason.Code__c != null ? Integer.valueOf(lReason.Code__c) : null;
        this.nomeProblema = lReason.Name;
        this.descricaoProblema = String.isNotBlank(lReason.Description__c) ? lReason.Description__c.stripHtmlTags() : null;
        this.status = String.isNotBlank(lReason.Status__c) ? String.valueOf(statusMap.get(lReason.Status__c)) : null;
        this.dataAtualizacao = lReason.LastModifiedDate != null ? String.valueOf(lReason.LastModifiedDate) : null;
        this.owner =lReason.LoggedUserFederationIdentifier__c;
        this.grupoProblema = String.isNotBlank(lReason.ReasonGroup__c) ? Integer.valueOf(lReason.ReasonGroup__c) : null;
    }

    public AWS_API.ResponseWrapper setAwsReason(){
		this.fReq.setBody(JSON.serialize(this));
		AWS_API.ResponseWrapper lResult =  this.doRequest();        
        return lResult;
    }

    public static Boolean needIntegration(SObject aSObj) {
        
        return TriggerCheck.isChanged(aSObj, Product2.Code__c) ||
                TriggerCheck.isChanged(aSObj, Product2.Name) ||
                TriggerCheck.isChanged(aSObj, Product2.Description__c) ||
                TriggerCheck.isChanged(aSObj, Product2.Status__c) || 
                TriggerCheck.isChanged(aSObj, Product2.ReasonGroup__c);
    }
}