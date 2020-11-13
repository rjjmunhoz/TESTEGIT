/**************************************************************************************************************
* Globant Brasil
* @author        	Misael RIbas (misael.ribas@globant.com)
* Project:          Porto Socorro
* Description:      
*
* Changes (Version)----
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-08      Misael RIbas          class created 
**************************************************************************************************************/
@isTest
public class AbilityHandler_tst {
    
	@isTest
    static void AbilityJunctionTest(){
        
		String lReturnMsg;
        
        OperationalSetup__c lAbility = new OperationalSetup__c();//OperationalSetupFactory.createOperationalSetupAbility();
		Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Ability').getRecordTypeId();
        lAbility.RecordTypeId = OSRecordType;
        lAbility.Name = 'teste3';
        lAbility.Perfil__c = 'Básico';
        lAbility.Description__c = 'teste3';
        lAbility.Status__c = 'Em implantação';
        insert lAbility;
        
        Product2 lProduct2 = new Product2();//Product2Factory.createProduct2Detail();
        Id lSpecialtyRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Specialty').getRecordTypeId();
        lProduct2.RecordTypeId = lSpecialtyRecType;
        lProduct2.Name = 'Detalhe/Motivo';
        lProduct2.Description__c = 'Descrição';
        lProduct2.Status__c = 'Em implantação';
        insert lProduct2;
        
        Ability__c lJunction = new Ability__c();
        lJunction.Product2__c = lProduct2.Id;
        lJunction.OperationalSetup__c = lAbility.Id;
        insert lJunction;
                
        lJunction.Product2__c = lProduct2.Id;
        try{
            update lJunction;
        }
        catch(Exception e){
           system.debug('Erro try/Catch: ');
            lReturnMsg = 'Insert failed: ' + e.getMessage();
        }
        
        Ability__c lJunction2 = new Ability__c();
        lJunction2.Product2__c = lProduct2.Id;
        lJunction2.OperationalSetup__c = lAbility.Id;
        
        Test.startTest();
        	try{
            	insert lJunction2;
        	}
        	catch(Exception e){
            	lReturnMsg = 'Insert failed: ' + e.getMessage();
        	}
        Test.stopTest();
    }

    @isTest
    static void ValidateJunctionAbilityRescuerTest(){
        String lReturnMsg;
        
        OperationalSetup__c lAbility = new OperationalSetup__c();//OperationalSetupFactory.createOperationalSetupAbility();
		Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Ability').getRecordTypeId();
        lAbility.RecordTypeId = OSRecordType;
        lAbility.Name = 'teste3';
        lAbility.Perfil__c = 'Básico';
        lAbility.Description__c = 'teste3';
        lAbility.Status__c = 'Em implantação';
        insert lAbility;
        
        Contact lContact = new Contact();//Product2Factory.createProduct2Detail();
        Id BaseEmployeesRecType = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('BaseEmployees').getRecordTypeId();
        lContact.RecordTypeId = BaseEmployeesRecType;
        lContact.LastName = 'Teste Colaborador';
        lContact.Status__c = 'Em implantação';
        insert lContact;
        
        Ability__c lJunction = new Ability__c();
        lJunction.RescuerId__c = lContact.Id;
        lJunction.Ability__c = lAbility.Id;
        insert lJunction;
                
        lJunction.RescuerId__c = lContact.Id;
        try{
            update lJunction;
        }
        catch(Exception e){
           system.debug('Erro try/Catch: ');
            lReturnMsg = 'Insert failed: ' + e.getMessage();
        }
        
        Ability__c lJunction2 = new Ability__c();
        lJunction2.RescuerId__c = lContact.Id;
        lJunction2.OperationalSetup__c = lAbility.Id;
        
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