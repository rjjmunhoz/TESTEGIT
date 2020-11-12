/**************************************************************************************************************
* Globant Brasil
* @author        	Misael Ribas (misael.ribas@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para gerar a cobertura das classes EventHandler e CaseHandler
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0     2020-02-06      Misael Ribas            class created
**************************************************************************************************************/

@isTest
public class EventHandler_tst {
    
    
    @isTest
    static void makeComponent(){
        Product2 lProduct = Product2Factory.createProduct2Service();
        Insert lProduct;
        Case lCase = CaseFactory.createCasePortfolioAnalysis(lProduct);
        insert lCase;
        Contact lContact = UserFactory.createContact();
        insert lContact;
        
        Event lEvent = new Event();
        lEvent.whoId = lContact.Id;
        lEvent.whatId = lCase.Id;
        lEvent.Subject = Label.String_Align_Execution;
        lEvent.StartDateTime = DateTime.newInstance(2020, 02, 04, 04, 0, 0);
        lEvent.EndDateTime = DateTime.newInstance(2020, 02, 04, 04, 0, 0);
        
        insert lEvent;
        
        lEvent.StartDateTime = DateTime.newInstance(2020, 02, 05, 04, 0, 0);
        lEvent.EndDateTime = DateTime.newInstance(2020, 02, 05, 04, 0, 0);
        update lEvent;
        
        
    }

}