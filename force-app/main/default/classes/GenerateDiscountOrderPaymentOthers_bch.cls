/**************************************************************************************************************
* Globant Brasil
* @author           Bruno Di Giacomo (bruno.digiacomo@globant.com)
* Project:          Porto Socorro 
* Description:      Scheduler/Batch que atribui os demais descontos dos contratos nas Ordens de Pagamento
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                          Description     
*           -----   ----------      --------------------            ---------------   
* @version   1.0    2020-08-05      Eduardo Costa/Bruno Di Giacomo    class created 
**************************************************************************************************************/
global class GenerateDiscountOrderPaymentOthers_bch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global Set<Id> fAccountIdSet;
    global Map<String,String> fConfigurationValues;

    global GenerateDiscountOrderPaymentOthers_bch(Set<Id> aAccountIdSet) {
        this.fAccountIdSet = aAccountIdSet;
    }

    global GenerateDiscountOrderPaymentOthers_bch() {
    }

    /*
    Método responsavel por montar o Map com os medatados personalizados utilizados no processdo de dessconto e
    retornar com todas as parcelas elegiveis para desconto 
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {   
        fConfigurationValues = new Map<String,String>();
        for(PaymentServices__mdt lPaymentServicesConf :[SELECT DeveloperName, Value__c FROM PaymentServices__mdt 
                WHERE DeveloperName IN ('MaxDiscountPercent','StandardPriceBook','StatusProcessedPaymentOrder',
                'OrderItemDefaultQuantity','OrderItemTypeDiscount','DiscountCompaniesOP','StatusActiveContract',
                'StatusFinishedContract','RecordTypeDevNameOthersDiscountsContract')]) {
            fConfigurationValues.put(lPaymentServicesConf.DeveloperName, lPaymentServicesConf.Value__c);
        }

        Integer lNumberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
        Date lLastDayOfMonth = Date.newInstance(system.today().year(), system.today().month(), lNumberOfDays);
        
        system.debug('###OthersfAccountIdSet ' + fAccountIdSet);

        // Retrieve the Contract Installment from contract
        return Database.getQueryLocator([SELECT Id, ParcelNumber__c, InstallmentValueN__c, AmountPaid__c, ContractId__r.AccountId, 
                                        ContractId__r.DiscountType__r.Name/* RecordType.Name */,ContractId__r.DiscountType__r.Priority__c, AttemptedPayment__c, Debt__c 
                                        FROM ContractInstallment__c
                                        WHERE Status__c IN (:Label.ContractInstallmentStatusOpened,:Label.ContractInstallmentStatusOverdue)
                                        AND ReferenceDate__c <= :lLastDayOfMonth
                                        AND ContractId__r.StartDate <= TODAY 
                                        // AND ContractId__r.EndDate >= TODAY
                                        AND ContractId__r.Status = :fConfigurationValues.get('StatusActiveContract') 
                                        AND ContractId__r.RecordType.DeveloperName = :fConfigurationValues.get('RecordTypeDevNameOthersDiscountsContract') 
                                        AND ContractId__r.AccountId IN :fAccountIdSet
                                        ORDER BY CompareMonth__c, ContractId__r.DiscountType__r.Priority__c, InstallmentValueN__c ASC]);
    }


global void execute(Database.BatchableContext BC, List<ContractInstallment__c> aContractInstallmentLst) { 
    
    system.debug('###aOthersContractInstallmentLst ' + aContractInstallmentLst);
    // Map para agrupar as parcelas do Cliente 
    Map<Id,List<ContractInstallmentWrapper>> lAccountContractInstallmentMap = new Map<Id,List<ContractInstallmentWrapper>>();
    for(ContractInstallment__c lContractInstallment :aContractInstallmentLst) {
        List<ContractInstallmentWrapper> lCtInstallmentWr = lAccountContractInstallmentMap.get(lContractInstallment.ContractId__r.AccountId);
        if(lCtInstallmentWr == null) {
            lCtInstallmentWr = new List<ContractInstallmentWrapper>();
            lAccountContractInstallmentMap.put(lContractInstallment.ContractId__r.AccountId,lCtInstallmentWr);
        }
        lCtInstallmentWr.add(new ContractInstallmentWrapper(lContractInstallment));
    }

    PricebookEntry lPbEntry;
    if(!Test.isRunningTest()) {
        lPbEntry = [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = :fConfigurationValues.get('StandardPriceBook') LIMIT 1];  
    }
    else {
        lPbEntry = [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :Test.getStandardPricebookId()];
    }
   
    Decimal lMaxDiscountPercent = Decimal.valueOf(fConfigurationValues.get('MaxDiscountPercent'));

        String lOrderItemTypeDiscount = fConfigurationValues.get('OrderItemTypeDiscount');
        Integer lOrderItemDefaultQuantity = Integer.valueOf(fConfigurationValues.get('OrderItemDefaultQuantity'));
        Map<String,OrderItem> lOrderItemToUpsert = new Map<String,OrderItem>();
        Map<Id,Decimal> lContractInstallmentAttemptedPaymentUpdate = new Map<Id,Decimal>();
        Map<String,OrderItemDiscountWrapper> lOrderItemDiscountToCreateMap = new Map<String,OrderItemDiscountWrapper>();        
        for(Order lOrder :[SELECT Id, TotalAmountService__c, TotalAmountDiscounts__c, AccountId, 
                TotalNetValue__c, TotalAmountCredits__c,  
                (SELECT UnitPrice, CompanyDiscount__c, OrderId FROM OrderItems WHERE ItemType__c = :lOrderItemTypeDiscount)
                FROM Order 
                WHERE Company__c IN :fConfigurationValues.get('DiscountCompaniesOP').split(',') // Empresas Porto
                AND AccountId IN :lAccountContractInstallmentMap.keySet() AND Status = :fConfigurationValues.get('StatusProcessedPaymentOrder')
                ORDER BY TotalNetValue__c DESC]) {

            List<ContractInstallmentWrapper> lContractInstallmentWr = lAccountContractInstallmentMap.get(lOrder.AccountId);
            if(lContractInstallmentWr == null) continue;

            Decimal lTotalAmount = lOrder.TotalAmountService__c + lOrder.TotalAmountCredits__c;            
            Decimal lMaxValueToDiscount = ((((lTotalAmount*lMaxDiscountPercent)/100) - lOrder.TotalAmountDiscounts__c) > 0)? ((lTotalAmount*lMaxDiscountPercent)/100) - lOrder.TotalAmountDiscounts__c : 0;
            
            if(lOrder.OrderItems.size() > 0) {
                for(OrderItem lOrderItem :lOrder.OrderItems) {
                    lOrderItemDiscountToCreateMap.put(lOrderItem.OrderId + lOrderItem.CompanyDiscount__c, new OrderItemDiscountWrapper(lOrderItem));
                }
            }
                
            for(ContractInstallmentWrapper lCtInstallmentWr :lContractInstallmentWr) {
                // Se não possui mais debito na parcela pula para próxima
                if(lCtInstallmentWr.debt == 0) continue;

                // Incrementa a tentativa de pagamento da parcela na quinzena                
                if(!lContractInstallmentAttemptedPaymentUpdate.containsKey(lCtInstallmentWr.contractInstallment.Id)) {
                    lContractInstallmentAttemptedPaymentUpdate.put(lCtInstallmentWr.contractInstallment.Id,lCtInstallmentWr.contractInstallment.AttemptedPayment__c+1);
                }                      

                Decimal lValueToDiscount = 0;
                if(lCtInstallmentWr.debt > lMaxValueToDiscount) {
                    lValueToDiscount = lMaxValueToDiscount;
                }
                else {
                    lValueToDiscount = lCtInstallmentWr.debt;
                }

                if(lValueToDiscount == 0) continue;

                //Subtrai do disponivel da OP o que já foi alocado para essa parcela
                lMaxValueToDiscount -= lValueToDiscount;

                String lOrderItemDiscountWrKey = lOrder.Id + lCtInstallmentWr.contractInstallment.ContractId__r.DiscountType__r.Name/* RecordType.Name */;
                OrderItemDiscountWrapper lOrderItemDiscounts = lOrderItemDiscountToCreateMap.get(lOrderItemDiscountWrKey);
                if(lOrderItemDiscounts == null) {
                    lOrderItemDiscounts = new OrderItemDiscountWrapper(
                        new OrderItem(
                            OrderId = lOrder.Id,
                            ItemType__c = lOrderItemTypeDiscount,
                            CompanyDiscount__c = lCtInstallmentWr.contractInstallment.ContractId__r.DiscountType__r.Name/* RecordType.Name */,
                            DiscountOrder__c = lOrder.Id,
                            PricebookEntryId = lPbEntry.Id,
                            Quantity = lOrderItemDefaultQuantity,
                            UnitPrice = 0
                        )
                    );
                    lOrderItemDiscountToCreateMap.put(lOrderItemDiscountWrKey, lOrderItemDiscounts);
                }
                // Somente para teste, o roll-up será feito na trigger de desconto
                lOrderItemDiscounts.orderItem.UnitPrice += lValueToDiscount;
                // Contabiliza o valor pago na parcela para não  debitar novamente
                lCtInstallmentWr.amountPaid += lValueToDiscount;

                lOrderItemDiscounts.discountLst.add(
                    new Discount__c(
                        ContractInstallment__c = lCtInstallmentWr.contractInstallment.Id, 
                        ParcelNumber__c = lCtInstallmentWr.contractInstallment.ParcelNumber__c, 
                        Amount__c = lValueToDiscount
                    )
                );
                lOrderItemToUpsert.put(lOrderItemDiscountWrKey, lOrderItemDiscounts.orderItem);
            }
        } 
        
        // Caso não tenha descontos para serem criados, apenas atualiza a quantidade de tentativa na parcela
        List<ContractInstallment__c> lContractInstallmentToUpdateLst = new List<ContractInstallment__c>();
        if(lOrderItemDiscountToCreateMap.isEmpty()) {
            for(ContractInstallment__c lContractInstallment :aContractInstallmentLst) {
                lContractInstallment.AttemptedPayment__c = lContractInstallmentAttemptedPaymentUpdate.get(lContractInstallment.Id);  
                lContractInstallmentToUpdateLst.add(lContractInstallment);
            }

            update lContractInstallmentToUpdateLst;
        }
        else {
            upsert lOrderItemToUpsert.values();        

            List<Discount__c> lDiscountTocreate = new List<Discount__c>();
            for(String lOrderItemDiscountWrKey :lOrderItemDiscountToCreateMap.keySet()) {
                OrderItemDiscountWrapper lOrderItemDiscounts = lOrderItemDiscountToCreateMap.get(lOrderItemDiscountWrKey);
                for(Discount__c lDiscount :lOrderItemDiscounts.discountLst) {
                    lDiscount.OrderItemId__c = lOrderItemDiscounts.OrderItem.Id;
                    lDiscountTocreate.add(lDiscount);
                }
            }

            upsert lDiscountTocreate;

            String lStatusFinishedContract = fConfigurationValues.get('StatusFinishedContract');
            for(ContractInstallment__c lContractInstallment :[SELECT Debt__c, ReferenceDate__c 
                    FROM ContractInstallment__c WHERE Id IN :lContractInstallmentAttemptedPaymentUpdate.keySet()]) {
                if(lContractInstallment.Debt__c == 0) {
                    lContractInstallment.Status__c = lStatusFinishedContract;
                }
                else {
                    // Verificar aqui se está atrasado
                } 
                lContractInstallment.AttemptedPayment__c = lContractInstallmentAttemptedPaymentUpdate.get(lContractInstallment.Id);  
                lContractInstallmentToUpdateLst.add(lContractInstallment);
            }
            
            update lContractInstallmentToUpdateLst;
        }
}

global class OrderItemDiscountWrapper {
    global OrderItem orderItem;
    global List<Discount__c> discountLst;
    global OrderItemDiscountWrapper(OrderItem aOrderItem) {
        this.orderItem = aOrderItem;
        this.discountLst = new List<Discount__c>();
    }
}

global class ContractInstallmentWrapper {
    global Decimal amountPaid;
    global Decimal debt {
        get {
            Decimal lInstallmentValue = contractInstallment.InstallmentValueN__c!=null?contractInstallment.InstallmentValueN__c:0;
            return lInstallmentValue - amountPaid;
        }set;
    }
    global ContractInstallment__c contractInstallment;
    global ContractInstallmentWrapper(ContractInstallment__c aContractInstallment) {
        this.contractInstallment = aContractInstallment;
        this.amountPaid = aContractInstallment.AmountPaid__c!=null?aContractInstallment.AmountPaid__c:0;
    }
}
    
    global void finish(Database.BatchableContext bc){
        
    }

    
}