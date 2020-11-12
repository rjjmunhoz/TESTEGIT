/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Habilidade
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-01-20      Jean Sganzerla          class created 
*            1.1    2020-06-20      Jean Sganzerla          FederationIdentifier Alteration
**************************************************************************************************************/
public with sharing class AbilityWebService extends AWS_API {
    private static final String ABILITY = Label.String_Ability;
    /*private static final Map<String,String> statusMap = new Map<String,String>{
        'Ativo' => 'A',
        'Inativo' => 'I'
    };*/

    private static final Map<String,String> statusMap {
        get {
            if(statusMap != null) {
                return statusMap;
            }
            else {
                statusMap = new Map<String,String>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'AbilityStatus' AND IsActive__c = true]) {
                    statusMap.put(lLegacyDomainTableValue.Key__c, lLegacyDomainTableValue.Value__c);
                }
                return statusMap;
            }            
        }
        set;
    }

    public Integer codigoHabilidade;
    public String nomeHabilidade;
    public String perfil;
    public String descricaoHabilidade;
    public String dataAtualizacao;
    public String status;
    public String owner; 

    public AbilityWebService(SObject aAbility) {
        super(ABILITY);
        OperationalSetup__c lAbility = (OperationalSetup__c)aAbility;
        this.codigoHabilidade = lAbility.Code__c != null?Integer.valueOf(lAbility.Code__c):null;
        this.nomeHabilidade = lAbility.Name;
        this.perfil = lAbility.Perfil__c;
        this.descricaoHabilidade = String.isNotBlank(lAbility.Description__c)?lAbility.Description__c.stripHtmlTags():null;
        this.dataAtualizacao = lAbility.LastModifiedDate != null?String.valueOf(lAbility.LastModifiedDate):null;
        this.status = String.isNotBlank(statusMap.get(lAbility.Status__c))?String.valueOf(statusMap.get(lAbility.Status__c)):null;
        this.owner = lAbility.LoggedUserFederationIdentifier__c;
    }

    public AWS_API.ResponseWrapper setAwsAbility(){
		this.fReq.setBody(JSON.serialize(this));
		AWS_API.ResponseWrapper lResult =  this.doRequest();
        return lResult;
    }
    
    public static List<SObject> getAbilityToIntegration(List<SObject> aSObjectLst) {
        
        TriggerCheck.assert();

        List<SObject> lSObjectToIntegrate = new List<SObject>();
        for(SObject lSObj :aSObjectLst) {
            if(TriggerCheck.isChanged(lSObj, OperationalSetup__c.Code__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.Name) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.Perfil__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.Description__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.Status__c)){ 
                    // Adicionar a verificação de todos os campos utilizados na integração
                lSObjectToIntegrate.add(lSObj);
            }            
        }
        return lSObjectToIntegrate;
    }
}