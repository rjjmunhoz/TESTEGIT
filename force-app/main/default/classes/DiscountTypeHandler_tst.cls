@isTest
public class DiscountTypeHandler_tst {
    @isTest
    static void DiscountDuplicateError(){
        
        User lUserAnalyst = UserFactory.createUserAnalist();
        insert lUserAnalyst;
        system.runAs(lUserAnalyst) {
        	
            Account lAccount = AccountFactory.createAccountProvider();
        	insert lAccount;
        	
        	DiscountType__c lType = DiscountTypeCreate();
            insert lType;
        	
        	Contract lContract = ContractFactory.createContractPortoHealth(lAccount.Id);
        	lContract.DiscountType__c = lType.Id;
        	insert lContract;
        	
        	DiscountType__c lType2 = DiscountTypeCreate();
        	try{
        		insert lType2;
        	}
        	catch( DmlException e){
        		system.debug('ERROR: ' + e);
        		system.assertEquals(e.getMessage().contains(Label.DuplicateDiscountTypeAlert), true);
        	}
        
        	lType.Status__c = 'Inativo';
        	update lType;
            
            
        }
    }
    
    static DiscountType__c DiscountTypeCreate(){
        	
        	DiscountType__c lType = new DiscountType__c();
        	lType.Name = 'Teste';
        	lType.Priority__c = '1';
        	lType.ExpenseCode__c = '123456';
        	lType.CostCenter__c = '1200';
        	lType.Type__c = '1';
        	lType.Status__c = 'Ativo';
        
        	return lType;
    }
}