@isTest
public class OperationalSetupFactory {
 

    private static Map<String, OperationalSetup__c> fStaticRecord = new Map<String, OperationalSetup__c>();
     
    //------------------------------------------GMV------------------------------------------------
    public static OperationalSetup__c createOperationalSetupGMV(){
        if(!fStaticRecord.containsKey('GMV')){
            Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('GMV').getRecordTypeId();
            fStaticRecord.put('GMV', new OperationalSetup__c(
                RecordTypeId = OSRecordType,
                Name = 'teste',
                Brand__c = 'teste',
                SupplyValue__c = 0
            ));
        }
        Return fStaticRecord.get('GMV');
    }
    public class GMV extends SObjectFactory {

        public GMV(){
            super(createOperationalSetupGMV());
        }
    }

    //------------------------------------------Baixa------------------------------------------
    public static OperationalSetup__c createOperationalSetupBaixa(){
        if(!fStaticRecord.containsKey('CloseOrder')){
            Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('CloseOrder').getRecordTypeId();
            fStaticRecord.put('CloseOrder', new OperationalSetup__c(
                RecordTypeId = OSRecordType,
                Name = 'teste1',
                Description__c = 'teste1'
            ));
        }
        Return fStaticRecord.get('CloseOrder');
    }

    public class CloseOrder extends SObjectFactory {

        public CloseOrder(){
            super(createOperationalSetupBaixa());
        }
    }

    //------------------------------------------Equipamento----------------------------------
    public static OperationalSetup__c createOperationalSetupEquipamento(){
        if(!fStaticRecord.containsKey('Equipment')){
            Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
            fStaticRecord.put('Equipment', new OperationalSetup__c(
                RecordTypeId = OSRecordType,
                Name = 'teste2',
                EquipmentType__c = 'Acessórios',
                Description__c = 'teste2',
                Brand__c = 'teste2',
                SafetyEquipment__c = 'Sim',
                Quantity__c = 7,
                EquipmentReturned__c = 'Sim'
            ));
        }
        Return fStaticRecord.get('Equipment');
    }
    public class Equipment extends SObjectFactory {

        public Equipment(){
            super(createOperationalSetupEquipamento());
        }
    }
    //------------------------------------------Habilidade--------------------------------
    public static OperationalSetup__c createOperationalSetupAbility(){
        if(!fStaticRecord.containsKey('Ability')){
            Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Ability').getRecordTypeId();
            fStaticRecord.put('Ability', new OperationalSetup__c(
                RecordTypeId = OSRecordType,
                Name = 'teste3',
                Perfil__c = 'Básico',
                Description__c = 'teste3'
            ));
        }
        Return fStaticRecord.get('Ability');
    }

    public class Ability extends SObjectFactory {

        public Ability(){
            super(createOperationalSetupAbility());
        }
    }

    //------------------------------------------Insumo----------------------------------------
    public static OperationalSetup__c createOperationalSetupSupply(){
        if(!fStaticRecord.containsKey('Supply')){
            Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Supply').getRecordTypeId();
            fStaticRecord.put('Supply', new OperationalSetup__c(
                RecordTypeId = OSRecordType,
                Name = 'teste4',
                Description__c = 'teste4',
                InputType__c = 'Bota'
            ));
        }
        Return fStaticRecord.get('Supply');
    }

    public class Supply extends SObjectFactory {

        public Supply(){
            super(createOperationalSetupSupply());
        }
    }

    //------------------------------------------Peça
    public static OperationalSetup__c createOperationalSetupPart(){
        if(!fStaticRecord.containsKey('Part')){
            Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
            fStaticRecord.put('Part', new OperationalSetup__c(
                RecordTypeId = OSRecordType,
                Name = 'teste5',
                Description__c = 'teste5'
            ));
        }
        Return fStaticRecord.get('Part');
    }

    public class Part extends SObjectFactory {

        public Part(){
            super(createOperationalSetupPart());
        }
    }
    
    
    
    //------------------------------------------GMV com código------------------------------------------------
    public static OperationalSetup__c createOperationalSetupGMVCode(){
        if(!fStaticRecord.containsKey('GMV')){
            Id OSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get('GMV').getRecordTypeId();
            fStaticRecord.put('GMV', new OperationalSetup__c(
                RecordTypeId = OSRecordType,
                Name = 'teste',
                Brand__c = 'teste',
                SupplyValue__c = 0,
                Code__c = 11
            ));
        }
        Return fStaticRecord.get('GMV');
    }
    public class GMV2 extends SObjectFactory {

        public GMV2(){
            super(createOperationalSetupGMV());
        }
    }
}