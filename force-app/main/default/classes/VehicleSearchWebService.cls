public with sharing class VehicleSearchWebService extends AWS_API{
    private static final String VEHICLE = 'ConsultaVeiculo';
    
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

    public VehicleSearchWebService() {
        super(VEHICLE);
        this.restricao1 = '';
        this.restricao2 = '';
        this.restricao3 = '';
        this.restricao4 = '';
    }

     public Vehicle__c getVehicleSearch(String chassiPlaca){
        String parameter = '?placa=';
        if(chassiPlaca.length()>7){
            parameter =  '?chassi=';
        }else if(chassiPlaca.length()>17){
            String placa = chassiPlaca.left(7);
            String chassi = chassiPlaca.right(17);
            parameter = parameter+placa+'&chassi='+chassi;
        }
        
        String lEndpoint = this.fReq.getEndpoint();
		this.fReq.setEndpoint(lEndpoint+parameter+chassiPlaca);
		AWS_API.ResponseWrapper lResult =  this.doRequest();    
		system.debug('getVehicle Body: ' + lResult.response.getBody());                  
        if(!lResult.success) {
            insert new Log__c(Message__c = lResult.message, Object__c = 'Vehicle', ObjectId__c = chassiPlaca);
            return null;
        }
        else {
			return getVehicle((VehicleSearchWebService) System.JSON.deserialize(lResult.response.getBody(), VehicleSearchWebService.class));
        }  
	}

    public Vehicle__c getVehicle(VehicleSearchWebService aVehicleInfos){
		Vehicle__c lVehicle = new Vehicle__c();
        lVehicle.plate__c = aVehicleInfos.placa != null ? aVehicleInfos.placa  : '';
        lVehicle.Chassi__c = aVehicleInfos.chassi != null ? aVehicleInfos.chassi  : '';
        //lVehicle.ModelCode__c = aVehicleInfos.codMarcaModelo != null ? aVehicleInfos.codMarcaModelo  : ''; 	//Retirado pois valor desse campo vai vir pela integração de veículo
        //lVehicle.VehicleCode__c = aVehicleInfos.codTipoVeiculo != null ? aVehicleInfos.codTipoVeiculo  : ''; 	//Retirado pois o campo tipo de veículo é referente ao tipo de modal
        lVehicle.ModelYear__c = aVehicleInfos.anoModelo != null ? aVehicleInfos.anoModelo  : '';
        lVehicle.TypeFuel__c = aVehicleInfos.combustivel != null ? aVehicleInfos.combustivel  : '';
        lVehicle.Name = aVehicleInfos.descricaoVeiculo != null ? aVehicleInfos.descricaoVeiculo  : '';
        lVehicle.YearManufacture__c = aVehicleInfos.anoFabricacao != null ? aVehicleInfos.anoFabricacao  : '';
        if(aVehicleInfos.restricao1 != '') {	
            lVehicle.Restrictions__c += aVehicleInfos.restricao1 != '00-SEM RESTRICAO' ? '<br/> CONSTA RESTRIÇÕES : ' + aVehicleInfos.restricao1 : '';
		}
        if(aVehicleInfos.restricao1 != '') {	
            lVehicle.Restrictions__c += aVehicleInfos.restricao2 != '00-SEM RESTRICAO' ? '<br/> CONSTA RESTRIÇÕES : ' + aVehicleInfos.restricao2 : '';
		}
        if(aVehicleInfos.restricao1 != '') {	
            lVehicle.Restrictions__c += aVehicleInfos.restricao3 != '00-SEM RESTRICAO' ? '<br/> CONSTA RESTRIÇÕES : ' + aVehicleInfos.restricao3 : '';
		}
        if(aVehicleInfos.restricao1 != '') {	
            lVehicle.Restrictions__c += aVehicleInfos.restricao4 != '00-SEM RESTRICAO' ? '<br/> CONSTA RESTRIÇÕES : ' + aVehicleInfos.restricao4 : '';
        }
        if(!lVehicle.Restrictions__c.contains('CONSTA RESTRIÇÕES')){
            lVehicle.Restrictions__c = 'NADA CONSTA';
        }
        lVehicle.Step__c = 'Step2';
        lVehicle.VehicleStatus__c = 'Em implantação';
		
		return lVehicle;
	}
}