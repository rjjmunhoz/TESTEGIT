/**************************************************************************************************************
* Avanxo Brasil
* @author           Eduardo Costa (eborges@avanxo.com)
* Project:          Porto Socorro 
* Description:      Scheduler/Batch que atribui os descontos dos contratos Porto Saúde nas Ordens de Pagamento
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                          Description     
*           -----   ----------      --------------------            ---------------   
* @version   1.0    2020-08-04      Eduardo Costa                   class created 
**************************************************************************************************************/
global class GenerateDiscountOrderPaymentSaude_bch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global Set<Id> fAccountIdSet;
    global Boolean fFirstDiscount;
    global Map<String,String> fConfigurationValues;

    /*
    Pega a lista de contas que possuem OP para Abate e seta se é para descontar da Porto Saúde na primeira ou segunda quinzena
    */
    global GenerateDiscountOrderPaymentSaude_bch(Set<Id> aAccountIdSet, Boolean aFirstDiscount) {
        this.fAccountIdSet = aAccountIdSet;
        this.fFirstDiscount = aFirstDiscount;
    }

    global GenerateDiscountOrderPaymentSaude_bch() {}

    /*
    Método responsavel por montar o Map com os medatados personalizados utilizados no processdo de dessconto e
    retornar com todas as parcelas elegiveis para desconto 
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {   
        fConfigurationValues = new Map<String,String>();
        for(PaymentServices__mdt lPaymentServicesConf :[SELECT DeveloperName, Value__c FROM PaymentServices__mdt 
                WHERE DeveloperName IN ('MaxDiscountPercent','StandardPriceBook','StatusProcessedPaymentOrder',
                'OrderItemDefaultQuantity','OrderItemTypeDiscount','DiscountCompaniesOP',
                'StatusActiveContract','StatusFinishedContract','OrderItemTypeCredit',
                'RecordTypeDevNamePortoHealthContract')]) {
            fConfigurationValues.put(lPaymentServicesConf.DeveloperName, lPaymentServicesConf.Value__c);
        }

        Integer lNumberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
        Date lLastDayOfMonth = Date.newInstance(system.today().year(), system.today().month(), lNumberOfDays);

        String lStatusActiveContract = fConfigurationValues.get('StatusActiveContract');
        String lRecordTypeDevNamePortoHealthContract = fConfigurationValues.get('RecordTypeDevNamePortoHealthContract');
        String lContractInstallmentStatusOpened = Label.ContractInstallmentStatusOpened;
        String lContractInstallmentStatusOverdue = Label.ContractInstallmentStatusOverdue;

        // Realiza o desconto na segunta quinzena da primeira parcela da Porto Saúde
        // este desconto acontece antes da chamada de desconto da PortoSeg, após o processo
        // de desconto da PortoSeg este batch é chamado novamente para pegar as parcelas em atrazo

        // Retrieve the Contract Installment from contract
        String lQuery = 'SELECT Id, ParcelNumber__c, Discount__c, AmountPaid__c, ContractId__r.AccountId, '
                + 'ContractId__r.RecordType.Name, AttemptedPayment__c, Credit__c '
                + 'FROM ContractInstallment__c '
                + 'WHERE Status__c IN (:lContractInstallmentStatusOpened,:lContractInstallmentStatusOverdue) '
                + 'AND ReferenceDate__c <= :lLastDayOfMonth '
                + 'AND ContractId__r.StartDate <= TODAY ';
                // + 'AND ContractId__r.EndDate >= TODAY '
        if(this.fFirstDiscount) {
            lQuery += 'AND AttemptedPayment__c = 0 ';
        }
        else {
            lQuery += 'AND AttemptedPayment__c >= 1 ';
        }
                
        lQuery += 'AND ContractId__r.Status = :lStatusActiveContract '
                + 'AND ContractId__r.RecordType.DeveloperName = :lRecordTypeDevNamePortoHealthContract '
                + 'AND ContractId__r.AccountId IN :fAccountIdSet '
                + 'ORDER BY ReferenceDate__c, Discount__c ASC ';
        return Database.getQueryLocator(lQuery);

        
	}

    global void execute(Database.BatchableContext BC, List<ContractInstallment__c> aContractInstallmentLst) { 

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
        // Map para indicar o maximo possivel para desconto das OP disponiveis
        Map<Id,Decimal> lTotalMaxValueToDiscountOrdersMap = new Map<Id,Decimal>();
        for(AggregateResult lAr :[SELECT AccountId, SUM(TotalAmountService__c) totalAmountService, SUM(TotalAmountDiscounts__c) totalAmountDiscounts FROM Order 
                WHERE Company__c IN :fConfigurationValues.get('DiscountCompaniesOP').split(',') // Empresas Porto
                AND AccountId IN :lAccountContractInstallmentMap.keySet() AND Status = :fConfigurationValues.get('StatusProcessedPaymentOrder')
                GROUP BY AccountId]) {
            Decimal lTotalAmountService = (Decimal)lAr.get('totalAmountService');
            Decimal lTotalAmountDiscounts = (Decimal)lAr.get('totalAmountDiscounts');
            Decimal lTotalMaxValueToDiscountOrder = ((((lTotalAmountService*lMaxDiscountPercent)/100) - lTotalAmountDiscounts) > 0)? ((lTotalAmountService*lMaxDiscountPercent)/100) - lTotalAmountDiscounts : 0;
            lTotalMaxValueToDiscountOrdersMap.put((Id)lAr.get('AccountId'),lTotalMaxValueToDiscountOrder);
        }

        String lOrderItemTypeCredit = fConfigurationValues.get('OrderItemTypeCredit');
        String lOrderItemTypeDiscount = fConfigurationValues.get('OrderItemTypeDiscount');
        Integer lOrderItemDefaultQuantity = Integer.valueOf(fConfigurationValues.get('OrderItemDefaultQuantity'));
        Map<Id,Decimal> lContractInstallmentAttemptedPaymentUpdate = new Map<Id,Decimal>();
        Map<String,OrderItemDiscountCreditWrapper> lOrderItemDiscountCreditToCreateMap = new Map<String,OrderItemDiscountCreditWrapper>();        
        for(Order lOrder :[SELECT Id, TotalAmountService__c, TotalAmountDiscounts__c, AccountId, 
                TotalNetValue__c, TotalAmountCredits__c, 
                (SELECT UnitPrice, CompanyDiscount__c, OrderId, ItemType__c FROM OrderItems WHERE ItemType__c = :lOrderItemTypeDiscount)
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
                    OrderItemDiscountCreditWrapper lOrderItemDiscountCreditWrapper = lOrderItemDiscountCreditToCreateMap.get(lOrderItem.OrderId + lOrderItem.CompanyDiscount__c);
                    if(lOrderItemDiscountCreditWrapper == null) {
                        lOrderItemDiscountCreditWrapper = new OrderItemDiscountCreditWrapper();
                        lOrderItemDiscountCreditToCreateMap.put(lOrderItem.OrderId + lOrderItem.CompanyDiscount__c, lOrderItemDiscountCreditWrapper);
                    }
                    if(lOrderItem.ItemType__c == lOrderItemTypeCredit) {
                        lOrderItemDiscountCreditWrapper.orderItemCredit = lOrderItem;
                    }
                    else if(lOrderItem.ItemType__c == lOrderItemTypeDiscount) {
                        lOrderItemDiscountCreditWrapper.orderItemDiscount = lOrderItem;
                    }
                    
                }
            }
                
            for(ContractInstallmentWrapper lCtInstallmentWr :lContractInstallmentWr) {

                Decimal lMaxValueToContractInstallmentDiscount = ((lCtInstallmentWr.contractInstallment.Credit__c*lMaxDiscountPercent)/100);
                if(lMaxValueToContractInstallmentDiscount < 0) lMaxValueToContractInstallmentDiscount = 0;
                lMaxValueToDiscount += lMaxValueToContractInstallmentDiscount;
                
                system.debug('###lMaxValueToDiscount ' + lMaxValueToDiscount);
                system.debug('###lCtInstallmentWr0 ' + JSON.serialize(lCtInstallmentWr));
                // Se não possui mais debito na parcela pula para próxima
                if(lCtInstallmentWr.debt == 0) continue;

                // Incrementa a tentativa de pagamento da parcela na quinzena                
                if(!lContractInstallmentAttemptedPaymentUpdate.containsKey(lCtInstallmentWr.contractInstallment.Id)) {
                    lContractInstallmentAttemptedPaymentUpdate.put(lCtInstallmentWr.contractInstallment.Id,lCtInstallmentWr.contractInstallment.AttemptedPayment__c+1);
                }      
                
                // Pega a soma do valor das Ordens de pagamento disponiveis para abate          
                Decimal lTotalMaxValueToDiscountOrders = lTotalMaxValueToDiscountOrdersMap.get(lOrder.AccountId);
                if(lTotalMaxValueToDiscountOrders == null) lTotalMaxValueToDiscountOrders = 0;
                lTotalMaxValueToDiscountOrders += lMaxValueToContractInstallmentDiscount;

                system.debug('###lTotalMaxValueToDiscountOrders ' + lTotalMaxValueToDiscountOrders);
                // Se o valor debito(Crédito - Desconto) for maior que o maximo disponivel nas OPs não desconta nada                 
                if(lCtInstallmentWr.debt > lTotalMaxValueToDiscountOrders) continue;

                Decimal lValueToDiscount = 0;
                if(lCtInstallmentWr.debt > lMaxValueToDiscount) {
                    lValueToDiscount = lMaxValueToDiscount;
                }
                else {
                    lValueToDiscount = lCtInstallmentWr.debt;
                }
                system.debug('###lCtInstallmentWr1 ' + JSON.serialize(lCtInstallmentWr));
                if(lValueToDiscount == 0) continue;

                //Subtrai do disponivel da OP o que já foi alocado para essa parcela
                lMaxValueToDiscount -= lValueToDiscount;
                
                //Subtrai do total das OPs diponiveis o que já foi alocado para essa parcela
                lTotalMaxValueToDiscountOrders -= lValueToDiscount;
                lTotalMaxValueToDiscountOrdersMap.put(lOrder.AccountId,lTotalMaxValueToDiscountOrders);

                String lOrderItemDiscountWrKey = lOrder.Id + lCtInstallmentWr.contractInstallment.ContractId__r.RecordType.Name;
                OrderItemDiscountCreditWrapper lOrderItemDiscountCreditWrapper = lOrderItemDiscountCreditToCreateMap.get(lOrderItemDiscountWrKey); 
                if(lOrderItemDiscountCreditWrapper == null) {
                    lOrderItemDiscountCreditWrapper = new OrderItemDiscountCreditWrapper();
                    lOrderItemDiscountCreditToCreateMap.put(lOrderItemDiscountWrKey, lOrderItemDiscountCreditWrapper);
                }
                if(lOrderItemDiscountCreditWrapper.orderItemCredit == null) {
                    lOrderItemDiscountCreditWrapper.orderItemCredit = new OrderItem(
                        OrderId = lOrder.Id,
                        ItemType__c = lOrderItemTypeCredit,
                        CompanyDiscount__c = lCtInstallmentWr.contractInstallment.ContractId__r.RecordType.Name,
                        ContractInstallmentCredit__c = lCtInstallmentWr.contractInstallment.Id,
                        CreditOrder__c = lOrder.Id,
                        PricebookEntryId = lPbEntry.Id,
                        Quantity = lOrderItemDefaultQuantity,
                        UnitPrice = 0
                    );
                }
                if(lOrderItemDiscountCreditWrapper.orderItemDiscount == null) {
                    lOrderItemDiscountCreditWrapper.orderItemDiscount = new OrderItem(
                        OrderId = lOrder.Id,
                        ItemType__c = lOrderItemTypeDiscount,
                        CompanyDiscount__c = lCtInstallmentWr.contractInstallment.ContractId__r.RecordType.Name,
                        ContractInstallmentDiscount__c = lCtInstallmentWr.contractInstallment.Id,
                        DiscountOrder__c = lOrder.Id,
                        PricebookEntryId = lPbEntry.Id,
                        Quantity = lOrderItemDefaultQuantity,
                        UnitPrice = 0
                    );
                } 
                if(!lCtInstallmentWr.creditWasApplied && lValueToDiscount == lCtInstallmentWr.debt) {
                    // 
                    lOrderItemDiscountCreditWrapper.orderItemCredit.UnitPrice += lCtInstallmentWr.contractInstallment.Credit__c;
                    lOrderItemDiscountCreditWrapper.orderItemDiscount.UnitPrice += lCtInstallmentWr.contractInstallment.Discount__c;
                } 
                else {
                    if(!lCtInstallmentWr.creditWasApplied) {
                        lOrderItemDiscountCreditWrapper.orderItemCredit.UnitPrice += lCtInstallmentWr.contractInstallment.Credit__c; 
                        lCtInstallmentWr.creditWasApplied = true;
                        lOrderItemDiscountCreditWrapper.orderItemDiscount.UnitPrice += lCtInstallmentWr.contractInstallment.Discount__c - (lCtInstallmentWr.debt - lValueToDiscount); 
                    }  
                    else {
                        lOrderItemDiscountCreditWrapper.orderItemDiscount.UnitPrice += lValueToDiscount; 
                    }                                     
                }  
                
                // Contabiliza o valor pago na parcela para não  debitar novamente
                lCtInstallmentWr.amountPaid += lValueToDiscount;
                
                system.debug('###lValueToDiscount ' + lValueToDiscount);
                system.debug('###lCtInstallmentWr2 ' + JSON.serialize(lCtInstallmentWr));
            }
        } 
        
        // Caso não tenha descontos para serem criados, apenas atualiza a quantidade de tentativa na parcela
        List<ContractInstallment__c> lContractInstallmentToUpdateLst = new List<ContractInstallment__c>();
        if(lOrderItemDiscountCreditToCreateMap.isEmpty()) {
            for(ContractInstallment__c lContractInstallment :aContractInstallmentLst) {
                lContractInstallment.AttemptedPayment__c = lContractInstallmentAttemptedPaymentUpdate.get(lContractInstallment.Id);  
                lContractInstallmentToUpdateLst.add(lContractInstallment);
            }

            update lContractInstallmentToUpdateLst;
        }
        else {        
            List<OrderItem> lOrderItemToUpsertLst = new List<OrderItem>();
            for(String lKey :lOrderItemDiscountCreditToCreateMap.keySet()) {
                OrderItemDiscountCreditWrapper lOrderItemDiscountCreditWrapper = lOrderItemDiscountCreditToCreateMap.get(lKey);
                if(lOrderItemDiscountCreditWrapper.orderItemCredit.UnitPrice > 0) {
                    lOrderItemToUpsertLst.add(lOrderItemDiscountCreditWrapper.orderItemCredit);
                }
                if(lOrderItemDiscountCreditWrapper.orderItemDiscount.UnitPrice > 0) {
                    lOrderItemToUpsertLst.add(lOrderItemDiscountCreditWrapper.orderItemDiscount);
                }
            }

            if(!lOrderItemToUpsertLst.isEmpty()) upsert lOrderItemToUpsertLst;   
            
            String lStatusFinishedContract = fConfigurationValues.get('StatusFinishedContract');
            for(String lKey :lAccountContractInstallmentMap.keySet()) {
                for(ContractInstallmentWrapper lCtInstallmentWr :lAccountContractInstallmentMap.get(lKey)) {
                    if(lCtInstallmentWr.debt == 0) {
                        lCtInstallmentWr.contractInstallment.Status__c = lStatusFinishedContract;
                    }
                    lCtInstallmentWr.contractInstallment.AttemptedPayment__c = lContractInstallmentAttemptedPaymentUpdate.get(lCtInstallmentWr.contractInstallment.Id);  
                    lContractInstallmentToUpdateLst.add(lCtInstallmentWr.contractInstallment);
                }
            }
            
            update lContractInstallmentToUpdateLst;    
        }    
    }
    
    global class OrderItemDiscountCreditWrapper {
        global OrderItem orderItemDiscount;
        global OrderItem orderItemCredit;
    }


    /* 
    Wrapper para armazenar o valor já pago na parcela e o valor faltante
    */
    global class ContractInstallmentWrapper {
        global ContractInstallment__c contractInstallment;
        global Boolean creditWasApplied;
        global Decimal amountPaid;
        //global Decimal discount;
        //global Decimal credit;
        global Decimal debt {
            get {
                //Decimal lDebt = (contractInstallment.Discount__c - contractInstallment.Credit__c) - amountPaid;
                Decimal lDebt = contractInstallment.Discount__c - amountPaid;
                return lDebt != null?lDebt:0;
            }set;
        }
        global ContractInstallmentWrapper(ContractInstallment__c aContractInstallment) {
            this.contractInstallment = aContractInstallment;
            this.amountPaid = aContractInstallment.AmountPaid__c;
            //this.discount = aContractInstallment.Discount__c;
            //this.credit = aContractInstallment.Credit__c;
            this.creditWasApplied = false;
        }
    }

	global void finish(Database.BatchableContext BC) {
        if(!Test.isRunningTest()) {        
            if(this.fFirstDiscount) {
                GenerateDiscountOrderPaymentPortoSeg_bch lGenerateDiscountOrderPaymentBatch = new GenerateDiscountOrderPaymentPortoSeg_bch(fAccountIdSet,false);
                Database.executeBatch(lGenerateDiscountOrderPaymentBatch);   
            }   
            else {
                GenerateDiscountOrderPaymentOthers_bch lGenerateDiscountOrderPaymentOthersBatch = new GenerateDiscountOrderPaymentOthers_bch(fAccountIdSet);
                Database.executeBatch(lGenerateDiscountOrderPaymentOthersBatch);
            } 
                   
        }
    }    
}