/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService dos usuários do Portal
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-09-03      Mariana Ribeiro         class created 
**************************************************************************************************************/
public with sharing class ProviderEquipamentWebService_cls extends AWS_API{
    
    private static final String PROVIDER = Label.String_Provider;
    private static final String ACTIVE = Label.Status_Active;
    private static final String INACTIVE = Label.Status_Inactive;

    public Integer CodigoPrestador;
    public List<Equipamentos> Equipamentos;
    public DadosSistema DadosSistema;

    public class Equipamentos{
        Integer CodigoEquipamento;
    }

    public class DadosSistema{
       String UsuarioCriacao;
       DateTime DataCriacao;
       String UsuarioAtualizacao;
       DateTime DataAtualizacao;
    }
    
    public ProviderEquipamentWebService_cls(SObject aProviderEquip, List<SpecialtyWrapper_cls.Equipamentos> aEquipmentLst){
        super(PROVIDER);
        Account lProviderEquip = (Account)aProviderEquip;

        String lPath = Label.ParameterCodeEquipament;
        List<Object> lParameters = new List<Object> {lProviderEquip.Code__c};
        String lFormattedPath = String.format(lPath, lParameters);                
        String lEndpoint = this.fReq.getEndpoint();
        this.fReq.setEndpoint(lEndpoint+lFormattedPath);
        this.fReq.setMethod(Label.String_PUT);

        this.CodigoPrestador = lProviderEquip.Code__c != null? Integer.ValueOf(lProviderEquip.Code__c): null;

        this.Equipamentos = new List<Equipamentos>();
        if(aEquipmentLst != null){
            for(SpecialtyWrapper_cls.Equipamentos lEquipment :aEquipmentLst){
                Equipamentos EquipamentosToAdd = new Equipamentos();
                EquipamentosToAdd.CodigoEquipamento = lEquipment.CodigoEquipamento;
    
                this.Equipamentos.add(EquipamentosToAdd);
            }
        }

        this.DadosSistema = new DadosSistema();
        this.DadosSistema.UsuarioCriacao = lProviderEquip.CreatorFederationIdentifier__c;
        this.DadosSistema.DataCriacao = lProviderEquip.CreatedDate;
        this.DadosSistema.UsuarioAtualizacao = lProviderEquip.ModifierFederationIdentifier__c;
        this.DadosSistema.DataAtualizacao = lProviderEquip.LastModifiedDate;
    }

    public AWS_API.ResponseWrapper setAwsProvider(){
        this.fReq.setBody(JSON.serialize(this));
		AWS_API.ResponseWrapper lResult =  this.doRequest();     
        return this.doRequest();
    }
  
    public static SpecialtyWrapper_cls newProviderEquipament(Set<Id> aProviderIdSet) {

        // Busca todos os Equipamentos dos Prestadores
        SpecialtyWrapper_cls lAccountSpecialtyWr = new SpecialtyWrapper_cls(new List<Account>());
        Map<Id,Map<Id,Account>> lEquipamentAccountMap = new Map<Id,Map<Id,Account>>();
        for(ProviderEquipment__c lEquipament : [SELECT Equipment__c, Provider__c, Equipment__r.Code__c, 
                                                    Provider__r.Code__c,Provider__r.SucursalCode__c,Provider__r.CreatorFederationIdentifier__c,
                                                    Provider__r.ModifierFederationIdentifier__c,Provider__r.LastModifiedDate, Provider__r.CreatedDate
                                                    FROM ProviderEquipment__c 
                                                    WHERE Provider__c IN :aProviderIdSet 
                                                    AND Equipment__r.Status__c = :ACTIVE 
                                                    AND IsActive__c = true 
                                                    AND Provider__r.Status__c != :INACTIVE 
                                                    AND Provider__r.Synced__c = true]){
            Map<Id,Account> lAccountMap = lEquipamentAccountMap.get(lEquipament.Equipment__c);
            if(lAccountMap == null) {
                lAccountMap = new Map<Id,Account>();     
                lEquipamentAccountMap.put(lEquipament.Equipment__c, lAccountMap);               
            }
            if(!lAccountMap.containsKey(lEquipament.Provider__c)) {
                lAccountMap.put(lEquipament.Provider__c, lEquipament.Provider__r);
            }
            lAccountSpecialtyWr.fSObjectLst.add(lEquipament.Provider__r);
            List<SpecialtyWrapper_cls.Equipamentos> lEquipamentLst = lAccountSpecialtyWr.fEquipmentLstMap.get(lEquipament.Provider__c);
            if (lEquipamentLst == null) {
                lEquipamentLst = new List<SpecialtyWrapper_cls.Equipamentos>();
                lAccountSpecialtyWr.fEquipmentLstMap.put(lEquipament.Provider__c, lEquipamentLst);
            }
            SpecialtyWrapper_cls.Equipamentos lEquipamento = new SpecialtyWrapper_cls.Equipamentos();
            lEquipamento.CodigoEquipamento = lEquipament.Equipment__r.Code__c!=null?Integer.valueOf(lEquipament.Equipment__r.Code__c):null;
            lEquipamentLst.add(lEquipamento);
        }

        Map<Id,Map<Id,Account>> lVehicleAccountMap = new Map<Id,Map<Id,Account>>();
        for(EquipamentVehicle__c lEquipament :[SELECT Vehicle__c, Equipament__c, Equipament__r.Code__c, 
                                                Provider__r.Code__c,Provider__r.SucursalCode__c,Provider__r.CreatorFederationIdentifier__c,
                                                Provider__r.ModifierFederationIdentifier__c,Provider__r.LastModifiedDate, Provider__r.CreatedDate FROM EquipamentVehicle__c WHERE Provider__c IN :aProviderIdSet AND VehicleStatus__c = :ACTIVE AND IsActive__c = true AND Equipament__c NOT IN :lEquipamentAccountMap.keySet()]){
            Map<Id,Account> lAccountMap = lVehicleAccountMap.get(lEquipament.Equipament__c);
            if(lAccountMap == null) {
                lAccountMap = new Map<Id,Account>();     
                lVehicleAccountMap.put(lEquipament.Equipament__c, lAccountMap);               
            }
            if(!lAccountMap.containsKey(lEquipament.Provider__c)) {
                lAccountMap.put(lEquipament.Provider__c, lEquipament.Provider__r);
            }
            List<SpecialtyWrapper_cls.Equipamentos> lEquipamentLst = lAccountSpecialtyWr.fEquipmentLstMap.get(lEquipament.Provider__c);
            if (lEquipamentLst == null) {
                lEquipamentLst = new List<SpecialtyWrapper_cls.Equipamentos>();
                lAccountSpecialtyWr.fEquipmentLstMap.put(lEquipament.Provider__c, lEquipamentLst);
            }
            SpecialtyWrapper_cls.Equipamentos lEquipamento = new SpecialtyWrapper_cls.Equipamentos();
            lEquipamento.CodigoEquipamento = lEquipament.Equipament__r.Code__c!=null?Integer.valueOf(lEquipament.Equipament__r.Code__c):null;
            lEquipamentLst.add(lEquipamento);
        }

        if(lVehicleAccountMap.isEmpty() && lEquipamentAccountMap.isEmpty()){
            List<Account> lProviderLst = [SELECT  Id, Code__c, SucursalCode__c, CreatorFederationIdentifier__c,
                                    ModifierFederationIdentifier__c, LastModifiedDate, CreatedDate FROM Account WHERE Id IN :aProviderIdSet
                                    AND Status__c != :INACTIVE 
                                    AND Synced__c = true];
            for(Account lProvider: lProviderLst){
                lAccountSpecialtyWr.fSObjectLst.add(lProvider);
                List<SpecialtyWrapper_cls.Equipamentos> lEquipamentLst = lAccountSpecialtyWr.fEquipmentLstMap.get(lProvider.Id);
                if (lEquipamentLst == null) {
                    lEquipamentLst = new List<SpecialtyWrapper_cls.Equipamentos>();
                    lAccountSpecialtyWr.fEquipmentLstMap.put(lProvider.Id, lEquipamentLst);
                }
            }
        }  
        System.debug('lAccountSpecialtyWr.fEquipmentLstMap: '+ lAccountSpecialtyWr.fEquipmentLstMap);

        return lAccountSpecialtyWr;
    }
}