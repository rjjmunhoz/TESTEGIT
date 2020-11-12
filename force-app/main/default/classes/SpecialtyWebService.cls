/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Especialidade
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0    2020-01-21      Jean Sganzerla          class created 
*           1.2    2020-01-21      Jean Sganzerla          add codigoGrupoEspecialidade field
*           1.3    2020-01-21      Jean Sganzerla          add owner,dataAtualizacao,similaridade fields
*           1.4    2020-04-22      Matheus Branco          add agendadoPrestador fields
*           1.5    2020-06-20      Jean Sganzerla          FederationIdentifier Alteration
**************************************************************************************************************/
public with sharing class SpecialtyWebService extends AWS_API{
    private static final String SPECIALTY = Label.String_Specialty;
    private static final String ACTIVE = Label.Status_Active;
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
                        WHERE Domain__c = 'SpecialtyStatus' AND IsActive__c = true]) {
                    statusMap.put(lLegacyDomainTableValue.Key__c, lLegacyDomainTableValue.Value__c);
                }
                return statusMap;
            }            
        }
        set;
    }
    public Integer codigoEspecialidade;
    public String nomeEspecialidade;
    public String segmentoEspecialidade;
    public String bemAtendido;
    public String tempoExecucao;
    public Decimal retornoGarantiaMaoDeObraDias;
    public Decimal retornoGarantiaPecaDias;
    public Decimal quantidadeDeMotivosAbertura;
    public Boolean servicoOperacional;
    public String descricaoEspecialidade ;
    public String status;
    public String segmento;
    public String codigoTipoAgendamento;
    public String codigoTipoAgendamentoPreferencial;
    public String codigoGrupoEspecialidade;
    public String owner;
    public String dataAtualizacao;
    public List<Problemas> problemas;
    public Similaridade similaridade;
    public Boolean flagAgendamentoPrestador;
    //public String createOwner;
    //public String dataCriacao; 
    

    public class Problemas {
        Integer codigoProblema;
        public Problemas(Integer aCodProblema) {
            this.codigoProblema = aCodProblema;
        }
    }  
    
    public class Similaridade {
        String nome;
        public Similaridade(String aNome) {
            this.nome = aNome;
        }
    } 

    public SpecialtyWebService(SObject aSpecialty) {
        super(SPECIALTY);
        Product2 lSpecialty = (Product2)aSpecialty;
        this.codigoEspecialidade = lSpecialty.Code__c != null?Integer.valueOf(lSpecialty.Code__c):null;
        this.nomeEspecialidade = lSpecialty.Name;
        this.segmentoEspecialidade = lSpecialty.SpecialtyType__c;
        this.bemAtendido = lSpecialty.AttendedAsset__c;
        this.retornoGarantiaMaoDeObraDias = lSpecialty.WarrantyMO__c;
        this.retornoGarantiaPecaDias = lSpecialty.WarrantyPiece__c;
        this.quantidadeDeMotivosAbertura = lSpecialty.NumberReasonsAllowed__c;
        this.servicoOperacional = lSpecialty.OperationalService__c;
        this.descricaoEspecialidade = String.isNotBlank(lSpecialty.Description__c)?lSpecialty.Description__c.stripHtmlTags():null;
        this.status = String.isNotBlank(statusMap.get(lSpecialty.Status__c))?String.valueOf(statusMap.get(lSpecialty.Status__c)):null;  
        this.codigoTipoAgendamento = lSpecialty.ScheduleType__c;
        this.codigoGrupoEspecialidade = lSpecialty.SpecialtiesGroup__c;
        this.dataAtualizacao = lSpecialty != null?String.valueOf(lSpecialty.LastModifiedDate):null;
        this.flagAgendamentoPrestador = lSpecialty.ScheduledProvider__c== Label.String_Yes ? true:false;
        this.owner = lSpecialty.LoggedUserFederationIdentifier__c;

        //preenche o map com os valores do picklist SpecialtiesGroup__c
        Map<String,String> lSpecialtiesGroupMap = new Map<String,String>();
		Schema.DescribeFieldResult lFieldResult = Product2.SpecialtiesGroup__c.getDescribe();
        List<Schema.PicklistEntry> lPicklistEntry = lFieldResult.getPicklistValues();
		for( Schema.PicklistEntry lPickListVal : lPicklistEntry){        
            
            lSpecialtiesGroupMap.put(lPickListVal.getValue(),lPickListVal.getLabel());
            // system.debug('lPickListVal.getValue() ' + lPickListVal.getValue());
            // system.debug('lPickListVal.getLabel() ' + lPickListVal.getLabel());
        }
        String lSimilaridade = lSpecialtiesGroupMap.get(lSpecialty.SpecialtiesGroup__c);
        lSimilaridade = lSimilaridade != null ? lSimilaridade.toUpperCase() : null;
        this.similaridade = new Similaridade(lSimilaridade);  

        if(lSpecialty.ScheduleType__c != Label.AWSQuantityAttemptsShipping){ //Label inserida pois contém o valor 3;
            this.codigoTipoAgendamentoPreferencial = lSpecialty.ScheduleType__c;
        }
        else{
            this.codigoTipoAgendamentoPreferencial = lSpecialty.PreferredScheduleType__c;
        }  

        this.problemas = new List<Problemas>();
        for(ServiceSpecialtyDetails__c lServSpecDet :[SELECT Detail__r.Code__c, IsActive__c 
                FROM ServiceSpecialtyDetails__c WHERE SpecialtyDetail__c = :lSpecialty.Id
                AND Detail__r.Status__c = :Label.Status_Active AND IsActive__c = true ]) {
            this.problemas.add(new Problemas(Integer.valueOf(lServSpecDet.Detail__r.Code__c)));
        }          

        if(lSpecialty.RunTime__c != null){
            Time lTime = lSpecialty.RunTime__c;
            String lYear = String.valueOf(system.today().year());
            String lMonth = String.valueOf(system.today().month());
            String lDay = String.valueOf(system.today().day());
            String lHour = String.valueOf(lTime.hour());
            String lMinute = String.valueOf(lTime.minute());
            String lSecond = Label.String_lSecond;
            String lStringDate = lYear + Label.String_Trace + lMonth + Label.String_Trace + lDay + ' ' + lHour + Label.String_Colon + lMinute +  Label.String_Colon + lSecond;
            this.tempoExecucao = String.valueOf(lStringDate);    
        }  
    }

    public AWS_API.ResponseWrapper setAwsSpecialty(){
        this.fReq.setBody(JSON.serialize(this));
        system.debug('setAwsSpecialty: ' + this.fReq.getBody());
		AWS_API.ResponseWrapper lResult =  this.doRequest();        
        return lResult;
    }    
    
    // Método utilizado para retornar campos da Especialidade utilizados para integração
    // caso seja adicionado mais algum campo na API que envia as especialidades para o Legado
    // será necessário incluir este campo na SOQL abaixo
    public static List<Product2> getSpecialtyWithFieldsToIntegrate(Set<Id> aSpecialtyIdSet) {
        return [SELECT Id, Code__c, Name, SpecialtyType__c, AttendedAsset__c, Runtime__c, 
            WarrantyMO__c, WarrantyPiece__c, NumberReasonsAllowed__c, OperationalService__c, 
            Description__c, Status__c, ScheduleType__c, PreferredScheduleType__c,SpecialtiesGroup__c, 
            Product2.RecordTypeId, LastModifiedDate, ScheduledProvider__c, CreatedDate, CreatedById,LoggedUserFederationIdentifier__c FROM Product2
            WHERE Id IN :aSpecialtyIdSet AND Status__c = :ACTIVE];
    }
    
    public static Boolean needIntegration(SObject aSObj) {        
        return TriggerCheck.isChanged(aSObj, Product2.Code__c) ||
            TriggerCheck.isChanged(aSObj, Product2.Name) ||
            TriggerCheck.isChanged(aSObj, Product2.SpecialtiesGroup__c) ||
            TriggerCheck.isChanged(aSObj, Product2.SpecialtyType__c) ||                      
            TriggerCheck.isChanged(aSObj, Product2.AttendedAsset__c) ||
            TriggerCheck.isChanged(aSObj, Product2.Runtime__c) ||
            TriggerCheck.isChanged(aSObj, Product2.WarrantyMO__c) ||
            TriggerCheck.isChanged(aSObj, Product2.WarrantyPiece__c) ||
            TriggerCheck.isChanged(aSObj, Product2.NumberReasonsAllowed__c) ||
            TriggerCheck.isChanged(aSObj, Product2.OperationalService__c) ||
            TriggerCheck.isChanged(aSObj, Product2.Description__c) ||
            TriggerCheck.isChanged(aSObj, Product2.Status__c) ||
            TriggerCheck.isChanged(aSObj, Product2.ScheduleType__c) ||
            TriggerCheck.isChanged(aSObj, Product2.PreferredScheduleType__c) || 
            TriggerCheck.isChanged(aSObj, Product2.ScheduledProvider__c);         
    }
}