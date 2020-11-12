/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do Seguro Auto WebService
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-03-23      Mariana Ribeiro         class created 
**************************************************************************************************************/
public with sharing class VehicleInsuranceAutoWebService_cls extends AWS_API{
    private static final String VEHICLE = Label.String_VehicleInsurance;
    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();
    
    public String NumeroApolice;
    public String CodigoSucursal;
    public String DataInicioVigencia;
    public String DataFimVigencia;
    public Integer CodigoModeloVeiculo;
    public String StatusApolice;

    public class VigenciaDetail {
        public String termino;
		public String inicio;
    }

    public VehicleInsuranceAutoWebService_cls() {
        super(VEHICLE);
    }

     public Vehicle__c getInsuranceAutoStatus(String aPlaca, String aChassi, String aAssigmentRuleId, Decimal aCode){
        String lParameter = '?placa=' + aPlaca + '&chassi=' + aChassi;  
        String lEndpoint = this.fReq.getEndpoint();
		this.fReq.setEndpoint(lEndpoint+lParameter);
		AWS_API.ResponseWrapper lResult =  this.doRequest();    
		system.debug('getVehicle Body: ' + lResult.response.getBody());                  
        if(!lResult.success) {
            system.debug('sem sucesso');
            
            Database.DMLOptions lDMLOptions = new Database.DMLOptions();
            lDMLOptions.EmailHeader.triggerUserEmail = true;
            lDMLOptions.assignmentRuleHeader.assignmentRuleId = aAssigmentRuleId;

            Case lCase = new Case(Subject = Label.String_StatusCode, Status = Label.String_OnHold , RecordCode__c = String.valueOf(aCode), Description = lResult.message, ObjectType__c = 'Pesquisa seguro auto (Vehicle__c)', RecordTypeId = SUPPORT_API, Origin = Label.FieldValueIntegrationFailure);
            lCase.setOptions(lDMLOptions);
            insert lCase;
            return null;
        }
        else {
			return getInsuranceAuto((VehicleInsuranceAutoWebService_cls) System.JSON.deserialize(lResult.response.getBody(), VehicleInsuranceAutoWebService_cls.class));
        }  
	}

    public Vehicle__c getInsuranceAuto(VehicleInsuranceAutoWebService_cls aInsuranceAuto){
		Vehicle__c lVehicle = new Vehicle__c();
		
		if(aInsuranceAuto != null){
            lVehicle.policy__c = aInsuranceAuto.NumeroApolice != null ? aInsuranceAuto.NumeroApolice  : '';
            lVehicle.ModelCode__c = aInsuranceAuto.CodigoModeloVeiculo != null ? String.ValueOf(aInsuranceAuto.CodigoModeloVeiculo)  : '';
            lVehicle.BranchCode__c = aInsuranceAuto.CodigoSucursal != null ? aInsuranceAuto.CodigoSucursal  : '';
            if(aInsuranceAuto.DataFimVigencia != null){
                Date myDate = date.newinstance(Integer.ValueOf(aInsuranceAuto.DataFimVigencia.right(4)), Integer.ValueOf(aInsuranceAuto.DataFimVigencia.mid(3,2)), Integer.ValueOf(aInsuranceAuto.DataFimVigencia.left(2)));
                lVehicle.InsuranceExpiration__c = myDate;
            }
            if(aInsuranceAuto.StatusApolice != null){
                lVehicle.InsuranceAuto__c = aInsuranceAuto.StatusApolice == 'A' ? Label.Status_Active : Label.Status_Inactive; 
            }
        }else{
            lVehicle.InsuranceAuto__c = Label.Status_Inactive;
        }
		return lVehicle;
	}
}