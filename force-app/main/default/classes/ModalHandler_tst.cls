/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para gerar a cobertura das classes ModalHandler e ModalWebService
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0     2019-12-16      Matheus Branco          class created 
            1.1     2020-03-26      Matheus Branco          class update to coverage
**************************************************************************************************************/

@isTest
public class ModalHandler_tst {
    @isTest
    static void ModalHandlerTest(){        
        
        String lBodyResponse = Label.BodyResponseCreated;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        List<Modal__c> lModalLst = new List<Modal__c>();
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
            
            lModal.Status__c = Label.Status_Active;
			lModalMap.put(lModal.Id,lModal);
        }
        insert lEquipmentLst;
        insert lSupplyLst;
        
        update lModalLst;
    } 
    
    /*@isTest
    static void ModalHandlerTestError(){        
        
        String lBodyResponse = '{'
            +'\"statusCode\": 501,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(501,'Created',lBodyResponse));
        
        List<Modal__c> lModalLst = new List<Modal__c>();
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
            
            lModal.Status__c = 'Ativo';
			lModalMap.put(lModal.Id,lModal);
        }
        insert lEquipmentLst;
        insert lSupplyLst;
        
        update lModalLst;
    }*/ 
           
    @TestSetup
    static void makeData(){

        Modal__c lModalResidential = (Modal__c) new ModalFactory.ModalResidential('Residencial').createRecord();
        Modal__c lModalSustainable = (Modal__c) new ModalFactory.ModalSustainable('Sustentável').createRecord();
    }

    @isTest
    static void verifyModalResidential(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        Modal__c lModalResidential = [SELECT Id, Status__c FROM Modal__c 
                                  WHERE ModalType__c = :Label.ModalTypeResidential LIMIT 1];
        System.assertEquals(lModalResidential.Status__c, Label.Status_Deployment);

        try{
            lModalResidential.Status__c = Label.Status_Active;
            update lModalResidential;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains(Label.ErrorModalLinkedEquipmentSupply) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    @isTest
    static void verifyModalSustainable(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        Modal__c lModalSustainable = [SELECT Id, Status__c FROM Modal__c 
                                  WHERE ModalType__c = :Label.ModalTypeSustainable LIMIT 1];
        System.assertEquals(lModalSustainable.Status__c, Label.Status_Deployment);

        try{
            lModalSustainable.Status__c = Label.Status_Active;
            update lModalSustainable;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains(Label.ErrorModalLinkedSupply) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
}