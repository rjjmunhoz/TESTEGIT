/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Classe para cobrir os cenários de teste da classe SpecialtyModalHandler_cls
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-05-12      Matheus Branco          class created 
**************************************************************************************************************/
@isTest
public class SpecialtyModalHandler_tst {
    @isTest
    static void SpecialtyServiceJunctionTest(){
        
        String lReturnMsg;//Mensagem de erro
		
        Product2 lSpecialty = Product2Factory.createProduct2Specialty();
        insert lSpecialty;

        Modal__c lModal = ModalFactory.createModalTaxi('Taxi Teste');
        insert lModal;

        SpecialtyModal__c lJunction = new SpecialtyModal__c();
        lJunction.Modal__c = lModal.Id;
        lJunction.Product2__c = lSpecialty.Id;
        insert lJunction;
        system.debug('Teste: ' + lJunction.Id);

        try{
            update lJunction;
        }
        catch(Exception e){
           system.debug('Erro try/Catch: ');
            lReturnMsg = Label.String_Insert_Failed + ' ' + e.getMessage();
        }
        
        SpecialtyModal__c lJunction2 = new SpecialtyModal__c();
        lJunction2.Modal__c = lModal.Id;
        lJunction2.Product2__c = lSpecialty.Id;
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