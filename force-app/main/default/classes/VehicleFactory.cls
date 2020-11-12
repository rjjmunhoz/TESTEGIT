@isTest
public class VehicleFactory {
    
    public static Vehicle__c createVehicle(){ 
        vehicle__c lVehicleCreate = new vehicle__c();
        /*List<Modal__c> lModalLst = new List<Modal__c>();
        lModalLst.add(ModalFactory.createModalMotorcycle('Modal'));
        lModalLst.add(ModalFactory.createModalResidential('Modal1'));
        lModalLst.add(ModalFactory.createModalSustainable('Modal2'));
        lModalLst.add(ModalFactory.createModalTaxi('Modal3'));
        insert lModalLst;
        
        
        OperationalSetup__c lOPEquipament = OperationalSetupFactory.createOperationalSetupEquipamento();
		insert lOPEquipament;

        OperationalSetup__c lOPSupply = OperationalSetupFactory.createOperationalSetupSupply();
        insert lOPSupply;

        List<Equipment__c> lEquipmentLst = new List<Equipment__c>();
        List<Supply__c> lSupplyLst = new List<Supply__c>();
        
		Map<Id,Modal__c> lModalMap = new Map<Id,Modal__c>();
        for(Modal__c lModal: lModalLst){
            Equipment__c lEquipament = new Equipment__c();
        	lEquipament.Modal__c = lModal.Id;
            lEquipament.OperationalSetup__c = lOPEquipament.Id;
            lEquipmentLst.add(lEquipament);
            
            Supply__c lSupply = new Supply__c();
            lSupply.Modal__c = lModal.Id;
            lSupply.OperationalSetup__c = lOPSupply.Id;
            lSupplyLst.add(lSupply);

        }
        insert lEquipmentLst;
        insert lSupplyLst;
        
        List<Modal__c> lModalLst2 = new List<Modal__c>();
        for(Modal__c lModal: [SELECT Status__c FROM Modal__c]){
            
            lModal.Status__c = Label.Status_Active;
			lModalLst2.add(lModal);
        }
        
        update lModalLst2;*/
        
        Account lProvider = AccountFactory.createAccountProvider();
        Insert lProvider;
        
        //system.debug('Id Modal: ' + lModal.Id);
        system.debug('Id Prestador: ' + lProvider.Id);
        lVehicleCreate.phone__c = '21967464736';
        lVehicleCreate.secondaryphone__c = '1198987989';
        //lVehicleCreate.TypeModal__c = lModalLst[0].Id;
        lVehicleCreate.Provider__c = lProvider.Id;
        lVehicleCreate.TypeRegistration__c = '6';
        lVehicleCreate.Company__c = '35;1;84';
        lVehicleCreate.Name = 'HONDA CIVIC';
        lVehicleCreate.YearManufacture__c = '1995';
        lVehicleCreate.plate__c = 'CEI0781';
        lVehicleCreate.Chassi__c = 'VF37CNFZ2SP733288';
        lVehicleCreate.Color__c = '1';
        lVehicleCreate.TypeFuel__c = '2';
        lVehicleCreate.RenavamCode__c = '10293847564';
        lVehicleCreate.TypeAcquisition__c = '2';
        lVehicleCreate.IPVA__c = 'Pendente';
        lVehicleCreate.TrafficFines__c = 'Consta';
        lVehicleCreate.Restrictions__c = 'NADA CONSTA'; 
        lVehicleCreate.Nonstop__c = 'Sim';
        lVehicleCreate.Standardization__c ='Sim';

        //insert lVehicleCreate;
        
        return lVehicleCreate;
    	
    }
    

}