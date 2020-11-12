@isTest
public class ContractFactory {

    private static Map<String, Contract> fStaticRecord = new Map<String, Contract>();
    
    public static Contract createContractPortoHealth(String aAccountId){
        if(!fStaticRecord.containsKey('PortoHealth')){
            
            Id ContractRecType = SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PortoHealth').getRecordTypeId();

            fStaticRecord.put('PortoHealth', new Contract(
                RecordTypeId = ContractRecType,
                AccountId = aAccountId,
                ContractValue__c = 1000,
                InstallmentValue__c = 500,
                StartDate = system.today()
            ));
        }
        return fStaticRecord.get('PortoHealth');
    }

    public class PortoHealth extends SObjectFactory{
        public PortoHealth(String aAccountId){
            super(createContractPortoHealth(aAccountId));
        }
    }
}