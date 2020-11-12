@isTest
public with sharing class GenerateDiscountOrderPaymentSaude_tst {

    private static final String PORTO_SAUDE_RECTYPE = SObjectType.ContractInstallment__c.getRecordTypeInfosByDeveloperName().get('PortoHealth').getRecordTypeId();
	
	
    @TestSetup
    static void makeData(){
        
        Map<String,String> lConfigurationValues = new Map<String,String>();
        for(PaymentServices__mdt lPaymentServicesConf :[SELECT DeveloperName, Value__c FROM PaymentServices__mdt 
                WHERE DeveloperName IN ('WorkOrderItemType','OrderItemDefaultQuantity','StatusNewPaymentOrder','StatusProcessedPaymentOrder','OrderItemTypeDiscount')]) {
            lConfigurationValues.put(lPaymentServicesConf.DeveloperName, lPaymentServicesConf.Value__c);
        }

        Account lAccount = AccountFactory.createAccountProvider();
        insert lAccount;
        
        DiscountType__c lDiscountType = new DiscountType__c ();
        lDiscountType.Name = 'Porto Saúde';
        lDiscountType.Type__c = Label.DiscountTypeCodePortoHealth;
        lDiscountType.Status__c = Label.DiscountTypeStatusActive;
        lDiscountType.Priority__c = '1';
        insert lDiscountType;
        
        Product2 lService = Product2Factory.createProduct2Specialty();
        lService.TaxCode__c = '14.14';
        insert lService;

        PriceBookEntry lPriceBookEntry = new PriceBookEntry();
        lPriceBookEntry.Product2Id = lService.Id; //Product Id
        lPriceBookEntry.Pricebook2Id = Test.getStandardPricebookId();
        lPriceBookEntry.UnitPrice = 2000;
        lPriceBookEntry.IsActive = true;
        insert lPriceBookEntry; 

        WorkOrder lWorkOrder = new WorkOrder();
        lWorkOrder.Status = 'Analisado e Liberado para Pagamento';
        lWorkOrder.AccountId = lAccount.Id;
        lWorkOrder.Specialty__c = lService.Id;
        lWorkOrder.ActualAmountToBePaid__c = 1000.0;
        lWorkOrder.Company__c = '1';
        insert lWorkOrder; 

        Order lOrder = new Order(    
            Status = lConfigurationValues.get('StatusNewPaymentOrder'),
            Pricebook2Id = Test.getStandardPricebookId(),
            AccountId = lAccount.Id,
            CPFCNPJ__c = lAccount.CNPJ__c,
            OrderTaxCode__c = lService.TaxCode__c,
            Company__c = lWorkOrder.Company__c,
            SucursalCode__c = lAccount.SucursalCode__c,
            Favored__c = lAccount.CompanyName__c,
            FavoredCpfCnpj__c = lAccount.CNPJ__c,
            BankAccountType__c = lAccount.BankAccountType__c,
            Agency__c = lAccount.Branch__c,
            DigitAgency__c = lAccount.DigitAgency__c,
            BankName__c = lAccount.BankName__c,
            BankAccountNumber__c = lAccount.CheckingAccount__c,
            DigitBankAccountNumber__c = lAccount.CurrentAccountDigit__c,
            Aliquot__c = lAccount.ISSTaxRate__c,
            EffectiveDate = Date.today()
        );

        insert lOrder;

        OrderItem lOrderItem = new OrderItem(
            OrderId = lOrder.Id,
            ItemType__c = lConfigurationValues.get('WorkOrderItemType'),
            ServicePaymentOrder__c = lOrder.Id,
            ServiceOrder__c = lWorkOrder.Id,
            RescuerId__c = lWorkOrder.ContactId,
            Vehicle__c = lWorkOrder.Vehicle__c,
            NetValue__c = lWorkOrder.ActualAmountToBePaid__c,
            PricebookEntryId = lPriceBookEntry.Id,
            Quantity = Integer.valueOf(lConfigurationValues.get('OrderItemDefaultQuantity')),
            UnitPrice = lWorkOrder.ActualAmountToBePaid__c
        );

        insert lOrderItem;

        lOrder.Status = lConfigurationValues.get('StatusProcessedPaymentOrder');
        update lOrder;
	}
	
    @isTest
    static void GenerateOrderPaymentSaudeFirstDiscount(){               
        
        Map<String,String> lConfigurationValues = new Map<String,String>();
        for(PaymentServices__mdt lPaymentServicesConf :[SELECT DeveloperName, Value__c FROM PaymentServices__mdt 
            WHERE DeveloperName IN ('WorkOrderItemType','OrderItemDefaultQuantity','StatusNewPaymentOrder','StatusProcessedPaymentOrder','OrderItemTypeDiscount')]) {
            lConfigurationValues.put(lPaymentServicesConf.DeveloperName, lPaymentServicesConf.Value__c);
        }
    
        Account lAccount = [SELECT Code__c FROM Account LIMIT 1];

        ContractInstallment__c lContractInstallment = new ContractInstallment__c();
        lContractInstallment.ProviderCode__c = lAccount.Code__c;
        lContractInstallment.ReferenceDate__c = System.today();
        lContractInstallment.Credit__c = 500.0;
        lContractInstallment.Discount__c = 1000;
        lContractInstallment.Status__c = 'Em Aberto';
        lContractInstallment.AttemptedPayment__c = 0;
        lContractInstallment.RecordTypeId = PORTO_SAUDE_RECTYPE;
        insert lContractInstallment;

        lContractInstallment = [SELECT Id, ContractId__c, ContractId__r.Status,
            Credit__c, Discount__c, Status__c
            FROM ContractInstallment__c WHERE Id = :lContractInstallment.Id];
        
        System.assert(lContractInstallment.ContractId__c != null, 'Erro ao criar o contrato da parcela!');
        System.assert(lContractInstallment.ContractId__r.Status == 'Active', 'Erro ao ativar o contrato da parcela!');

        Test.startTest();            
            GenerateDiscountOrderPaymentSaude_bch lGenerateOrderPaymentSaude = new GenerateDiscountOrderPaymentSaude_bch(new Set<Id>{lAccount.Id}, true);
            Database.executeBatch(lGenerateOrderPaymentSaude);
        Test.stopTest();

        List<Order> lOrderLst = [SELECT TotalNetValue__c, (SELECT UnitPrice FROM DiscountOrderItems__r), (SELECT UnitPrice FROM CreditOrderItems__r) FROM Order WHERE AccountId = :lAccount.Id];
        System.assert(lOrderLst.size() > 0, 'Erro ao carregar ordem de pagamento!');
        System.assert(lOrderLst[0].CreditOrderItems__r.size() > 0, 'Erro ao gerar crédito na ordem de pagamento!');  
        System.assert(lOrderLst[0].DiscountOrderItems__r.size() > 0, 'Erro ao gerar desconto na ordem de pagamento!');  
        System.assert(lOrderLst[0].CreditOrderItems__r[0].UnitPrice == lContractInstallment.Credit__c, 'Erro ao gerar crédito na ordem de pagamento!');  
        System.assert(lOrderLst[0].DiscountOrderItems__r[0].UnitPrice == lContractInstallment.Discount__c, 'Erro ao gerar desconto na ordem de pagamento!');  

        lContractInstallment = [SELECT Status__c FROM ContractInstallment__c WHERE Id = :lContractInstallment.Id AND ReferenceDate__c = :System.today()];
        
        System.assert(lContractInstallment.Status__c == 'Liquidado', 'Erro ao liquidar a parcela!');    
    }
    
    @isTest
    static void GenerateOrderPaymentSaudeSecondDiscount(){               
        
        Map<String,String> lConfigurationValues = new Map<String,String>();
        for(PaymentServices__mdt lPaymentServicesConf :[SELECT DeveloperName, Value__c FROM PaymentServices__mdt 
            WHERE DeveloperName IN ('WorkOrderItemType','OrderItemDefaultQuantity','StatusNewPaymentOrder','StatusProcessedPaymentOrder','OrderItemTypeDiscount')]) {
            lConfigurationValues.put(lPaymentServicesConf.DeveloperName, lPaymentServicesConf.Value__c);
        }
    
        Account lAccount = [SELECT Code__c FROM Account LIMIT 1];

        ContractInstallment__c lContractInstallment = new ContractInstallment__c();
        lContractInstallment.ProviderCode__c = lAccount.Code__c;
        lContractInstallment.ReferenceDate__c = System.today();
        lContractInstallment.Credit__c = 500.0;
        lContractInstallment.Discount__c = 1000;
        lContractInstallment.Status__c = 'Em Aberto';
        lContractInstallment.AttemptedPayment__c = 1;
        lContractInstallment.RecordTypeId = PORTO_SAUDE_RECTYPE;
        insert lContractInstallment;

        lContractInstallment = [SELECT Id, ContractId__c, ContractId__r.Status,
            Credit__c, Discount__c, Status__c
            FROM ContractInstallment__c WHERE Id = :lContractInstallment.Id];
        
        System.assert(lContractInstallment.ContractId__c != null, 'Erro ao criar o contrato da parcela!');
        System.assert(lContractInstallment.ContractId__r.Status == 'Active', 'Erro ao ativar o contrato da parcela!');

        Test.startTest();            
            GenerateDiscountOrderPaymentSaude_bch lGenerateOrderPaymentSaude = new GenerateDiscountOrderPaymentSaude_bch(new Set<Id>{lAccount.Id},false);
            Database.executeBatch(lGenerateOrderPaymentSaude);
        Test.stopTest();

        List<Order> lOrderLst = [SELECT TotalNetValue__c, (SELECT UnitPrice FROM DiscountOrderItems__r), (SELECT UnitPrice FROM CreditOrderItems__r) FROM Order WHERE AccountId = :lAccount.Id];
        System.assert(lOrderLst.size() > 0, 'Erro ao carregar ordem de pagamento!');
        System.assert(lOrderLst[0].CreditOrderItems__r.size() > 0, 'Erro ao gerar crédito na ordem de pagamento!');  
        System.assert(lOrderLst[0].DiscountOrderItems__r.size() > 0, 'Erro ao gerar desconto na ordem de pagamento!');  
        System.assert(lOrderLst[0].CreditOrderItems__r[0].UnitPrice == lContractInstallment.Credit__c, 'Erro ao gerar crédito na ordem de pagamento!');  
        System.assert(lOrderLst[0].DiscountOrderItems__r[0].UnitPrice == lContractInstallment.Discount__c, 'Erro ao gerar desconto na ordem de pagamento!');  

        lContractInstallment = [SELECT Status__c FROM ContractInstallment__c WHERE Id = :lContractInstallment.Id AND ReferenceDate__c = :System.today()];
        
        System.assert(lContractInstallment.Status__c == 'Liquidado', 'Erro ao liquidar a parcela!');    
    }
}