public class ContractInstallmentFactory {
    
    private static Map<String, ContractInstallment__c> fStaticRecord = new Map<String, ContractInstallment__c>();
    
	public static ContractInstallment__c createContractInstallmentPortoHealth(){
        if(!fStaticRecord.containsKey('PortoHealth')){
            Id ContractInstallmentRecType = SObjectType.ContractInstallment__c.getRecordTypeInfosByDeveloperName().get('PortoHealth').getRecordTypeId();

            fStaticRecord.put('PortoHealth', new ContractInstallment__c(
                RecordTypeId = ContractInstallmentRecType,
                ProviderCode__c = 83783,
                Discount__c	= 200,
                Credit__c = 100,
                ReferenceDate__c = system.today(),
                Status__c = 'Em Aberto'
            ));
        }
        return fStaticRecord.get('PortoHealth');
    }

    public class PortoHealth extends SObjectFactory{
        public PortoHealth(){
            super(createContractInstallmentPortoHealth());
        }
    }
}