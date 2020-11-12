@isTest
public class ModalFactory{

    private static Map<String, Modal__c> fStaticRecord = new Map<String, Modal__c>();
    private static Id MODAL_REC_TYPE = SObjectType.Modal__c.getRecordTypeInfosByDeveloperName().get('ModalRecord').getRecordTypeId();

//----------------------------------------------MODAL-----------------------------------------

    public static Modal__c createModalResidential(String aName){
        if(!fStaticRecord.containsKey('ModalResidential')){

            fStaticRecord.put('ModalResidential', new Modal__c(
                RecordTypeId = MODAL_REC_TYPE,
                Name__c = aName,
                Initials__c = 'RE',
                Description__c = 'Descrição',
                Safe__c = 'Seguro',
                ModalType__c = 'Residencial',
                Survey__c = 'Anual',
                RequiredItems__c = 'Ar condicionado',
                CNHCategory__c = 'B',
                Status__c = 'Em implantação'
            ));
        }
        return fStaticRecord.get('ModalResidential');
    }

    public class ModalResidential extends SObjectFactory{
        public ModalResidential(String aName){
            super(createModalResidential(aName));
        }
    }

    public static Modal__c createModalMotorcycle(String aName){
        if(!fStaticRecord.containsKey('ModalMotorcycle')){

            fStaticRecord.put('ModalMotorcycle', new Modal__c(
                RecordTypeId = MODAL_REC_TYPE,
                Name__c = aName,
                Initials__c = 'RE',
                Description__c = 'Descrição',
                Safe__c = 'Seguro',
                ModalType__c = 'Moto',
                Survey__c = 'Anual',
                CNHCategory__c = 'A',
                Status__c = 'Em implantação'
            ));
        }
        return fStaticRecord.get('ModalMotorcycle');
    }

    public class ModalMotorcycle extends SObjectFactory{
        public ModalMotorcycle(String aName){
            super(createModalMotorcycle(aName));
        }
    }

    public static Modal__c createModalSustainable(String aName){
        if(!fStaticRecord.containsKey('ModalSustainable')){

            fStaticRecord.put('ModalSustainable', new Modal__c(
                RecordTypeId = MODAL_REC_TYPE,
                Name__c = aName,
                Initials__c = 'RE',
                Description__c = 'Descrição',
                Safe__c = 'Seguro',
                ModalType__c = 'Sustentável',
                RequiredItems__c = 'Ar condicionado',
                Status__c = 'Em implantação'
            ));
        }
        return fStaticRecord.get('ModalSustainable');
    }

    public class ModalSustainable extends SObjectFactory{
        public ModalSustainable(String aName){
            super(createModalSustainable(aName));
        }
    }

    public static Modal__c createModalTaxi(String aName){
        if(!fStaticRecord.containsKey('ModalTaxi')){

            fStaticRecord.put('ModalTaxi', new Modal__c(
                RecordTypeId = MODAL_REC_TYPE,
                Name__c = aName,
                Initials__c = 'RE',
                Description__c = 'Descrição',
                Safe__c = 'Seguro',
                ModalType__c = 'Táxi',
                RequiredItems__c = 'Ar condicionado',
                CNHCategory__c = 'B',
                Status__c = 'Em implantação'
            ));
        }
        return fStaticRecord.get('ModalTaxi');
    }

    public class ModalTaxi extends SObjectFactory{
        public ModalTaxi(String aName){
            super(createModalTaxi(aName));
        }
    }
}