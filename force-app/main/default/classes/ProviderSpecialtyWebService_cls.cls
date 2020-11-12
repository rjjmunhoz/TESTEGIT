/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Prestador e Especialidade
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-06-15      Jean Sganzerla          class created 
**************************************************************************************************************/
public with sharing class ProviderSpecialtyWebService_cls extends AWS_API{
    
    private static final String PROVIDER = Label.String_Provider;
    private static final String ACTIVE = Label.Status_Active;
    private static final String INACTIVE = Label.Status_Inactive;

    
    public DadosSistema DadosSistema;
    public List<Especialidades> Especialidades;
    public List<Habilidades> Habilidades;

    public class DadosSistema{
       String UsuarioCriacao;
       DateTime DataCriacao;
       String UsuarioAtualizacao;
       DateTime DataAtualizacao;
    }

    public class Especialidades{
        Integer CodigoEspecialidade;
        String Segmento;
    } 

    public class Habilidades{
        Integer CodigoHabilidade;
    } 
    
    public ProviderSpecialtyWebService_cls(SObject aAccount,List<SpecialtyWrapper_cls.Especialidades> aSpecialtyLst, List<SpecialtyWrapper_cls.Habilidades> aAbilityLst){
        super(PROVIDER);
        Account lAccount = (Account)aAccount;
        
        String lPath = Label.ParameterCodeSpeciality;
        List<Object> lParameters = new List<Object> {lAccount.Code__c};
        String lFormattedPath = String.format(lPath, lParameters);             
        String lEndpoint = this.fReq.getEndpoint();
        this.fReq.setEndpoint(lEndpoint+lFormattedPath);
        this.fReq.setMethod(Label.String_PUT);
        
        this.DadosSistema = new DadosSistema();
        this.DadosSistema.UsuarioCriacao = lAccount.CreatorFederationIdentifier__c;
        this.DadosSistema.DataCriacao = lAccount.CreatedDate;
        this.DadosSistema.UsuarioAtualizacao = lAccount.ModifierFederationIdentifier__c;
        this.DadosSistema.DataAtualizacao = System.NOW();

        this.Especialidades = new List<Especialidades>();
        if(aSpecialtyLst != null){
            for(SpecialtyWrapper_cls.Especialidades lSpec :aSpecialtyLst){
                Especialidades EspecialidadesToAdd = new Especialidades();
                EspecialidadesToAdd.CodigoEspecialidade = lSpec.CodigoEspecialidade;
                EspecialidadesToAdd.Segmento = lSpec.Segmento;
    
                this.Especialidades.add(EspecialidadesToAdd);
            }
        }

        this.Habilidades = new List<Habilidades>();
        if(aAbilityLst != null){
            for(SpecialtyWrapper_cls.Habilidades lAbility :aAbilityLst){
                Habilidades HabilidadesToAdd = new Habilidades();
                HabilidadesToAdd.CodigoHabilidade = lAbility.CodigoHabilidade;
    
                this.Habilidades.add(HabilidadesToAdd);
            }
        }
    }

    public AWS_API.ResponseWrapper setAwsProvider(){
        this.fReq.setBody(JSON.serialize(this));
		AWS_API.ResponseWrapper lResult =  this.doRequest();     
        return this.doRequest();
    }
  
    public static SpecialtyWrapper_cls newProviderAbility (Set<Id> aProviderIdSet) {

        Map<Id,Account> lProviderInfoMap = new Map<Id,Account>([SELECT Code__c, CNPJ__c, Name, SucursalCode__c,CreatorFederationIdentifier__c,CreatedDate,ModifierFederationIdentifier__c,LastModifiedDate FROM Account WHERE Id IN :aProviderIdSet AND Status__c != :INACTIVE AND Synced__c = true]);
        if(lProviderInfoMap.isEmpty()) return null;

        // Busca todas as Habilidades dos Prestadores
        SpecialtyWrapper_cls lAccountSpecialtyWr = new SpecialtyWrapper_cls(lProviderInfoMap.values());
        Map<Id,Map<Id,Account>> lAbilityAccountMap = new Map<Id,Map<Id,Account>>();
        for(EquipmentSupplyPart__c lAbility :[SELECT Abiliity__c, Provider__c, Abiliity__r.Code__c FROM EquipmentSupplyPart__c WHERE Provider__c IN :aProviderIdSet AND Abiliity__r.Status__c = :ACTIVE AND IsActive__c = true]){
            Map<Id,Account> lAccountMap = lAbilityAccountMap.get(lAbility.Abiliity__c);
            if(lAccountMap == null) {
                lAccountMap = new Map<Id,Account>();     
                lAbilityAccountMap.put(lAbility.Abiliity__c, lAccountMap);               
            }
            if(!lAccountMap.containsKey(lAbility.Provider__c)) {
                lAccountMap.put(lAbility.Provider__c, lProviderInfoMap.get(lAbility.Provider__c));
            }
            List<SpecialtyWrapper_cls.Habilidades> lAbilityLst = lAccountSpecialtyWr.fAbillityLstMap.get(lAbility.Provider__c);
            if (lAbilityLst == null) {
                lAbilityLst = new List<SpecialtyWrapper_cls.Habilidades>();
                lAccountSpecialtyWr.fAbillityLstMap.put(lAbility.Provider__c, lAbilityLst);
            }
            SpecialtyWrapper_cls.Habilidades lHabilidade = new SpecialtyWrapper_cls.Habilidades();
            lHabilidade.CodigoHabilidade = lAbility.Abiliity__r.Code__c!=null?Integer.valueOf(lAbility.Abiliity__r.Code__c):null;
            lAbilityLst.add(lHabilidade);
        } 

        // Monta um map de Id de Habilidade com suas Especialidades
        Map<Id,List<SpecialtyWrapper_cls.Especialidades>> lAbilitySpecialtyLstMap = new Map<Id,List<SpecialtyWrapper_cls.Especialidades>>();
        Set<Decimal> lSpecialtyDuplicated = new Set<Decimal>();
        for(Ability__c lAbility :[SELECT Product2__r.Code__c, Product2__r.SpecialtyType__c, OperationalSetup__c FROM Ability__c 
        WHERE Product2__r.Status__c = :ACTIVE AND IsActive__c = true AND OperationalSetup__c IN :lAbilityAccountMap.keySet()]){
            
            List<SpecialtyWrapper_cls.Especialidades> lSpecialtyLst = lAbilitySpecialtyLstMap.get(lAbility.OperationalSetup__c);
            if(lSpecialtyLst == null) {
                lSpecialtyLst = new List<SpecialtyWrapper_cls.Especialidades>();
                lAbilitySpecialtyLstMap.put(lAbility.OperationalSetup__c, lSpecialtyLst);
            }
            if(!lSpecialtyDuplicated.contains(lAbility.Product2__r.Code__c)){
                SpecialtyWrapper_cls.Especialidades lEspecialidade = new SpecialtyWrapper_cls.Especialidades();
                lEspecialidade.Segmento = lAbility.Product2__r.SpecialtyType__c;
                lEspecialidade.CodigoEspecialidade = lAbility.Product2__r.Code__c!=null?Integer.valueOf(lAbility.Product2__r.Code__c):null;
                lSpecialtyLst.add(lEspecialidade);                   
                lSpecialtyDuplicated.add(lAbility.Product2__r.Code__c);
            }          
        }
        //if(lAbilitySpecialtyLstMap.isEmpty()) return null;        

        // Monta um map de Id de Prestador com suas Especialidades
        for(Id lAbilityId :lAbilityAccountMap.keySet()) {
            List<SpecialtyWrapper_cls.Especialidades> lSpecialtyLst = lAbilitySpecialtyLstMap.get(lAbilityId);
            if(lSpecialtyLst != null) {
                Map<Id,Account> lAccountMap = lAbilityAccountMap.get(lAbilityId);
                if(lAccountMap != null) {
                    for(Account lAccount :lAccountMap.values()) {
                        List<SpecialtyWrapper_cls.Especialidades> lSpecialtyAccountLst = lAccountSpecialtyWr.fSpecialtyLstMap.get(lAccount.Id);
                        if(lSpecialtyAccountLst == null) {
                            lSpecialtyAccountLst = new List<SpecialtyWrapper_cls.Especialidades>();
                            lAccountSpecialtyWr.fSpecialtyLstMap.put(lAccount.Id, lSpecialtyAccountLst);
                        }
                        lSpecialtyAccountLst.addAll(lSpecialtyLst);
                    }
                }
            }
        }

        //Manda uma lista de habilidade vazia
        if(lAbilityAccountMap.isEmpty()){
            List<Account> lProviderLst = [SELECT Code__c, CNPJ__c, Name, SucursalCode__c,CreatorFederationIdentifier__c,CreatedDate,ModifierFederationIdentifier__c,LastModifiedDate FROM Account WHERE Id IN :aProviderIdSet AND Status__c != :INACTIVE AND Synced__c = true];
            for(Account lProvider: lProviderLst){
                lAccountSpecialtyWr.fSObjectLst.add(lProvider);
                List<SpecialtyWrapper_cls.Habilidades> lAbilityLst = lAccountSpecialtyWr.fAbillityLstMap.get(lProvider.Id);
                if (lAbilityLst == null) {
                    lAbilityLst = new List<SpecialtyWrapper_cls.Habilidades>();
                    lAccountSpecialtyWr.fAbillityLstMap.put(lProvider.Id, lAbilityLst);
                }

            }
        }  

        return lAccountSpecialtyWr;
    }
}