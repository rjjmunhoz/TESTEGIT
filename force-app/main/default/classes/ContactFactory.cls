@isTest
public class ContactFactory {
    private static Map<String, Contact> fStaticRecord = new Map<String, Contact>();
    
    //----------------------------------------------Colaborador da base-----------------------------------------
    
    public static Contact createContactBaseEmployee(){
        if(!fStaticRecord.containsKey('BaseEmployees')){
            Id BaseEmployeesRectypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('BaseEmployees').getRecordTypeId();
            
            fStaticRecord.put('BaseEmployees', new Contact(
                RecordTypeId = BaseEmployeesRectypeId,
                FirstName = 'Colaborador',
                LastName = 'da base',
                CPF__c = '000000000',
                City__c = 'São Paulo'
            ));
        }
        return fStaticRecord.get('BaseEmployees');
    }
    
    public static Contact createContactBaseEmployee(id accid){
        if(!fStaticRecord.containsKey('BaseEmployees')){
            Id BaseEmployeesRectypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('BaseEmployees').getRecordTypeId();
            
            fStaticRecord.put('BaseEmployees', new Contact(
                RecordTypeId = BaseEmployeesRectypeId,
                FirstName = 'Colaborador',
                LastName = 'da base',
                CPF__c = '000000000',
                AccountId = accid,
                City__c = 'São Paulo'
            ));
        }
        return fStaticRecord.get('BaseEmployees');
    }
    public class BaseEmployees extends SObjectFactory{
        public BaseEmployees(){
            super(createContactBaseEmployee());
        }
        public BaseEmployees(Id AccId){
            super(createContactBaseEmployee(AccId));
        }
    }
	//----------------------------------------------Parceiro-----------------------------------------
    public static Contact createContactPartner(String aLastName, String aCPF){
        if(!fStaticRecord.containsKey('Partner')){
            Id PartnerId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
            
            fStaticRecord.put('Partner', new Contact(
                RecordTypeId = PartnerId,
                FirstName = 'Sócio',
                LastName = aLastName,
                CPF__c = aCPF,
                Phone = '912345678',
                MobilePhone = '912345678',
                City__c = 'São Paulo'
            ));
        }
        return fStaticRecord.get('Partner');
    }
    public class Partner extends SObjectFactory{
        public Partner(String aLastName, String aCPF){
            super(createContactPartner(aLastName,aCPF));
        }
    }
    
}