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
public class EquipmentHandler_tst {
	@isTest
    static void EquipmentJunctionTest(){
        
        String lReturnMsg;//Mensagem de erro
		
        Modal__c lModal = ModalFactory.createModalMotorcycle('aName');
        insert lModal;
        
        OperationalSetup__c lEquipament = OperationalSetupFactory.createOperationalSetupEquipamento();
        insert lEquipament;
        
        Equipment__c lJunction = new Equipment__c();
        lJunction.Modal__c = lModal.Id;
        lJunction.OperationalSetup__c = lEquipament.Id;
        insert lJunction;
        system.debug('Teste: ' + lJunction.Id);
        
        lJunction.Modal__c = lModal.Id;
        try{
            update lJunction;
        }
        catch(Exception e){
           system.debug('Erro try/Catch: ');
            lReturnMsg = 'Insert failed: ' + e.getMessage();
        }
        
        Equipment__c lJunction2 = new Equipment__c();
        lJunction2.Modal__c = lModal.Id;
        lJunction2.OperationalSetup__c = lEquipament.Id;
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