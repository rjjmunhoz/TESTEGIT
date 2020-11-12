/**************************************************************************************************************
* Avanxo Brasil
* @author           Eduardo Costa (eborges@avanxo.com)
* Project:          Porto Socorro 
* Description:      Scheduler/Batch que consolida as ordens de serviço em ordens de pagamento
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-06-30      Eduardo Costa           class created 
**************************************************************************************************************/
global class GenerateOrderPayment_sch_bch implements Schedulable, Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {        

	/* GenerateOrderPayment_sch_bch lSb = new GenerateOrderPayment_sch_bch();
	String lSch = '0 0 0 * * ? * ';
    String jobID = system.schedule('Generate Order Payment', lSch, lSb);*/
    
    global Set<Id> fOrderIdCompletedSet;
    global Map<String,String> fConfigurationValues;
    global Map<Id,Boolean> fScheduleIsFirstFortnightMap;

    @InvocableMethod(label='Executar batch de geração de OP' description='Inicia processo de geração de Ordens de Pagamento.' category='PaymentOrder')
    global static List<String> startBatchOP(List<String> aOperations) {
		GenerateOrderPayment_sch_bch lGenerateOrderPaymentBatch = new GenerateOrderPayment_sch_bch();
        Database.executeBatch(lGenerateOrderPaymentBatch);
        return aOperations;
    }

	global void execute(SchedulableContext sc) {
		GenerateOrderPayment_sch_bch lGenerateOrderPaymentBatch = new GenerateOrderPayment_sch_bch();
		Database.executeBatch(lGenerateOrderPaymentBatch);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        fOrderIdCompletedSet = new Set<Id>();
        fConfigurationValues = new Map<String,String>();
        fScheduleIsFirstFortnightMap = new Map<Id,Boolean>();
        for(PaymentServices__mdt lPaymentServicesConf :[SELECT DeveloperName, Value__c FROM PaymentServices__mdt 
                WHERE DeveloperName IN ('StatusProcessedServiceOrder','StandardPriceBook','StatusNewPaymentOrder',
                'StatusReleasedForPaymentServiceOrder','StatusProcessedPaymentOrder','OrderItemDefaultQuantity', 'WorkOrderItemType')]) {
            fConfigurationValues.put(lPaymentServicesConf.DeveloperName, lPaymentServicesConf.Value__c);
        }

        // Get scheduler by pay day
        Set<String> lScheduleIdSet = new Set<String>();
        for(AggregateResult lSch : [SELECT Schedule__c FROM SchedulingDay__c WHERE PayDay__c = TODAY GROUP BY Schedule__c]) {
            lScheduleIdSet.add((Id)lSch.get('Schedule__c'));
        }  
        
        Integer lNumberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
        Date lLastDayOfMonth = Date.newInstance(system.today().year(), system.today().month(), lNumberOfDays);
        Date lFirstDayOfMonth = Date.newInstance(system.today().year(), system.today().month(), 1);

        // Pesquisa as datas de pagamento dos cronogramas do dia, ordenando a data de mais antiga para mais atual, se a primeira ocorrência for menor do que a data atual quer dizer que a primeira quinzana 
        // já foi processada
        for(SchedulingDay__c lSchedulingDay :[SELECT Schedule__c, PayDay__c FROM SchedulingDay__c WHERE Schedule__c IN :lScheduleIdSet AND PayDay__c >= :lFirstDayOfMonth AND PayDay__c <= :lLastDayOfMonth ORDER BY PayDay__c ASC]) {
            Boolean lFortnight = fScheduleIsFirstFortnightMap.get(lSchedulingDay.Schedule__c);
            if(lFortnight == null) {
                // Se a primeira data do pagamento deste cronograma for menor que a data atual quer dizer que já foi processada a primeira quinzena
                if(lSchedulingDay.PayDay__c < system.today()) {
                    fScheduleIsFirstFortnightMap.put(lSchedulingDay.Schedule__c, false);
                }
                else {
                    fScheduleIsFirstFortnightMap.put(lSchedulingDay.Schedule__c, true);
                }
            }
        }

        // Retrieve the service orders ordered by CNPJ, Company and Tax Code. 
        return Database.getQueryLocator([SELECT Id, AccountId, Account.CNPJ__c, Company__c, Specialty__c, Specialty__r.TaxCode__c,
                                        ServiceOrderNumber__c, Vehicle__c, ActualAmountToBePaid__c, ContactId 
                                        FROM WorkOrder 
                                        WHERE Account.ScheduleLink__c IN :lScheduleIdSet 
                                        AND Status = :fConfigurationValues.get('StatusReleasedForPaymentServiceOrder')
                                        ORDER BY AccountId, Company__c, Specialty__r.TaxCode__c]);
	}

    global void execute(Database.BatchableContext BC, List<WorkOrder> aWorkOrderLst) { 
        
        String lStatusProcessedServiceOrder = fConfigurationValues.get('StatusProcessedServiceOrder');
        
        Set<Id> lAccountIdSet = new Set<Id>();
        Set<Id> lSpecialtyIdSet = new Set<Id>();
        Set<String> lOrdersKeySet = new Set<String>();
        for(WorkOrder lWorkOrder :aWorkOrderLst){
            lAccountIdSet.add(lWorkOrder.AccountId);
            lSpecialtyIdSet.add(lWorkOrder.Specialty__c);
            lWorkOrder.Status = lStatusProcessedServiceOrder;
            lOrdersKeySet.add(lWorkOrder.Account.CNPJ__c + lWorkOrder.Company__c + lWorkOrder.Specialty__r.TaxCode__c);
        }

        Map<Id,Account> lAccountMap = new Map<Id,Account>([
            SELECT Code__c, SucursalCode__c, BankAccountType__c, Branch__c, DigitAgency__c, BankName__c, 
            CheckingAccount__c, CurrentAccountDigit__c, ISSTaxRate__c, CompanyName__c 
            FROM Account WHERE Id IN :lAccountIdSet]);

        // Get configuration values for process
        String lStatusNewPaymentOrder = fConfigurationValues.get('StatusNewPaymentOrder');
        
        Map<String,Order> lOrdersMap = new Map<String,Order>();
        for(Order lOrder :[SELECT Status, Pricebook2Id, AccountId, CPFCNPJ__c, Code__c, OrderTaxCode__c, 
                Company__c, SucursalCode__c, Favored__c, FavoredCpfCnpj__c, BankAccountType__c, 
                Agency__c, DigitAgency__c, BankName__c, BankAccountNumber__c, DigitBankAccountNumber__c, 
                Aliquot__c, EffectiveDate, OrderKey__c 
                FROM ORDER
                WHERE Status = :lStatusNewPaymentOrder
                AND OrderKey__c IN :lOrdersKeySet]) {
            lOrdersMap.put(lOrder.OrderKey__c,lOrder);
        }        

        // Retrieve standard pricebook to service order
        Id lStandardPriceBookId;
        if(!Test.isRunningTest()) {
            lStandardPriceBookId = [SELECT Id FROM Pricebook2 WHERE Name = :fConfigurationValues.get('StandardPriceBook')].Id;   
        }
        else {
            lStandardPriceBookId = Test.getStandardPricebookId();
        }
          
        Map<String,Order> lOrderToCreateMap = new Map<String,Order>();   
        for(WorkOrder lWorkOrder :aWorkOrderLst){
            String lOrderKey = lWorkOrder.Account.CNPJ__c + lWorkOrder.Company__c + lWorkOrder.Specialty__r.TaxCode__c;
            if(!lOrdersMap.containsKey(lOrderKey)) {     
                lOrderToCreateMap.put(
                    lOrderKey,
                    createPaymentOrder(lWorkOrder, lAccountMap.get(lWorkOrder.AccountId), lStatusNewPaymentOrder, lStandardPriceBookId)
                );
            }
        }     

        if(!lOrderToCreateMap.isEmpty()) {
            insert lOrderToCreateMap.values();
            lOrdersMap.putAll(lOrderToCreateMap);
        }   
        
        Map<Id,Id> lPriceBookEntryMap = new Map<Id,Id>();        
        for(PricebookEntry lPbEntry :[SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :lStandardPriceBookId AND Product2Id IN :lSpecialtyIdSet]) {
            lPriceBookEntryMap.put(lPbEntry.Product2Id, lPbEntry.Id);
        }
        
        String lOrderItemDefaultQuantity = fConfigurationValues.get('OrderItemDefaultQuantity');
        List<OrderItem> lOrderItemToCreateLst = new List<OrderItem>();
        for(WorkOrder lWorkOrder :aWorkOrderLst){
            String lOrderKey = lWorkOrder.Account.CNPJ__c + lWorkOrder.Company__c + lWorkOrder.Specialty__r.TaxCode__c;
            Order lOrder = lOrdersMap.get(lOrderKey);
            lWorkOrder.PaymentOrder__c = lOrder.Id;
            lOrderItemToCreateLst.add(
                new OrderItem(
                    OrderId = lOrder.Id,
                    ItemType__c = fConfigurationValues.get('WorkOrderItemType'),
                    ServicePaymentOrder__c = lOrder.Id,
                    ServiceOrder__c = lWorkOrder.Id,
                    RescuerId__c = lWorkOrder.ContactId,
                    Vehicle__c = lWorkOrder.Vehicle__c,
                    NetValue__c = lWorkOrder.ActualAmountToBePaid__c,
                    PricebookEntryId = lPriceBookEntryMap.get(lWorkOrder.Specialty__c),
                    Quantity = Integer.valueOf(lOrderItemDefaultQuantity),
                    UnitPrice = lWorkOrder.ActualAmountToBePaid__c
                )
            ); 
            fOrderIdCompletedSet.add(lOrder.Id);           
        }	
        
        if(!lOrderItemToCreateLst.isEmpty()) insert lOrderItemToCreateLst;

        update aWorkOrderLst;
    }
    
    global static Order createPaymentOrder(WorkOrder aWorkOrder, Account aAccount, String aStatus, String aPriceBookId) {
        return new Order(    
            Status = aStatus,
            Pricebook2Id = aPriceBookId,
            AccountId = aWorkOrder.AccountId,
            CPFCNPJ__c = aWorkOrder.Account.CNPJ__c,
            Code__c = (aAccount.Code__c!=null)?String.valueOf(aAccount.Code__c):null,
            OrderTaxCode__c = aWorkOrder.Specialty__r.TaxCode__c,
            Company__c = aWorkOrder.Company__c,
            SucursalCode__c = aAccount.SucursalCode__c,
            Favored__c = aAccount.CompanyName__c,
            FavoredCpfCnpj__c = aWorkOrder.Account.CNPJ__c,
            BankAccountType__c = aAccount.BankAccountType__c,
            Agency__c = aAccount.Branch__c,
            DigitAgency__c = aAccount.DigitAgency__c,
            BankName__c = aAccount.BankName__c,
            BankAccountNumber__c = aAccount.CheckingAccount__c,
            DigitBankAccountNumber__c = aAccount.CurrentAccountDigit__c,
            Aliquot__c = aAccount.ISSTaxRate__c,
            EffectiveDate = Date.today()
        );
    }
	
	global void finish(Database.BatchableContext BC) {

        if(fOrderIdCompletedSet.isEmpty()) return;

        String lStatusProcessedPaymentOrder = fConfigurationValues.get('StatusProcessedPaymentOrder');   
        List<Order> lOrderToUpdate = new List<Order>(); 
        for(Id lOrderId :fOrderIdCompletedSet) {
            lOrderToUpdate.add(
                new Order(
                    Id = lOrderId,
                    Status = lStatusProcessedPaymentOrder
                )
            );
        }
        update lOrderToUpdate;        

        Set<Id> lAccountIdSet = new Set<Id>();
        for(Aggregateresult lAr :[SELECT AccountId FROM Order WHERE Id IN :fOrderIdCompletedSet GROUP BY AccountId]) {
            lAccountIdSet.add((Id)lAr.get('AccountId'));
        }

        Set<Id> lFirstFortnightAccountIdSet = new Set<Id>();
        Set<Id> lSecondFortnightAccountIdSet = new Set<Id>();
        for(Account lAcc :[SELECT Id, ScheduleLink__c FROM Account WHERE Id IN :lAccountIdSet]) {
            if(fScheduleIsFirstFortnightMap.get(lAcc.ScheduleLink__c)) {
                lFirstFortnightAccountIdSet.add(lAcc.Id);
            }
            else {
                lSecondFortnightAccountIdSet.add(lAcc.Id);
            }
        }
        
        // Chama os batchs de desconto somente se não estiver executando no contexto de teste
        if(!Test.isRunningTest()) {    
            if(!lFirstFortnightAccountIdSet.isEmpty()) {
                // Caso seja a primeira quinzena chama o processo de desconto da PortoSeg
                GenerateDiscountOrderPaymentPortoSeg_bch lGenerateDiscountOrderPaymentBatch = new GenerateDiscountOrderPaymentPortoSeg_bch(lFirstFortnightAccountIdSet,true);
                Database.executeBatch(lGenerateDiscountOrderPaymentBatch); 
            }            
            
            if(!lSecondFortnightAccountIdSet.isEmpty()) {
                // Caso seja a segunda quinzena, chama o desconto Porto Saúde passando que é a o primeiro desconto após geração das OPs
                // para descontar prioritariamente a primeira parcela do PortoSaúde
                GenerateDiscountOrderPaymentSaude_bch lGenerateDiscountOrderPaymentSaude = new GenerateDiscountOrderPaymentSaude_bch(lSecondFortnightAccountIdSet,true);
                Database.executeBatch(lGenerateDiscountOrderPaymentSaude);
            }               
        }
    }
}