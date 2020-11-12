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
* @version   1.0    2020-04-08      Misael RIbas            class created 
**************************************************************************************************************/
@isTest
public class SupplyHandler_tst {
	@isTest
    static void AbilityJunctionTest(){
        
		String lReturnMsg;//Mensagem de erro
		
        Modal__c lModal = ModalFactory.createModalMotorcycle('aName');
        insert lModal;
        
        OperationalSetup__c lInsumo = OperationalSetupFactory.createOperationalSetupSupply();
        insert lInsumo;
        
        Supply__c lJunction = new Supply__c();
        lJunction.Modal__c = lModal.Id;
        lJunction.OperationalSetup__c = lInsumo.Id;
        insert lJunction;
        system.debug('Teste: ' + lJunction.Id);
        
        try{
            update lJunction;
        }
        catch(Exception e){
           system.debug('Erro try/Catch: ');
            lReturnMsg = 'Insert failed: ' + e.getMessage();
        }
        
        Supply__c lJunction2 = new Supply__c();
        lJunction2.Modal__c = lModal.Id;
        lJunction2.OperationalSetup__c = lInsumo.Id;
        Test.startTest();
        	try{
            	insert lJunction2;
        	}
        	catch(Exception e){
            	lReturnMsg = 'Insert failed: ' + e.getMessage();
        	}
        Test.stopTest();
    }
}