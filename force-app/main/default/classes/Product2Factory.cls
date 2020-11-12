@isTest
public class Product2Factory {

    private static Map<String, Product2> fStaticRecord = new Map<String, Product2>();

//----------------------------------------------SERVIÇO-----------------------------------------

    public static Product2 createProduct2Service(){
        if(!fStaticRecord.containsKey('Service')){
            Id ServiceRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();

            fStaticRecord.put('Service', new Product2(
                RecordTypeId = ServiceRecType,
                Name = 'Serviço'+Math.random(),
                AttendedAsset__c = 'Carro',
                Description__c = 'Descrição',
                SpecialtyType__c = 'AUTO',
                Status__c = 'Em implantação'
            ));
        }
        return fStaticRecord.get('Service');
    }

    public class Service extends SObjectFactory{
        public Service(){
            super(createProduct2Service());
        }
    }

//----------------------------------------------ESPECIALIDADE-----------------------------------------

    public static Product2 createProduct2Specialty(){
        if(!fStaticRecord.containsKey('Specialty')){
            Id SpecialtyRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Specialty').getRecordTypeId();

            fStaticRecord.put('Specialty', new Product2(
                RecordTypeId = SpecialtyRecType,
                Name = 'Especialidade',
                Description__c = 'Descrição',
                AttendedAsset__c = 'Carro',
                WarrantyMO__c = 10,
                WarrantyPiece__c = 10,
                NumberReasonsAllowed__c = 10,
                Status__c = 'Em implantação',
                SpecialtiesGroup__c = '761',
                ScheduledProvider__c = 'Sim'
            )); 
        }
        return fStaticRecord.get('Specialty');
    }

    public class Specialty extends SObjectFactory{
        public Specialty(){
            super(createProduct2Specialty());
        }
    }
    
    
	    public static Product2 createProduct2ActiveSpecialty(){
        if(!fStaticRecord.containsKey('Specialty')){
            Id SpecialtyRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Specialty').getRecordTypeId();

            fStaticRecord.put('Specialty', new Product2(
                RecordTypeId = SpecialtyRecType,
                Name = 'Especialidade',
                Description__c = 'Descrição',
                AttendedAsset__c = 'Carro',
                WarrantyMO__c = 10,
                WarrantyPiece__c = 10,
                NumberReasonsAllowed__c = 10,
                SpecialtiesGroup__c = '761',
                ScheduledProvider__c = 'Sim',
                Status__c = 'Ativo',
        		Runtime__c = Time.newInstance(1, 2, 3, 4)
            )); 
        }
        return fStaticRecord.get('Specialty');
    }
//----------------------------------------------MOTIVO-----------------------------------------

    public static Product2 createProduct2Detail(){
        if(!fStaticRecord.containsKey('Detail')){
            Id DetailRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Detail').getRecordTypeId();

            fStaticRecord.put('Detail', new Product2(
                RecordTypeId = DetailRecType,
                Name = 'Detalhe/Motivo',
                Description__c = 'Descrição',
                Status__c = 'Em implantação',
                ReasonGroup__c = String.valueOf(1)
            ));
        }
        return fStaticRecord.get('Detail');
    }

    public class Detail extends SObjectFactory{
        public Detail(){
            super(createProduct2Detail());
        }
    }

}