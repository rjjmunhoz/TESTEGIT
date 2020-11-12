/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      WS Class to get Sucursal Information for the Providers
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-05-28      Jean Sganzerla         class created 
**************************************************************************************************************/
public with sharing class SucursalWebService_cls extends AWS_API {
    private static final String SUCURSAL = Label.String_Sucursal;
    
    public Integer codigoSucursal;
    public String cidade;
    public String uf;

    public SucursalWebService_cls() {
        super(SUCURSAL);
    }

    public AWS_API.ResponseWrapper getSucursal(String aCity, String aUF, String aId){
        String lCity = '';
        if(String.isNotBlank(aCity)) {
            lCity = Accents_cls.removeDiacritics(aCity).deleteWhitespace();
        }

        String lParameter = Label.ParameterCity + lCity + Label.ParameterUF + aUF;               
        String lEndpoint = this.fReq.getEndpoint();
		this.fReq.setEndpoint(lEndpoint+lParameter);
		AWS_API.ResponseWrapper lResult =  this.doRequest();                  
        if(lResult.success) {
            SucursalWebService_cls lSucursal = (SucursalWebService_cls) System.JSON.deserialize(lResult.response.getBody(), SucursalWebService_cls.class);
            system.debug('SucursalCode: ' + lSucursal.codigoSucursal);
            List<Account>lProvider = [SELECT SucursalCode__c FROM Account WHERE Id = :aId];
            lProvider[0].SucursalCode__c = lSucursal.codigoSucursal;                
            update lProvider;                      
        }
        return lResult;
    }
}