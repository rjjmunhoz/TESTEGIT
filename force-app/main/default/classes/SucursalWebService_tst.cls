/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      test class of the SucursalWebService_cls class
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-05-29      Misael Ribas            class created 
**************************************************************************************************************/
@isTest
public class SucursalWebService_tst {
    @isTest
    static void getSucursalTest(){
        String lBodyResponse = Label.BodyResponseCreated;  
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        test.startTest();
        
        Account lAccount = AccountFactory.createAccountProvider();
        lAccount.TaxCity__c = 'São Paulo';
        lAccount.TaxUf__c = 'SP';
        insert lAccount;
        
        test.stopTest();
    }
}