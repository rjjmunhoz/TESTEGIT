/**************************************************************************************************************
* Globant Brasil
* @author        	Misael RIbas (misael.ribas@globant.com)
* Project:          Porto Socorro
* Description:      
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-08      Misael RIbas          class created 
**************************************************************************************************************/
@isTest
public class PartHandler_tst {
	@isTest
    static void PartJunctionTest(){
        
		String lReturnMsg;//Mensagem de erro
        
        Product2 lSpecialty = Product2Factory.createProduct2Specialty();
        insert lSpecialty;
        
        OperationalSetup__c lPart = OperationalSetupFactory.createOperationalSetupPart();
        insert lPart;
        
        Part__c lJunction = new Part__c();
        lJunction.SpecialtyDetail__c = lSpecialty.Id;
        lJunction.OperationalSetup__c = lPart.Id;
        system.debug('Teste: ' + lJunction);
        insert lJunction;
        system.debug('Teste: ' + lJunction.Id);

        try{
            update lJunction;
        }
        catch(Exception e){
           system.debug('Erro try/Catch');
            lReturnMsg = Label.String_Insert_Failed + ' ' + e.getMessage();
        }
        
        Part__c lJunction2 = new Part__c();
        lJunction2.SpecialtyDetail__c = lSpecialty.Id;
        lJunction2.OperationalSetup__c = lPart.Id;
        Test.startTest();
        	try{
            	insert lJunction2;
        	}
        	catch(Exception e){
            	lReturnMsg = Label.String_Insert_Failed + ' ' + e.getMessage();
        	}
        Test.stopTest();
    }
}