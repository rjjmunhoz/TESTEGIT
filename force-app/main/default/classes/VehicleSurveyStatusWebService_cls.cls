/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do Vistoria Auto WebService
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-03-24      Mariana Ribeiro         class created 
**************************************************************************************************************/
public with sharing class VehicleSurveyStatusWebService_cls extends AWS_API{
    private static final String VEHICLE = 'VistoriaVeiculo';
    
    public String status;
    public String data;

    public VehicleSurveyStatusWebService_cls() {
        super(VEHICLE);
    }

    public Vehicle__c getSurveyStatus(String chassiPlaca){
        String placa = chassiPlaca.left(7);
        String chassi = chassiPlaca.right(17);
        String lEndpoint = this.fReq.getEndpoint();
		this.fReq.setEndpoint(lEndpoint+placa+'/'+chassi);
		AWS_API.ResponseWrapper lResult =  this.doRequest();    
		system.debug('getVehicle Body: ' + lResult.response.getBody());                  
        if(!lResult.success) {
            insert new Log__c(Message__c = lResult.message, Object__c = 'Vehicle', ObjectId__c = chassiPlaca.left(7));
            return null;
        }
        else {
			return getSurvey((VehicleSurveyStatusWebService_cls) System.JSON.deserialize(lResult.response.getBody(), VehicleSurveyStatusWebService_cls.class));
        }  
	}

    public Vehicle__c getSurvey(VehicleSurveyStatusWebService_cls aVehicleInfos){
        Vehicle__c lVehicle = new Vehicle__c();
        if(aVehicleInfos != null){
            
            if(aVehicleInfos.status != null){
                lVehicle.SurveyStatus__c = aVehicleInfos.status == 'APROVADO' ? 'Liberado' : 'Não liberado';
            }
            if(aVehicleInfos.data != null){
                Date myDate = date.newinstance(Integer.ValueOf(aVehicleInfos.data.left(4)), Integer.ValueOf(aVehicleInfos.data.mid(5,2)), Integer.ValueOf(aVehicleInfos.data.mid(8,2)));
                lVehicle.DateLastSurvey__c = myDate;
            }
        }else{
            lVehicle.SurveyStatus__c = 'Não liberado';
        }
        return lVehicle;
	}
}