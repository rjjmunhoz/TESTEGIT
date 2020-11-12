/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Equipamento
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-01-16      Eduardo Costa           class created 
**************************************************************************************************************/
public with sharing class EquipmentWebService extends AWS_API {

    private static final String EQUIPMENT = Label.String_Equipment;
    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();
    private static String fAssigmentRuleId;
    private static Id fRecordCode;

    private static final Map<String,String> statusMap {
        get {
            if(statusMap != null) {
                return statusMap;
            }
            else {
                statusMap = new Map<String,String>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'EquipmentStatus' AND IsActive__c = true]) {
                    statusMap.put(lLegacyDomainTableValue.Key__c, lLegacyDomainTableValue.Value__c);
                }
                return statusMap;
            }            
        }
        set;
    }

    public Integer codigoEquipamento;
	public String nomeEquipamento;
	public Integer codigoTipoEquipamento;
	public String descricaoEquipamento;
	public String marcaEquipamento;
	public Decimal valorUnitario;
	public Boolean flagEquipamentoSeguranca;
	public String codigoSerie;
	public Decimal quantidade;
	public Boolean flagEquipamentoSeraDevolvido;
	public String dataSolicitacao;
	public Integer quantidadeDiasUsoPadrao;
	public String dataEntrada;
	public Integer quantidadeDiasGarantia;
    public String status;
    public String dataAtualizacao;
    public String owner;

    public EquipmentWebService(SObject aEquipment) {
        super(EQUIPMENT);
        OperationalSetup__c lEquipment = (OperationalSetup__c)aEquipment;
        this.codigoEquipamento =  lEquipment.Code__c != null ? Integer.valueOf(lEquipment.Code__c) : null;
        this.nomeEquipamento =  lEquipment.Name;
        this.descricaoEquipamento = String.isNotBlank(lEquipment.Description__c)?lEquipment.Description__c.stripHtmlTags():'';
        this.marcaEquipamento =  lEquipment.Brand__c;
        this.valorUnitario =  lEquipment.UnitaryValue__c;
        this.flagEquipamentoSeguranca = lEquipment.SafetyEquipment__c==Label.String_Yes?true:false;
        this.codigoSerie =lEquipment.SerialCode__c;
        this.quantidade = lEquipment.Quantity__c;
        this.flagEquipamentoSeraDevolvido = lEquipment.EquipmentReturned__c==Label.String_Yes?true:false;
        this.dataSolicitacao = lEquipment.RequestDate__c != null ? String.valueOf(lEquipment.RequestDate__c) : null;
        this.quantidadeDiasUsoPadrao = Integer.valueOf(lEquipment.UseTime__c==null?0:lEquipment.UseTime__c); // Verificar se é isso mesmo (Tempo de uso (dias))
        this.dataEntrada = lEquipment.EntryDate__c != null ? String.valueOf(lEquipment.EntryDate__c) : null;
        this.quantidadeDiasGarantia = lEquipment.WarrantyTime__c != null ? Integer.valueOf(lEquipment.WarrantyTime__c) : null;
        this.status = String.isNotBlank(lEquipment.Status__c) ? String.valueOf(statusMap.get(lEquipment.Status__c)) : null;
        this.dataAtualizacao = lEquipment.LastModifiedDate != null ? String.valueOf(lEquipment.LastModifiedDate) : null;
        this.owner = lEquipment.LoggedUserFederationIdentifier__c; 
    }

    public AWS_API.ResponseWrapper setAwsEquipment(){
		this.fReq.setBody(JSON.serialize(this));
		AWS_API.ResponseWrapper lResult =  this.doRequest();        
        return lResult;
    }
    
    public static List<SObject> getEquipmentToIntegration(List<SObject> aSObjectLst) {
        
        TriggerCheck.assert();

        List<SObject> lSObjectToIntegrate = new List<SObject>();
        for(SObject lSObj :aSObjectLst) {
            if(TriggerCheck.isChanged(lSObj, OperationalSetup__c.Code__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.Name) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.Description__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.Brand__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.UnitaryValue__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.SafetyEquipment__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.SerialCode__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.Quantity__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.EquipmentReturned__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.RequestDate__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.UseTime__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.EntryDate__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.WarrantyTime__c) ||
                    TriggerCheck.isChanged(lSObj, OperationalSetup__c.Status__c)){ 
                    // Adicionar a verificação de todos os campos utilizados na integração
                lSObjectToIntegrate.add(lSObj);
            }            
        }
        return lSObjectToIntegrate;
    }
}