public class DependentFactory {
    
    private static Map<String, Dependent__c> fStaticRecord = new Map<String, Dependent__c>();
	public static Dependent__c createDependent(id aContact){
            
            fStaticRecord.put('Dependent', new Dependent__c(
                Name = 'Dependent',
                CPF__c = '000000000',
                PersonHolder__c = aContact
            ));
        
        return fStaticRecord.get('Dependent');
    }
    public class Dependent extends SObjectFactory{
        public Dependent(Id aContact){
            super(createDependent(aContact));
        }
    }
}