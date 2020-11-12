/**************************************************************************************************************
* Globant Brasil
* @author           Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService para esquecimento LGPD
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                          Description     
*           -----   ----------      --------------------            ---------------   
* @version   1.0    2020-04-27      Eduardo Costa/Matheus Branco    class created 
**************************************************************************************************************/
public with sharing class LgpdForgetWebService extends AWS_API {
    private static final String LGPD_FORGET = Label.LgpdForget;
    
    public Integer pescod;
    public Integer ticket;
    public String status;

    public LgpdForgetWebService(Contact aContact, String LgpdStatus) {
        super(LGPD_FORGET);

        this.pescod = aContact.PesCod__c!=null?Integer.valueOf(aContact.PesCod__c):null;
        this.ticket = aContact.LgpdTicket__c!=null?Integer.valueOf(aContact.LgpdTicket__c):null;
        this.status = LgpdStatus;
    }    

    public AWS_API.ResponseWrapper setLgpdForget(){

        this.fReq.setBody(JSON.serialize(this));
        AWS_API.ResponseWrapper lResult =  this.doRequest();
        system.debug('Result.success ' + lResult);       
        return lResult;
    }
}