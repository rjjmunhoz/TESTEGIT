/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Veículo
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-03-23      Mariana Ribeiro         class created 
**************************************************************************************************************/
public with sharing class VehicleSearchWebService_cls extends AWS_API{
    private static final String VEHICLE = Label.String_VehicleConsultation;    
    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();

    private static final Map<String,String> fuelMap {
        get {
            if(fuelMap != null) {
                return fuelMap;
            }
            else {
                fuelMap = new Map<String,String>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'VehicleTypeFuel' AND IsActive__c = true]) {
                            fuelMap.put(lLegacyDomainTableValue.Key__c, lLegacyDomainTableValue.Value__c);
                }
                return fuelMap;
            }            
        }
        set;
    }
    
    public String codMarcaModelo;
    public String codTipoVeiculo;
    public String anoFabricacao;
    public String anoModelo;
    public String placa;
    public String chassi;
    public String combustivel;
    public String descricaoVeiculo;
    public String restricao1;
    public String restricao2;
    public String restricao3;
    public String restricao4;

    public VehicleSearchWebService_cls() {
        super(VEHICLE);
        this.restricao1 = '';
        this.restricao2 = '';
        this.restricao3 = '';
        this.restricao4 = '';
    }

     public Vehicle__c getVehicleSearch(String chassiPlaca){
        String parameter = Label.ParameterPlate;
        if(chassiPlaca.length()>7){
            parameter =  Label.ParameterChassi;
        }else if(chassiPlaca.length()>17){
            String placa = chassiPlaca.left(7);
            String chassi = chassiPlaca.right(17);
            parameter = parameter+placa+ Label.ParameterChassi2 +chassi;
        }
        
        String lEndpoint = this.fReq.getEndpoint();
		this.fReq.setEndpoint(lEndpoint+parameter+chassiPlaca);
		AWS_API.ResponseWrapper lResult =  this.doRequest();    
		system.debug('getVehicle Body: ' + lResult.response.getBody());                  
        if(!lResult.success) {
            //é pego o id da regra de atribuição de caso para se a integração quebrar, será criado um registro de caso e definido a regra de atribuição a ele. 
            //(Regra de atribuição não roda sozinha quando o registro é criado via APEX) 
            //https://help.salesforce.com/articleView?id=000338182&type=1&mode=1
            List<AssignmentRule>  lAssigmentRuleIdLst = [SELECT Id FROM AssignmentRule WHERE SobjectType = :Label.SObjectNameCase and Active = true];
            Database.DMLOptions lDMLOptions = new Database.DMLOptions();
            lDMLOptions.EmailHeader.triggerUserEmail = true;
            lDMLOptions.assignmentRuleHeader.assignmentRuleId = lAssigmentRuleIdLst[0].Id;

            Case lCase = new Case(Subject = Label.String_StatusCode + ' ' + String.Valueof(lResult.response.getStatusCode()), Status = Label.String_OnHold , RecordCode__c = Label.FieldValueCodeNull, Description = lResult.message, ObjectType__c = Label.FieldValueSearchVehicle, RecordTypeId = SUPPORT_API, Origin = Label.FieldValueIntegrationFailure);
            lCase.setOptions(lDMLOptions);
            insert lCase;
            
            return null;
        }
        else {
			return getVehicle((VehicleSearchWebService_cls) System.JSON.deserialize(lResult.response.getBody(), VehicleSearchWebService_cls.class));
        }  
	}

    public Vehicle__c getVehicle(VehicleSearchWebService_cls aVehicleInfos){
		Vehicle__c lVehicle = new Vehicle__c();
        lVehicle.plate__c = aVehicleInfos.placa != null ? aVehicleInfos.placa  : '';
        lVehicle.Chassi__c = aVehicleInfos.chassi != null ? aVehicleInfos.chassi  : '';
        //lVehicle.ModelCode__c = aVehicleInfos.codMarcaModelo != null ? aVehicleInfos.codMarcaModelo  : ''; 	//Retirado pois valor desse campo vai vir pela integração de veículo
        //lVehicle.VehicleCode__c = aVehicleInfos.codTipoVeiculo != null ? aVehicleInfos.codTipoVeiculo  : ''; 	//Retirado pois o campo tipo de veículo é referente ao tipo de modal
        lVehicle.ModelYear__c = aVehicleInfos.anoModelo != null ? aVehicleInfos.anoModelo  : '';
        lVehicle.TypeFuel__c = fuelMap.get(String.valueOf(aVehicleInfos.combustivel != null ? aVehicleInfos.combustivel  : '').toLowerCase());
        lVehicle.Name = aVehicleInfos.descricaoVeiculo != null ? aVehicleInfos.descricaoVeiculo  : '';
        lVehicle.YearManufacture__c = aVehicleInfos.anoFabricacao != null ? aVehicleInfos.anoFabricacao  : '';
        if(aVehicleInfos.restricao1 != '') {	
            lVehicle.Restrictions__c += aVehicleInfos.restricao1 != Label.String_NoRestriction ? Label.String_ConsiderRestrictions + ' : ' + aVehicleInfos.restricao1 + '\n' : '';
		}
        if(aVehicleInfos.restricao1 != '') {	
            lVehicle.Restrictions__c += aVehicleInfos.restricao2 != Label.String_NoRestriction ? Label.String_ConsiderRestrictions + ' : ' + aVehicleInfos.restricao2 + '\n' : '';
		}
        if(aVehicleInfos.restricao1 != '') {	
            lVehicle.Restrictions__c += aVehicleInfos.restricao3 != Label.String_NoRestriction ? Label.String_ConsiderRestrictions + ' : ' + aVehicleInfos.restricao3 + '\n' : '';
		}
        if(aVehicleInfos.restricao1 != '') {	
            lVehicle.Restrictions__c += aVehicleInfos.restricao4 != Label.String_NoRestriction ? Label.String_ConsiderRestrictions + ' : ' + aVehicleInfos.restricao4 + '\n' : '';
        }
        if(String.isBlank(lVehicle.Restrictions__c) || !lVehicle.Restrictions__c.contains(Label.String_ConsiderRestrictions) ){
            lVehicle.Restrictions__c = 'NADA CONSTA';
        }else{
            lVehicle.Restrictions__c = lVehicle.Restrictions__c.remove('null');
        }
        lVehicle.Step__c = Label.String_Step2;
        lVehicle.VehicleStatus__c = Label.Status_Deployment ;
		
		return lVehicle;
	}
}