@isTest
public with sharing class GenerateDiscountOrderPaymentPortoSeg_tst {

    private static final String PORTOSEG_RECTYPE = SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PortoSeg').getRecordTypeId();

    @TestSetup
    static void makeData(){
        
        Map<String,String> lConfigurationValues = new Map<String,String>();
        for(PaymentServices__mdt lPaymentServicesConf :[SELECT DeveloperName, Value__c FROM PaymentServices__mdt 
                WHERE DeveloperName IN ('WorkOrderItemType','OrderItemDefaultQuantity','StatusNewPaymentOrder','StatusProcessedPaymentOrder','OrderItemTypeDiscount')]) {
            lConfigurationValues.put(lPaymentServicesConf.DeveloperName, lPaymentServicesConf.Value__c);
        }

        Account lAccount = AccountFactory.createAccountProvider();
        insert lAccount;
        
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
    static void GenerateDiscountOrderPaymentPortoSeg_bch(){   
          
        Map<String,String> lConfigurationValues = new Map<String,String>();
        for(PaymentServices__mdt lPaymentServicesConf :[SELECT DeveloperName, Value__c FROM PaymentServices__mdt 
                WHERE DeveloperName IN ('WorkOrderItemType','OrderItemDefaultQuantity','StatusNewPaymentOrder','StatusProcessedPaymentOrder','OrderItemTypeDiscount')]) {
            lConfigurationValues.put(lPaymentServicesConf.DeveloperName, lPaymentServicesConf.Value__c);
        }
        
        Account lAccount = [SELECT Id FROM Account LIMIT 1];

        Contract lContract = new Contract();
        lContract.AccountId = lAccount.Id;
        lContract.Novate__c = 'Não';
        lContract.InstallmentValue__c = 500.0;
        lContract.ContractTerm = 1;
        lContract.StartDate = System.today();
        lContract.RecordTypeId = PORTOSEG_RECTYPE;
        insert lContract;

        ContractInstallment__c lContractInstallment = [SELECT Id, Status__c, InstallmentValueN__c, 
            ReferenceMonth__c, ContractInstallmentValue__c, Interest__c, AmountPaid__c, Debt__c 
            FROM ContractInstallment__c WHERE ContractId__c = :lContract.Id AND ReferenceDate__c = :System.today()];
        
        System.assert(lContractInstallment.InstallmentValueN__c == lContract.InstallmentValue__c, 'Erro ao atribuir o valor na parcela!');
        System.assert(lContractInstallment.AmountPaid__c == 0, 'Erro ao atribuir o valor pago na parcela!');
        System.assert(lContractInstallment.InstallmentValueN__c == lContractInstallment.Debt__c, 'Divergência do debito com o valor da parcela!');

        lContract.Status = 'Active';
        update lContract;    

        Test.startTest();            
            GenerateDiscountOrderPaymentPortoSeg_bch lGenerateOrderPaymentPortoSegBatch = new GenerateDiscountOrderPaymentPortoSeg_bch(new Set<Id>{lAccount.Id});
            Database.executeBatch(lGenerateOrderPaymentPortoSegBatch);
        Test.stopTest();

        List<Order> lOrderLst = [SELECT TotalNetValue__c, (SELECT ServiceOrder__c FROM OrderItems WHERE ItemType__c = :lConfigurationValues.get('OrderItemTypeDiscount')) FROM Order WHERE AccountId = :lAccount.Id];
        System.assert(lOrderLst.size() > 0, 'Erro ao carregar ordem de pagamento!');
        System.assert(lOrderLst[0].OrderItems.size() > 0, 'Erro ao gerar desconto na ordem de pagamento!');  

        lContractInstallment = [SELECT Debt__c FROM ContractInstallment__c WHERE ContractId__c = :lContract.Id AND ReferenceDate__c = :System.today()];
        
        System.assert(lContractInstallment.Debt__c == 0, 'Erro ao atribuir desconto na parcela!');  
    }
}