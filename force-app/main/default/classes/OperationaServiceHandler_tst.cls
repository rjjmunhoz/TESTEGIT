/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-08      Mariana Ribeiro         class created 
**************************************************************************************************************/
@isTest
public class OperationaServiceHandler_tst {
	@isTest
    static void OperationaServiceJunctionTest(){
        
        String lReturnMsg;//Mensagem de erro
		
        Product2 lOperationalService = Product2Factory.createProduct2Specialty();
        lOperationalService.OperationalService__c = true;
        insert lOperationalService;
        
        /*lProduct2 lSpecialty = Product2Factory.createProduct2Specialty();
        lSpecialty.Name = 'Especialidade2';
        insert lSpecialty;*/
        
        OperationalService__c lJunction = new OperationalService__c();
        lJunction.Specialty__c	 = lOperationalService.Id;
        lJunction.OperationalService__c = lOperationalService.Id;
        insert lJunction;
        system.debug('Teste: ' + lJunction.Id);

        try{
            update lJunction;
        }
        catch(Exception e){
           system.debug('Erro try/Catch: ');
            lReturnMsg = Label.String_Insert_Failed + ' ' + e.getMessage();
        }
        
       	OperationalService__c lJunction2 = new OperationalService__c();
        lJunction2.Specialty__c	 = lOperationalService.Id;
        lJunction2.OperationalService__c = lOperationalService.Id;
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