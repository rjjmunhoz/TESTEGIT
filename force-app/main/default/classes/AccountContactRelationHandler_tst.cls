/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para cobertura da classe AccountContactRelation
*
* Changes (Version)--
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-06-03      Matheus Branco           class created 
**************************************************************************************************************/

@isTest
public class AccountContactRelationHandler_tst {

    @isTest
    static void predefinedValuesTest(){
    	
        Account lProvider = AccountFactory.createAccountProvider();
        insert lProvider;

        Contact lContact = ContactFactory.createContactBaseEmployee();
        lContact.AccountId = lProvider.Id;
        insert lContact;

        AccountContactRelation lAccountContact = [SELECT Id, Roles, StartDate, EndDate FROM AccountContactRelation WHERE AccountId =: lProvider.Id AND ContactId =: lContact.Id LIMIT 1];
        System.assertEquals(lAccountContact.Roles, Label.BaseEmployeeLabel);
        System.assertEquals(lAccountContact.StartDate, system.today());
        System.assertEquals(lAccountContact.EndDate, Date.newInstance(2999, 01, 01));
    }

    @isTest
    static void blockExclusionTest(){
        Account lProvider = AccountFactory.createAccountProvider();
        insert lProvider;

        Contact lContact = ContactFactory.createContactBaseEmployee();
        lContact.AccountId = lProvider.Id;
        insert lContact;

        AccountContactRelation lAccountContact = [SELECT Id, Roles, StartDate, EndDate FROM AccountContactRelation WHERE AccountId =: lProvider.Id AND ContactId =: lContact.Id LIMIT 1];

        try{
            delete lAccountContact;
        }
        catch(Exception ex){
            System.assert(ex.getMessage().contains(Label.AccountContactRelationExclusionError), ex.getMessage());
        }
    }
}