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
* @version   1.0    2020-07-28      Misael Ribas          class created 
**************************************************************************************************************/
@isTest
public class ContractInstallmentHandler_tst {
	
    @isTest
    static void ProviderWithoutContractTest(){
        // Método de teste que verifica se a classe Handler criará um Contrato e vinculará a Parcela criada
        
        String lReturnMsg;
        
        Account lAccount = AccountFactory.createAccountProvider();
        lAccount.Code__c = 111;
        insert lAccount;
        
        DiscountType__c lDiscountType = new DiscountType__c ();
        lDiscountType.Name = 'Porto Saúde';
        lDiscountType.Type__c = Label.DiscountTypeCodePortoHealth;
        lDiscountType.Status__c = Label.DiscountTypeStatusActive;
        lDiscountType.Priority__c = '1';
        insert lDiscountType;
        
        ContractInstallment__c lParcel = ContractInstallmentFactory.createContractInstallmentPortoHealth();
        lParcel.ProviderCode__c = lAccount.Code__c;
        
        insert lParcel;
        System.debug('Primeiro teste ok');
        
        Contract lContract = [SELECT Id, ProviderCode__c, AccountId, ContractNumber__c FROM Contract WHERE AccountId =: lAccount.Id];
        lParcel = [SELECT Id, ProviderCode__c FROM ContractInstallment__c WHERE ContractId__c =: lContract.Id];
        
        String lContractNumber = lAccount.Code__c + '-01';
        System.assertEquals(lContract.AccountId, lAccount.Id);
        System.assertEquals(lContract.ContractNumber__c, lContractNumber);
        
        
    }
    
    @isTest
    static void ProviderWithContractTest(){
        // Método de teste que verifica se a classe Handler criará uma Parcela e vinculará ela a um Contrato existente de seu Prestador
        
        String lReturnMsg;
        
        Account lAccount = AccountFactory.createAccountProvider();
        insert lAccount;
        
        Contract lContract = ContractFactory.createContractPortoHealth(lAccount.Id);
        insert lContract;
        
        ContractInstallment__c lParcel = ContractInstallmentFactory.createContractInstallmentPortoHealth();
        lParcel.ProviderCode__c = lAccount.Code__c;
        
        try{
            insert lParcel;
            
            lParcel = [SELECT Id, ContractId__c FROM ContractInstallment__c LIMIT 1];
        	System.assertEquals(lParcel.ContractId__c, lContract.Id);
            System.debug('Segundo teste ok');
        }
        catch(Exception e){
            lReturnMsg = 'Insert failed: ' + e.getMessage();
            System.debug('Segundo teste falhou');
        }        
    }
    
    @isTest
    static void ContractInstallmentErrorTest(){
        // Método de teste que verifica se a classe Handler retornará uma mensagem de erro quando tentamos inserir 
        // uma Parcela sem um Prestador existente 
        
        ContractInstallment__c lParcel = ContractInstallmentFactory.createContractInstallmentPortoHealth();
        lParcel.ProviderCode__c = 83783;
        
        String lReturnMsg;
        String lMsgTest = 'não localizado';
        
        try{
            insert lParcel;
        }
        catch(DMLException e){
            lReturnMsg = 'Insert failed: ' + e.getDmlMessage(0);
            System.assertEquals(lReturnMsg.contains(lMsgTest), true);
        }
    }
    
    @isTest
    static void ContractInstallmentErrorTest2(){
        // Método de teste que verifica se a classe Handler retornará uma mensagem de erro quando tentamos inserir duas 
        // parcelas com o mesmo mês de referência em um contrato
                
        List<ContractInstallment__c> lParcelList = new List<ContractInstallment__c>();
            
        Account lAccount = AccountFactory.createAccountProvider();
        lAccount.Code__c = 111;
        insert lAccount;
        
        DiscountType__c lDiscountType = new DiscountType__c ();
        lDiscountType.Name = 'Porto Saúde';
        lDiscountType.Type__c = Label.DiscountTypeCodePortoHealth;
        lDiscountType.Status__c = Label.DiscountTypeStatusActive;
        lDiscountType.Priority__c = '1';
        insert lDiscountType;
        
        Contract lContract = ContractFactory.createContractPortoHealth(lAccount.Id);
        insert lContract;
        
        ContractInstallment__c lParcel = ContractInstallmentFactory.createContractInstallmentPortoHealth();
        lParcel.ProviderCode__c = lAccount.Code__c;
        lParcel.ReferenceDate__c = system.today();
        lParcelList.add(lParcel);
        
        ContractInstallment__c lParcel2 = new ContractInstallment__c();
        lParcel2.RecordTypeId = SObjectType.ContractInstallment__c.getRecordTypeInfosByDeveloperName().get('PortoHealth').getRecordTypeId();
        lParcel2.ProviderCode__c = lAccount.Code__c;
        lParcel2.Discount__c = 1724.93;
        lParcel2.Credit__c = 1259.75;
        lParcel2.ReferenceDate__c = system.today();
        lParcelList.add(lParcel2);

        try{
            insert lParcelList;
            System.debug('Quarto teste falhou');
            
            lParcel = [SELECT Id, ReferenceDate__c, ContractId__c, ProviderCode__c FROM ContractInstallment__c WHERE Id =:lParcel.Id LIMIT 1];
            lParcel2 = [SELECT Id, ReferenceDate__c, ContractId__c, ProviderCode__c FROM ContractInstallment__c WHERE Id =:lParcel2.Id LIMIT 1];
            
            system.debug('lParcel: ' + lParcel);
            system.debug('lParcel: ' + lParcel2);
        }
        catch(DMLException e){
            System.assert(e.getDmlMessage(0).contains(Label.InstallmentAlreadyRegisteredThisMonth), 'Erro na validação de parcela criada para o mesmo mês! ' + e.getDmlMessage(0));
            System.debug('Quarto teste ok');
        }
        
    }
    
	@isTest
    static void ContractInstallmentErrorTest3(){
        // Método de teste que verifica se a classe Handler retornará uma mensagem de erro quando tentamos inserir uma parcela, 
        // quando já existe outra parcela com o mesmo mês de referência no contrato
                
        Account lAccount = AccountFactory.createAccountProvider();
        lAccount.Code__c = 111;
        insert lAccount;        
        
        DiscountType__c lDiscountType = new DiscountType__c ();
        lDiscountType.Name = 'Porto Saúde';
        lDiscountType.Type__c = Label.DiscountTypeCodePortoHealth;
        lDiscountType.Status__c = Label.DiscountTypeStatusActive;
        lDiscountType.Priority__c = '1';
        insert lDiscountType;
        
        Contract lContract = ContractFactory.createContractPortoHealth(lAccount.Id);
        insert lContract;
        
        ContractInstallment__c lParcel = ContractInstallmentFactory.createContractInstallmentPortoHealth();
        lParcel.ProviderCode__c = lAccount.Code__c;
        lParcel.ContractId__c = lContract.Id;
        lParcel.ReferenceDate__c = system.today();
        insert lParcel;
        
        ContractInstallment__c lParcel2 = new ContractInstallment__c();
        lParcel2.RecordTypeId = SObjectType.ContractInstallment__c.getRecordTypeInfosByDeveloperName().get('PortoHealth').getRecordTypeId();
        lParcel2.ProviderCode__c = lAccount.Code__c;
        lParcel2.Discount__c = 1724.93;
        lParcel2.Credit__c = 1259.75;
        lParcel2.ReferenceDate__c = system.today();
        
        try{
            insert lParcel2;
            System.debug('Quinto teste falhou');
        }
        catch(DMLException e){
            System.assert(e.getDmlMessage(0).contains(Label.InstallmentAlreadyRegisteredThisMonth), 'Erro na validação de parcela criada para o mesmo mês! ' + e.getDmlMessage(0));
            System.debug('Quinto teste ok');
        }
    } 
}