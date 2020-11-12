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
* @version   1.0    2020-07-29      Misael Ribas          class created 
**************************************************************************************************************/
public class ContractHandler_cls {

    private static final String CONTRACT_PORTO_OTHERDISCOUNTS_RECTYPE = SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(Label.OtherDiscountsLabel).getRecordTypeId();
    private static final String CONTRACT_PORTO_SAUDE_RECTYPE = SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(Label.ContractPortoSaudeRercordType).getRecordTypeId();
    private static final String PROVIDER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProviderRecordType).getRecordTypeId();

    public static void CheckDuplicatesContracts(List<Contract> aContractLst) {

        TriggerCheck.assert();
        
        Map<Id,Contract> lContractMap = new Map<Id,Contract>();
        for(Contract lContract :aContractLst){
            if(lContract.RecordTypeId == CONTRACT_PORTO_SAUDE_RECTYPE){
            	lContractMap.Put(lContract.AccountId,lContract);
            }
        }
        if(lContractMap.isEmpty()) return;
        
        for(Contract lContractExisting :[SELECT Id, AccountId FROM Contract 
                WHERE AccountId =:lContractMap.keySet() 
                AND RecordTypeId =:CONTRACT_PORTO_SAUDE_RECTYPE
                AND Status = :Label.ContractStatusActive]){
            if(lContractMap.get(lContractExisting.AccountId) != null){
                lContractMap.get(lContractExisting.AccountId).addError(Label.ErrorProviderAlreadyContract);
            }
        }
	}
    
    public static void AutoFillContractFields(List<Contract> aContractLst) {

        TriggerCheck.assert();
    	
        Map<Id,Contract> lContractIdMap = new Map<Id,Contract>();
        Map<String,Contract> lContractCNPJMap = new Map<String,Contract>();
        for(Contract lContract :aContractLst){
            // if(lContract.RecordTypeId == CONTRACT_PORTO_SAUDE_RECTYPE || lContract.RecordTypeId == CONTRACT_PORTO_OTHERDISCOUNTS_RECTYPE){
                if(lContract.AccountId != null){
                    lContractIdMap.put(lContract.AccountId,lContract);
                }
                else if(lContract.CNPJ__c != null){
                    lContractCNPJMap.put(lContract.CNPJ__c,lContract);
                }
            // }
        }
        if(lContractIdMap.isEmpty() && lContractCNPJMap.isEmpty()) return;
        
        for(Account lAccount :[SELECT Id, Name, Code__c, CNPJ__c, RecordTypeId FROM Account WHERE RecordTypeId =:PROVIDER_RECTYPE AND (Id =:lContractIdMap.keySet() OR CNPJ__c =: lContractCNPJMap.keySet())]){
            if(lContractIdMap.get(lAccount.Id) != null){
                lContractIdMap.get(lAccount.Id).CNPJ__c = lAccount.CNPJ__c;
            }
            else if(lContractCNPJMap.get(lAccount.CNPJ__c) != null){
                lContractCNPJMap.get(lAccount.CNPJ__c).AccountId = lAccount.Id;
            }
        }
    }
}