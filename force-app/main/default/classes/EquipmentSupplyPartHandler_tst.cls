@isTest
public class EquipmentSupplyPartHandler_tst {

    
    @isTest
    static void EquipmentSupplyPartTest(){
        String lBodyResponse = Label.BodyResponseCreated;  
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        Account lProvider = AccountFactory.createAccountProvider();
        lProvider.TaxCity__c = 'São Paulo';
        lProvider.Synced__c = true;
        lProvider.Status__c = Label.Status_Active;
        insert lProvider;
        
        Modal__c lModal = (Modal__c) new ModalFactory.ModalMotorcycle('teste').createRecord();
        Account lAccount = AccountFactory.createAccountSupplier();
        lAccount.TaxCity__c = 'São Paulo';
        insert lAccount;
        
        OperationalSetup__c lEquipment = (OperationalSetup__c) new OperationalSetupFactory.Equipment().createRecord();
        OperationalSetup__c lAbility = OperationalSetupFactory.createOperationalSetupAbility();//(OperationalSetup__c) new OperationalSetupFactory.Ability().createRecord();
        insert lAbility;
        
        Equipment__c Equipamento = new Equipment__c();
        Equipamento.Modal__c = lModal.Id;
        Equipamento.OperationalSetup__c = lEquipment.Id;
        Insert Equipamento;
        
        EquipmentSupplyPart__c EquipmentSupplyPart = new EquipmentSupplyPart__c();
        EquipmentSupplyPart.Account__c = lAccount.Id;
        EquipmentSupplyPart.OperationalSetup__c = lEquipment.Id;
        EquipmentSupplyPart.Abiliity__c = lAbility.Id;
        EquipmentSupplyPart.Provider__c = lProvider.Id;
        Insert EquipmentSupplyPart;
        
        update EquipmentSupplyPart;
        /*
        EquipmentSupplyPart__c EquipmentSupplyPart2 = new EquipmentSupplyPart__c();
        EquipmentSupplyPart2.Account__c = lAccount.Id;
        EquipmentSupplyPart2.OperationalSetup__c = lEquipment.Id;
        EquipmentSupplyPart2.Abiliity__c = lAbility.Id;
        EquipmentSupplyPart2.Provider__c = lProvider.Id;
        try{
            Insert EquipmentSupplyPart2;                 
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains('Esta Habilidade e este Prestador já estão vinculados. Por favor escolha outro registro.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
		*/
    }
}