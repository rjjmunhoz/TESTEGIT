@isTest
public class AccountFactory {

    private static Map<String, Account> fStaticRecord = new Map<String, Account>();

//----------------------------------------------PRESTADOR-----------------------------------------

    public static Account createAccountProvider(){
        if(!fStaticRecord.containsKey(Label.ProviderRecordType)){
            Id ProviderRecType = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProviderRecordType).getRecordTypeId();

            fStaticRecord.put(Label.ProviderRecordType, new Account(
                RecordTypeId = ProviderRecType,
                Name = 'Prestador',
                Type = 'Parceiro',
                BankName__c = '260',
                CNPJ__c = '00000000000000',
                TaxCity__c = 'São Paulo',
                SucursalCode__c = 234,
                Code__c = 83783,
                LegalSituation__c = 'PJ'
            ));
        }
        return fStaticRecord.get(Label.ProviderRecordType);
    }

    public class Provider extends SObjectFactory{
        public Provider(){
            super(createAccountProvider());
        }
    }

    public static Account createAccountProviderPF(){
        if(!fStaticRecord.containsKey(Label.ProviderRecordType)){
            Id ProviderRecType = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProviderRecordType).getRecordTypeId();

            fStaticRecord.put(Label.ProviderRecordType, new Account(
                RecordTypeId = ProviderRecType,
                Name = 'Prestador',
                Type = 'Parceiro',
                BankName__c = '260',
                CNPJ__c = '00000000085',
                TaxCity__c = 'São Paulo',
                SucursalCode__c = 234,
                Code__c = 83783,
                LegalSituation__c = 'PF'
            ));
        }
        return fStaticRecord.get(Label.ProviderRecordType);
    }

    public class ProviderPF extends SObjectFactory{
        public ProviderPF(){
            super(createAccountProviderPF());
        }
    }
//----------------------------------------------FORNECEDOR-----------------------------------------

    public static Account createAccountSupplier(){
        if(!fStaticRecord.containsKey(Label.SupplierRecordType)){
            Id ProviderRecType = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.SupplierRecordType).getRecordTypeId();

            fStaticRecord.put(Label.SupplierRecordType, new Account(
                RecordTypeId = ProviderRecType,
                Name = 'Fornecedor',
                CompanyName__c = 'Razão social',
                CNPJ__c = '12222333000190',
                BankName__c = '260',
                Branch__c = '00001',
                CheckingAccount__c = '123456789',
                CurrentAccountDigit__c = '1',
                Status__c = 'Em implantação',
                TaxCity__c = 'São Paulo'
            ));
        }
        return fStaticRecord.get(Label.SupplierRecordType);
    }

    public class Supplier extends SObjectFactory{
        public Supplier(){
            super(createAccountSupplier());
        }
    }

//----------------------------------------------PRODUTO-----------------------------------------

    public static Account createAccountProduct(){
        if(!fStaticRecord.containsKey(Label.ProductRecordType)){
            Id ProviderRecType = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.SupplierRecordType).getRecordTypeId();

            fStaticRecord.put('Product2', new Account(
                Name = 'Nome',
                CNPJ__c = '12222333000190',
                CompanyName__c = 'Razão social' 
            ));
        }
        return fStaticRecord.get(Label.ProductRecordType);
    }

    public class Product extends SObjectFactory{
        public Product(){
            super(createAccountProduct());
        }
    }
}