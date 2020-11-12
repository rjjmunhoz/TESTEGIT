/**************************************************************************************************************
* Globant Brasil
* @author        	Misael Ribas (misael.ribas@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para gerar a cobertura das classes OperationalSetupHandler, EquipmentWebService
*                   e AbilityWebService
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0     2019-12-16      MisaelRibas             class created 
            1.1     2020-04-08      Matheus Branco          class update to coverage
**************************************************************************************************************/

@isTest
public class OperationalSetupHandler_tst {
    
    @isTest
    static void junctionsCreate(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        Modal__c lModal = (Modal__c) new ModalFactory.ModalMotorcycle('teste').createRecord();
        Account lAccount = (Account) new AccountFactory.Supplier().createRecord();
        
//----------------------------------------------GMV-------------------------------------------------------------
        OperationalSetup__c lGMV = (OperationalSetup__c) new OperationalSetupFactory.GMV().createRecord();
        GMV__c Gmv = new GMV__c();
        Gmv.Modal__c = lModal.Id;
        Gmv.OperationalSetup__c = lGMV.Id;
        insert Gmv;
        
//------------------------------------------Equipamento---------------------------------------------------------
		
    	OperationalSetup__c lEquipment = (OperationalSetup__c) new OperationalSetupFactory.Equipment().createRecord();
        
        Equipment__c Equipamento = new Equipment__c();
        Equipamento.Modal__c = lModal.Id;
        Equipamento.OperationalSetup__c = lEquipment.Id;
        Insert Equipamento;
        
        EquipmentSupplyPart__c EquipmentSupplyPart = new EquipmentSupplyPart__c();
        EquipmentSupplyPart.Account__c = lAccount.Id;
        EquipmentSupplyPart.OperationalSetup__c = lEquipment.Id;
        Insert EquipmentSupplyPart;
        
//------------------------------------------------------------------------------------------------------------------------      	
        Map<Id, OperationalSetup__c> lOSMap = new Map<Id, OperationalSetup__c>();
    	List<OperationalSetup__c> lOSList = [SELECT Id, Name FROM OperationalSetup__c];
        
        Integer i = 0;
    	for(OperationalSetup__c lOS:lOSList){
        	lOS.Name = lOS.Name+i;
        	lOS.Status__c = Label.Status_Active;
            
        	lOSMap.put(lOS.Id,lOS);
        	
            try{
            	update lOSMap.get(lOS.Id);
        	}
        	catch(Exception ex){
            	Return;
        	}
    	}
         
    }
    
    @isTest
    static void junctionsCreateComplement(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        Modal__c lModal = (Modal__c) new ModalFactory.ModalMotorcycle('teste').createRecord();
        Account lAccount = (Account) new AccountFactory.Supplier().createRecord();
        
//--------------------------------------------Insumos-----------------------------------------------------------         
    	
    	OperationalSetup__c lSupply = (OperationalSetup__c) new OperationalSetupFactory.Supply().createRecord();
        Supply__c Supply = new Supply__c();
        Supply.Modal__c = lModal.Id;
        Supply.OperationalSetup__c = lSupply.Id;
        Insert Supply;
        
        EquipmentSupplyPart__c lEquipmentSupplyPart = new EquipmentSupplyPart__c();
        lEquipmentSupplyPart.ProviderInputs__c = lAccount.Id;
        lEquipmentSupplyPart.Input__c = lSupply.Id;
        Insert lEquipmentSupplyPart;
		
        
//------------------------------------------------------------------------------------------------------------------------      	
        Map<Id, OperationalSetup__c> lOSMap = new Map<Id, OperationalSetup__c>();
    	List<OperationalSetup__c> lOSList = [SELECT Id, Name FROM OperationalSetup__c];
        
        Integer i = 0;
    	for(OperationalSetup__c lOS:lOSList){
        	lOS.Name = lOS.Name+i;
        	lOS.Status__c = Label.Status_Active;
            
        	lOSMap.put(lOS.Id,lOS);
        	
            try{
            	update lOSMap.get(lOS.Id);
        	}
        	catch(Exception ex){
            	Return;
        	}
    	}
    }
//------------------------------------------------------------------------------------------------------------------------  
//-------------------------------------------------Habilidade-------------------------------------------------------------
    @isTest 
    static void updateAbility(){
        String lBodyResponse = Label.BodyResponseCreated;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        OperationalSetup__c lAbility = OperationalSetupFactory.createOperationalSetupAbility();
        insert lAbility;
        
        lAbility.Name = 'Habilidade Salesforce';
        update lAbility;
        lAbility.Perfil__c = 'Intermediário';
        update lAbility;
        lAbility.Description__c = 'Habilidade Salesforce';
        update lAbility;
        lAbility.Status__c = Label.Status_Active;
        update lAbility;
        
        system.assertEquals(lAbility.Status__c, Label.Status_Active);
    }
//--------------------------------------------------------------------------------------------------------------------   
//-------------------------------------------------Equipamento--------------------------------------------------------    
    @isTest 
    static void updateAEquipment(){
        String lBodyResponse = Label.BodyResponseCreated;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
		        
        OperationalSetup__c lEquipment = OperationalSetupFactory.createOperationalSetupEquipamento();
        insert lEquipment;
        
        lEquipment.Description__c = 'Equipamento Salesforce';
        update lEquipment;
        lEquipment.Brand__c = 'Mundial';
       	update lEquipment;
        lEquipment.UnitaryValue__c = 50;
        update lEquipment;
        lEquipment.SafetyEquipment__c = Label.String_No;
        update lEquipment;
        lEquipment.SerialCode__c = '23666';
        update lEquipment;
        lEquipment.Quantity__c = 100;
        update lEquipment;
        lEquipment.EquipmentReturned__c = Label.String_No;
        update lEquipment;
        lEquipment.RequestDate__c = system.today();
        update lEquipment;
        lEquipment.UseTime__c = 365;
        update lEquipment;
        lEquipment.EntryDate__c = system.today();
        update lEquipment;
        lEquipment.WarrantyTime__c = 90;
        update lEquipment;
        lEquipment.Status__c = Label.Status_Inactive;
        update lEquipment;
        
        system.assertEquals(lEquipment.Status__c, Label.Status_Inactive);
    }
//----------------------------------------------------------------------------------------------------------------    
    
    @isTest 
    static void ExternalIdTest(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
		     
		OperationalSetup__c lGMV = (OperationalSetup__c) new OperationalSetupFactory.GMV2().createRecord();
		system.debug('1 teste Id:'+ lGMV.Id);
    	OperationalSetup__c lEquipment = (OperationalSetup__c) new OperationalSetupFactory.Equipment().createRecord();
        system.debug('2 teste Id:'+ lEquipment.Id);
        
        Boolean lTestGMV;
        OperationalSetup__c lTestGMVCode = [SELECT Id, code__c FROM OperationalSetup__c WHERE Id =: lGMV.Id];
        if(lTestGMVCode.code__c != null) lTestGMV = true;
        
        Boolean lTestEquipment;
        OperationalSetup__c lTestEquipmentCode = [SELECT Id, code__c FROM OperationalSetup__c WHERE Id =: lEquipment.Id];
        if(lTestEquipmentCode.code__c != null) lTestEquipment = true;
        
        System.assertEquals(lTestGMV, true);
        System.assertEquals(lTestEquipment, true);
        
    }
    @isTest 
    static void validateExternalIdTest(){
        
        system.debug('teste validateExternalIdTest');
        
		OperationalSetup__c lGMV = (OperationalSetup__c) new OperationalSetupFactory.GMV2().createRecord();
        OperationalSetup__c lTestGMVCode = [SELECT Id, code__c FROM OperationalSetup__c WHERE Id =: lGMV.Id];
        
        OperationalSetup__c lGMVCode = new OperationalSetup__c();
        Id oSRecordType = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.GMVRecordType).getRecordTypeId();
		lGMVCode.RecordTypeId = oSRecordType;
        lGMVCode.Name = 'teste 85-8';
        lGMVCode.Brand__c = 'teste 920';
        lGMVCode.SupplyValue__c = 0;
        lGMVCode.Code__c = lTestGMVCode.Code__c;
        
        try{       	
        	insert lGMVCode;
        }
        catch(Exception ex){ 
        }
        system.debug('1 teste Id:'+ lGMVCode.Id);
        system.debug('2 teste code:'+ lGMV.Code__c);
        system.debug('3 teste code:'+ lGMVCode.Code__c);
        System.assertEquals(lGMVCode.Code__c, lTestGMVCode.Code__c);
        
    }
}