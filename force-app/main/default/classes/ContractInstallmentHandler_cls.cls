/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Classe manipuladora da trigger do objeto Parcela
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-07-24      Eduardo Costa           class created 
* @version   2.0    2020-07-28      Misael Ribas            class updated 
**************************************************************************************************************/
public with sharing class ContractInstallmentHandler_cls {

    private static final String INSTALLMENT_PORTO_SAUDE_RECTYPE = SObjectType.ContractInstallment__c.getRecordTypeInfosByDeveloperName().get(Label.ContractInstallmentPortoSaudeRercordType).getRecordTypeId();
    private static final String CONTRACT_PORTO_SAUDE_RECTYPE = SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(Label.ContractPortoSaudeRercordType).getRecordTypeId();

    private static final Id fDiscountTypeId {
        get {
            if(fDiscountTypeId == null) {
                List<DiscountType__c> lDiscountTypeLst = [SELECT Id FROM DiscountType__c 
                        WHERE Type__c = :Label.DiscountTypeCodePortoHealth 
                        AND Status__c = :Label.DiscountTypeStatusActive];
                if(!lDiscountTypeLst.isEmpty()) {
                    fDiscountTypeId = lDiscountTypeLst[0].Id;
                }
            }            
            return fDiscountTypeId;
        }
        set;
    }
    

    public static void contractRelationshipCreation(List<ContractInstallment__c> aContractInstallmentHandlerLst) {

        TriggerCheck.assert();
        
        Map<Decimal,List<ContractInstallment__c>> lContractInstallmentToCreateContractLstMap = new Map<Decimal,List<ContractInstallment__c>>();
        Map<Decimal,Contract> lCodeContractToCreateMap = new Map<Decimal,Contract>();
        Map<Decimal,Account> lCodeAccountMap = new Map<Decimal,Account>();
        
        for(ContractInstallment__c lContractInstallment :aContractInstallmentHandlerLst) {
            
            if(lContractInstallment.RecordTypeId == INSTALLMENT_PORTO_SAUDE_RECTYPE && lContractInstallment.ContractId__c == null) {
                if(String.isBlank(fDiscountTypeId)) {
                    lContractInstallment.addError(Label.ActiveDiscountTypePortoHealthNotFound);
                }

                lCodeAccountMap.put(lContractInstallment.ProviderCode__c,null);

                List<ContractInstallment__c> lContractInstallmentToCreateContractLst = lContractInstallmentToCreateContractLstMap.get(lContractInstallment.ProviderCode__c);
                if(lContractInstallmentToCreateContractLst == null) {
                    lContractInstallmentToCreateContractLst = new List<ContractInstallment__c>();
                    lContractInstallmentToCreateContractLstMap.put(lContractInstallment.ProviderCode__c,lContractInstallmentToCreateContractLst);
                }
                
                lContractInstallmentToCreateContractLst.add(lContractInstallment);
                lCodeContractToCreateMap.put(lContractInstallment.ProviderCode__c,
                    new Contract(
                        StartDate = system.today(),
                        DiscountType__c = fDiscountTypeId,
                        RecordTypeId = CONTRACT_PORTO_SAUDE_RECTYPE
                    )
                );                
            }            
        }
        
        if(lContractInstallmentToCreateContractLstMap.isEmpty()) return;
        
        for(Account lAccount :[SELECT Id, Code__c, CNPJ__c,
                    (SELECT Id, AccountId, Account.Code__c, Status
                    FROM Contracts 
                    WHERE RecordtypeId = :CONTRACT_PORTO_SAUDE_RECTYPE)
                FROM Account WHERE Code__c IN :lCodeAccountMap.keySet()]) {

            lCodeAccountMap.put(lAccount.Code__c,lAccount);    
            if(!lAccount.Contracts.isEmpty()) {
                lCodeContractToCreateMap.put(lAccount.Code__c, lAccount.Contracts[0]);
            }
            else {
                Contract lContract = lCodeContractToCreateMap.get(lAccount.Code__c);
                if(lContract != null) {
                    lContract.CNPJ__c = lAccount.CNPJ__c;
                    lContract.AccountId = lAccount.Id;
                    lContract.Account = lAccount;
                    lContract.ContractNumber__c = lAccount.Code__c + '-01';
                }
            }            
        }

        Database.UpsertResult[] lSaveResultLst = Database.upsert(lCodeContractToCreateMap.values(), false);

        List<Contract> lContractToActivateLst = new List<Contract>();
        for(Contract lContract :lCodeContractToCreateMap.values()) {
            if(lContract.Id != null) {
                if(lContract.Status != Label.ContractStatusActive) {
                    lContract.Status = Label.ContractStatusActive;
                    lContractToActivateLst.add(lContract);
                }
            }            
        }

        if(!lContractToActivateLst.isEmpty()) update lContractToActivateLst;

        for(Integer i = 0; i < lSaveResultLst.size(); i++){
			if(!lSaveResultLst[i].isSuccess()){
                String lMsgError = '';
                for(Database.Error lError : lSaveResultLst[i].getErrors()){
					lMsgError += lError.getStatusCode() + ' : ' + lError.getMessage() + '\n';
                }
                
                Contract lContract = lCodeContractToCreateMap.values()[i];
                if(lContract.Account != null) {
                    for(ContractInstallment__c lContractInstallment :lContractInstallmentToCreateContractLstMap.get(lContract.Account.Code__c)) {
                        lContractInstallment.addError(lMsgError);
                    }
    
                    lContractInstallmentToCreateContractLstMap.remove(lContract.Account.Code__c);  
                }                              
			}
        }        
        
        if(lContractInstallmentToCreateContractLstMap.isEmpty()) return;
        
        List<ContractInstallment__c> lContractInstallmentToCreateContractLst = new List<ContractInstallment__c>();
        for(Decimal lKey :lContractInstallmentToCreateContractLstMap.keySet()) {
            lContractInstallmentToCreateContractLst.addAll(lContractInstallmentToCreateContractLstMap.get(lKey));
        }

        for(ContractInstallment__c lContractInstallment :lContractInstallmentToCreateContractLst) {
            Account lAccount = lCodeAccountMap.get(lContractInstallment.ProviderCode__c);
            if(lAccount == null) {
                lContractInstallment.addError(Label.ProviderNotFound);
            }
            lContractInstallment.ContractId__c = lCodeContractToCreateMap.get(lContractInstallment.ProviderCode__c).Id;
        }
    }

    public static void contractInstallmentMonthValidation(List<ContractInstallment__c> aContractInstallmentHandlerLst) {

        TriggerCheck.assert();
                
        Set<String> lContractIdSet = new Set<String>();
        Set<String> lExistingContractInstallmentSet = new Set<String>();
        List<ContractInstallment__c> lContractInstallmentToCreateContractLst = new List<ContractInstallment__c>();
        for(ContractInstallment__c lContractInstallment :aContractInstallmentHandlerLst) {            
            if(lContractInstallment.RecordTypeId == INSTALLMENT_PORTO_SAUDE_RECTYPE && lContractInstallment.ContractId__c != null) {
                // Caso já tenha na mesma inclusão parcelas para o mesmo contrato, mês e ano de referência apresenta erro de duplicidade
                if(lExistingContractInstallmentSet.contains(lContractInstallment.ContractId__c + String.valueOf(lContractInstallment.ReferenceDate__c.month()) + String.valueOf(lContractInstallment.ReferenceDate__c.year()))) {
                    lContractInstallment.addError(Label.InstallmentAlreadyRegisteredThisMonth);
                }
                else {
                    // Para toda parcela adciona no set a parcela do contrado para o mês e ano de referência
                    lExistingContractInstallmentSet.add(lContractInstallment.ContractId__c + String.valueOf(lContractInstallment.ReferenceDate__c.month()) + String.valueOf(lContractInstallment.ReferenceDate__c.year()));
                }

                lContractInstallmentToCreateContractLst.add(lContractInstallment);
                lContractIdSet.add(lContractInstallment.ContractId__c);            
            }            
        }
        
        if(lContractIdSet.isEmpty()) return;        

        lExistingContractInstallmentSet.clear();
        for(ContractInstallment__c lContractInstallment :[SELECT ReferenceDate__c, ContractId__c FROM ContractInstallment__c WHERE ContractId__c IN :lContractIdSet]) {
            lExistingContractInstallmentSet.add(lContractInstallment.ContractId__c + String.valueOf(lContractInstallment.ReferenceDate__c.month()) + String.valueOf(lContractInstallment.ReferenceDate__c.year()));
        }

        for(ContractInstallment__c lContractInstallment :lContractInstallmentToCreateContractLst) {
            if(lExistingContractInstallmentSet.contains(lContractInstallment.ContractId__c + String.valueOf(lContractInstallment.ReferenceDate__c.month()) + String.valueOf(lContractInstallment.ReferenceDate__c.year()))) {
                lContractInstallment.addError(Label.InstallmentAlreadyRegisteredThisMonth);
            }
        }
    }
}