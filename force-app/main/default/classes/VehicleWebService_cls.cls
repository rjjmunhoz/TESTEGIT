/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de veículo
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-03-25      Mariana Ribeiro         class created 
**************************************************************************************************************/
public with sharing class VehicleWebService_cls extends AWS_API{

    private static final Map<String,Integer> statusMap {
        get {
            if(statusMap != null) {
                return statusMap;
            }
            else {
                statusMap = new Map<String,Integer>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'VehicleStatus' AND IsActive__c = true]) {
                    statusMap.put(lLegacyDomainTableValue.Key__c, Integer.valueOf(lLegacyDomainTableValue.Value__c));
                }
                return statusMap;
            }            
        }
        set;
    }

    
    private static final String VEHICLE = Label.String_Vehicle;
    
    
    public Integer CodigoVeiculo;
	public String NomeProprietario;
	public Integer CodigoModal;
	public Integer CodigoTipoCadastro;
	public Integer CodigoStatusVeiculo;
	public List<Telefones> Telefones;
	public DadosVeiculo DadosVeiculo;
	public DadosPadronizacao DadosPadronizacao;
	public DadosPrestador DadosPrestador;
	public DadosSistema DadosSistema;
	public List<String> Empresas;
	public List<SpecialtyWrapper_cls.Especialidades> Especialidades;
	public List<Integer> Equipamentos;

	public class DadosVeiculo {
		public Integer CodigoModeloVeiculo;
		public Integer AnoFabricacao;
		public Integer AnoModelo;
		public String Placa;
		public String Chassi;
		public Long Renavam;
		public Integer CodigoCorVeiculo;
		public Integer CodigoTipoCombustivel;
		public Integer CodigoTipoAquisicao;
		public Integer CodigoModeloVeiculoFipe;
	}

	public class DadosPrestador {
		public Integer CodigoPrestador;
		public List<Integer> TipoContrato;
	}

	public class DadosPadronizacao {
		public String FlagPossuiSemParar;
		public String SiglaVeiculo;
	}

	public class Telefones {
		public Integer CodigoTipoTelefone;
        public String NumeroTelefone;
        public Telefones(Integer aCodigoTipoTelefone, String aNumeroTelefone) {
            this.CodigoTipoTelefone = aCodigoTipoTelefone;
            this.NumeroTelefone = aNumeroTelefone;
        }
	}

	public class DadosSistema {
		public Datetime DataCadastro;
        public String UsuarioCadastro;
        public Datetime DataAtualizacao;
        public String UsuarioAtualizacao;
	}


    public VehicleWebService_cls(SObject aVehicle, List<SpecialtyWrapper_cls.Especialidades> aVehicleSpecialtyLst, List<Integer> aEquipmentLst) {
        super(VEHICLE);        
        Vehicle__c lVehicle = (Vehicle__c)aVehicle;
        
        this.CodigoVeiculo = lVehicle.Code__c != null?Integer.valueOf(lVehicle.Code__c):null;
        this.NomeProprietario = lVehicle.OwnerName__c;
        this.CodigoModal = String.isNotBlank(lVehicle.ModalName__c)?Integer.valueOf(lVehicle.ModalName__c):null;
        this.CodigoTipoCadastro = String.isNotBlank(lVehicle.TypeRegistration__c)?Integer.valueOf(lVehicle.TypeRegistration__c):null;
        this.CodigoStatusVeiculo = String.isNotBlank(lVehicle.VehicleStatus__c) ? statusMap.get(lVehicle.VehicleStatus__c) : null;

        this.Telefones = new List<Telefones>();
        if(String.isNotBlank(lVehicle.secondaryphone__c)) {
            this.Telefones.add( new Telefones(3,lVehicle.secondaryphone__c));
        }
        if(String.isNotBlank(lVehicle.phone__c)) {
            this.Telefones.add( new Telefones(1,lVehicle.phone__c));
        }
        this.DadosVeiculo = new DadosVeiculo();
        this.DadosVeiculo.CodigoModeloVeiculo = String.isNotBlank(lVehicle.ModelCode__c)?Integer.valueOf(lVehicle.ModelCode__c):null;
		this.DadosVeiculo.AnoFabricacao = String.isNotBlank(lVehicle.YearManufacture__c)?Integer.valueOf(lVehicle.YearManufacture__c):null;
		this.DadosVeiculo.AnoModelo = String.isNotBlank(lVehicle.ModelYear__c)?Integer.valueOf(lVehicle.ModelYear__c):null;
		this.DadosVeiculo.Placa = lVehicle.plate__c;
		this.DadosVeiculo.Chassi = lVehicle.Chassi__c;
		this.DadosVeiculo.Renavam = String.isNotBlank(lVehicle.RenavamCode__c)?Long.valueOf(lVehicle.RenavamCode__c):null;
		this.DadosVeiculo.CodigoCorVeiculo = String.isNotBlank(lVehicle.Color__c)?Integer.valueOf(lVehicle.Color__c):null;
        System.debug('lVehicle.TypeFuel__c: '+lVehicle.TypeFuel__c);
		this.DadosVeiculo.CodigoTipoCombustivel = String.isNotBlank(lVehicle.TypeFuel__c)?Integer.valueOf(lVehicle.TypeFuel__c):null;
		this.DadosVeiculo.CodigoTipoAquisicao = String.isNotBlank(lVehicle.TypeAcquisition__c)?Integer.valueOf(lVehicle.TypeAcquisition__c):null;
        this.DadosVeiculo.CodigoModeloVeiculoFipe = 0; // Ver se o campo será criado no veiculo
        
        this.DadosPadronizacao = new DadosPadronizacao();
        this.DadosPadronizacao.FlagPossuiSemParar = lVehicle.Nonstop__c == Label.String_Yes ? 'S':null;
        this.DadosPadronizacao.SiglaVeiculo = lVehicle.Initials__c;

        this.DadosPrestador = new DadosPrestador();
        this.DadosPrestador.CodigoPrestador = lVehicle.ProviderCode__c!=null?Integer.valueOf(lVehicle.ProviderCode__c):null;  
        this.DadosPrestador.TipoContrato = new List<Integer>();
        if(String.isNotBlank(lVehicle.ProviderContractType__c)) {
            for(String lContract :lVehicle.ProviderContractType__c.split(';')) {
                if(String.isNotBlank(lContract)) {
                    this.DadosPrestador.TipoContrato.add(Integer.valueOf(lContract.replace(' ', ''))); 
                }
            }
        }
        this.DadosSistema = new DadosSistema();
        this.DadosSistema.DataCadastro = lVehicle.CreatedDate;
        this.DadosSistema.UsuarioCadastro = lVehicle.CreatorFederationIdentifier__c;
        this.DadosSistema.DataAtualizacao = lVehicle.LastModifiedDate;
        this.DadosSistema.UsuarioAtualizacao = lVehicle.ModifierFederationIdentifier__c;

        this.Empresas = (String.isNotBlank(lVehicle.Company__c)?lVehicle.Company__c.split(';'):null);
        
        if(aVehicleSpecialtyLst != null) {
            this.Especialidades = aVehicleSpecialtyLst;
        }
        else {
            this.Especialidades = new List<SpecialtyWrapper_cls.Especialidades>();
        }
        
        if(aEquipmentLst != null) {
            this.Equipamentos = aEquipmentLst;
        }
        else {
            this.Equipamentos = new List<Integer>();
        }
    }

    public AWS_API.ResponseWrapper setAwsVehicle(){
		this.fReq.setBody(JSON.serialize(this));
		AWS_API.ResponseWrapper lResult =  this.doRequest();        
        return lResult;
	}

    public static SpecialtyWrapper_cls getVehicleToIntegration(List<Vehicle__c> aVehicleLst) {
        
        TriggerCheck.assert();

        Set<Id> lModalIdSet = new Set<Id>();
        Map<Id,Vehicle__c> lVehicleToIntegrateMap = new Map<Id,Vehicle__c>();
        for(Vehicle__c lVehicle :aVehicleLst) {
            if(lVehicle.SyncAPI__c ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.YearManufacture__c) ||                      
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.ModelYear__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.Chassi__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.Color__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.Company__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.OwnerName__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.plate__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.Provider__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.Nonstop__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.Name) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.VehicleStatus__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.secondaryphone__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.TypeAcquisition__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.TypeRegistration__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.TypeFuel__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.VehicleCode__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.phone__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.ModelCode__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.RenavamCode__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.Initials__c) ||
                    TriggerCheck.isChanged(lVehicle, Vehicle__c.TypeModal__c)){ 
                // Adicionar a verificação de todos os campos utilizados na integração
                lVehicleToIntegrateMap.put(lVehicle.Id,lVehicle);
                lModalIdSet.add(lVehicle.TypeModal__c);
            }            
        }

        if(lVehicleToIntegrateMap.isEmpty()) return null;

        SpecialtyWrapper_cls lVehicleSpecialtyWr = new SpecialtyWrapper_cls(lVehicleToIntegrateMap.values());
        // Monta um map de Id de Modal com suas Especialidades
        Map<Id,List<SpecialtyWrapper_cls.Especialidades>> lModalSpecialtyLstMap = new Map<Id,List<SpecialtyWrapper_cls.Especialidades>>();
        for(SpecialtyModal__c lSpecMod :[SELECT Modal__c, Product2__r.Code__c, Product2__r.SpecialtyType__c
                FROM SpecialtyModal__c 
                WHERE IsActive__c = true 
                AND Modal__c IN :lModalIdSet 
                AND Product2__r.RecordType.DeveloperName = :Label.SpecialtyRecordType]) {
            List<SpecialtyWrapper_cls.Especialidades> lSpecialtyLst = lModalSpecialtyLstMap.get(lSpecMod.Modal__c);
            if(lSpecialtyLst == null) {
                lSpecialtyLst = new List<SpecialtyWrapper_cls.Especialidades>();
                lModalSpecialtyLstMap.put(lSpecMod.Modal__c, lSpecialtyLst);
            }
            SpecialtyWrapper_cls.Especialidades lEspecialidade = new SpecialtyWrapper_cls.Especialidades();
            lEspecialidade.Segmento = lSpecMod.Product2__r.SpecialtyType__c;
            lEspecialidade.CodigoEspecialidade = Integer.valueOf(lSpecMod.Product2__r.Code__c);
            lSpecialtyLst.add(lEspecialidade);  
        }
        // Monta map de id do veiculo com a lista de suas especialidades(relacionadas ao modal do veiculo)
        if(!lModalSpecialtyLstMap.isEmpty()) {
            for(Vehicle__c lVehicle :lVehicleToIntegrateMap.values()) {
                lVehicleSpecialtyWr.fSpecialtyLstMap.put(lVehicle.Id, lModalSpecialtyLstMap.get(lVehicle.TypeModal__c));
            }
        }

        // Monta um map de Id de Vehiculo com seus Equipamentos
        for(EquipamentVehicle__c lEquipVehic :[SELECT Vehicle__c, Equipament__r.Code__c FROM EquipamentVehicle__c WHERE Vehicle__c IN :lVehicleToIntegrateMap.keySet() AND IsActive__c = true]) {
            List<Integer> lEquipmentLst = lVehicleSpecialtyWr.fEquipmentMap.get(lEquipVehic.Vehicle__c);
            if(lEquipmentLst == null) {
                lEquipmentLst = new List<Integer>();
                lVehicleSpecialtyWr.fEquipmentMap.put(lEquipVehic.Vehicle__c, lEquipmentLst);
            }
            lEquipmentLst.add(Integer.valueOf(lEquipVehic.Equipament__r.Code__c));
        }

        return lVehicleSpecialtyWr;
    }

    public static void setVehicleToSynchronize(Set<Id> aVehicleIdSet) {
        List<Vehicle__c> lVehicleLst = new List<Vehicle__c>();
        for(Id lVehicleId :aVehicleIdSet){
            lVehicleLst.add(new Vehicle__c(Id = lVehicleId, SyncAPI__c = true));
        } 
        if(!lVehicleLst.isEmpty()) update lVehicleLst;
    }
}