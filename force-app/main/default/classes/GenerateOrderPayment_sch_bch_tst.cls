@isTest
public with sharing class GenerateOrderPayment_sch_bch_tst {

    private static final String PORTOSEG_RECTYPE = SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PortoSeg').getRecordTypeId();

    @TestSetup
    static void makeData(){
        Account lAccount = AccountFactory.createAccountProvider();

        Schedule__c lSchedule = new Schedule__c();
        lSchedule.Frequency__c = '10 dias';
        lSchedule.Name = 'Schedule Test';
        insert lSchedule;

        SchedulingDay__c lScheduleDay = new SchedulingDay__c();
        lScheduleDay.PayDay__c = System.today();
        lScheduleDay.Schedule__c = lSchedule.Id;
        insert lScheduleDay;

        lAccount.ScheduleLink__c = lSchedule.Id;
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
        
        Map<String,String> lConfigurationValues = new Map<String,String>();
        for(PaymentServices__mdt lPaymentServicesConf :[SELECT DeveloperName, Value__c FROM PaymentServices__mdt 
                WHERE DeveloperName IN ('StatusReleasedForPaymentServiceOrder')]) {
            lConfigurationValues.put(lPaymentServicesConf.DeveloperName, lPaymentServicesConf.Value__c);
        }

        WorkOrder lWorkOrder = new WorkOrder();
        lWorkOrder.Status = 'Analisado e Liberado para Pagamento';
        lWorkOrder.AccountId = lAccount.Id;
        lWorkOrder.Specialty__c = lService.Id;
        lWorkOrder.ActualAmountToBePaid__c = 1000.0;
        lWorkOrder.Company__c = '1';
        insert lWorkOrder; 
    }

    @isTest 
    static void GenerateOrderPayment(){     
        
        Account lAccount = [SELECT Id FROM Account LIMIT 1];   
        List<WorkOrder> lWorkOrderLst = [SELECT Id, ActualAmountToBePaid__c FROM WorkOrder WHERE AccountId = :lAccount.Id];     
        System.assert(lWorkOrderLst.size() > 0, 'Erro ao localizar ordem de serviço!');  

        Test.startTest();            
            GenerateOrderPayment_sch_bch lGenerateOrderPaymentBatch = new GenerateOrderPayment_sch_bch();
            Database.executeBatch(lGenerateOrderPaymentBatch);
        Test.stopTest();

        List<Order> lOrderLst = [SELECT TotalNetValue__c, (SELECT ServiceOrder__c FROM OrderItems WHERE ItemType__c = 'Ordem de Serviço') FROM Order WHERE AccountId = :lAccount.Id];
        System.assert(lOrderLst.size() > 0, 'Erro ao gerar ordem de pagamento!');
        System.assert(lOrderLst[0].OrderItems.size() > 0, 'Erro ao gerar itens da ordem de pagamento!');        
        System.assert(lOrderLst[0].TotalNetValue__c == lWorkOrderLst[0].ActualAmountToBePaid__c, 'Valor da ordem de pagamento não condiz com a ordem de serviço!');
        System.assert(lOrderLst[0].OrderItems[0].ServiceOrder__c == lWorkOrderLst[0].Id, 'Ordem de serviço não confere com o item da ordem de pagamento!');
    }
}