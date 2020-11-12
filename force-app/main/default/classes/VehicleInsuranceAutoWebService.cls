public with sharing class VehicleInsuranceAutoWebService extends AWS_API{
    private static final String VEHICLE = Label.String_VehicleInsurance;
    
    public String apolice;
    public String sucursal;
    public VigenciaDetail vigencia;
    public String status;

    public class VigenciaDetail {
        public String termino;
		public String inicio;
    }

    public VehicleInsuranceAutoWebService() {
        super(VEHICLE);
    }

     public Vehicle__c getInsuranceAutoStatus(String chassiPlaca){
        String lEndpoint = this.fReq.getEndpoint();
		this.fReq.setEndpoint(lEndpoint+chassiPlaca);
		AWS_API.ResponseWrapper lResult =  this.doRequest();    
		system.debug('getVehicle Body: ' + lResult.response.getBody());                  
        if(!lResult.success) {
            system.debug('sem sucesso');
            insert new Log__c(Message__c = lResult.message, Object__c = Label.ObjectVehicle, ObjectId__c = chassiPlaca);
            return null;
        }
        else {
			return getInsuranceAuto((List<VehicleInsuranceAutoWebService>) System.JSON.deserialize(lResult.response.getBody(), List<VehicleInsuranceAutoWebService>.class));
        }  
	}

    public Vehicle__c getInsuranceAuto(List<VehicleInsuranceAutoWebService> aInsuranceAuto){
		Vehicle__c lVehicle = new Vehicle__c();
		
		if(!aInsuranceAuto.isEmpty()){
            Integer size = aInsuranceAuto.size() - 1;
            lVehicle.policy__c = aInsuranceAuto[size].apolice != null ? aInsuranceAuto[size].apolice  : '';
            lVehicle.BranchCode__c = aInsuranceAuto[size].sucursal != null ? aInsuranceAuto[size].sucursal  : '';
            if(aInsuranceAuto[size].vigencia.termino.left(10) != null){
                Date myDate = date.newinstance(Integer.ValueOf(aInsuranceAuto[size].vigencia.termino.left(4)), Integer.ValueOf(aInsuranceAuto[size].vigencia.termino.mid(5,2)), Integer.ValueOf(aInsuranceAuto[size].vigencia.termino.mid(8,2)));
                lVehicle.InsuranceExpiration__c = myDate;
            }
            if(aInsuranceAuto[size].status != null){
                lVehicle.InsuranceAuto__c = aInsuranceAuto[size].status == Label.Status_Ativa ? Label.Status_Active : Label.Status_Inactive; 
            }
		}
		return lVehicle;
	}
}