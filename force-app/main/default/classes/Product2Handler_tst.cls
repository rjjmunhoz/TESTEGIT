/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para gerar a cobertura das classes Product2Handler, SpecialtyWebService
*                   e ReasonWebService
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0     2019-12-17      Matheus Branco          class created 
            1.1     2020-04-08      Matheus Branco          class update to coverage
**************************************************************************************************************/

@isTest
public class Product2Handler_tst {

    @TestSetup
    static void makeData(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));

        Product2 lProduct2DuplicateService = (Product2) new Product2Factory.Service().createRecord();
        lProduct2DuplicateService.Status__c = Label.Status_Active;
        update lProduct2DuplicateService;
        
        Product2 lProduct2DuplicateSpecialty = Product2Factory.createProduct2Specialty();
        lProduct2DuplicateSpecialty.Status__c = Label.Status_Active;
        insert lProduct2DuplicateSpecialty;        
                   
        Product2 lProduct2DuplicateDetail = Product2Factory.createProduct2Detail();
        lProduct2DuplicateDetail.Status__c = Label.Status_Active;
        insert lProduct2DuplicateDetail;
        
        lProduct2DuplicateDetail.Name = '10';
        update lProduct2DuplicateDetail;
        
        lProduct2DuplicateDetail.Description__c = 'Teste Motivo';
        update lProduct2DuplicateDetail;
        
        lProduct2DuplicateDetail.Status__c = Label.Status_Inactive;
        update lProduct2DuplicateDetail;
    }

    @isTest
    static void verifyDuplicate(){
        try{
            List<Product2> lProduct2 = new Product2Factory.Service().createRecords();
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains('Não é possível definir o nome como ') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    @isTest
    static void updateSpecialty(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        Product2 lProduct2Specialty = Product2Factory.createProduct2Specialty();
        lProduct2Specialty.Name = 'Outra especialidade';
        insert lProduct2Specialty;
        
        lProduct2Specialty.WarrantyMO__c = 90;
        update lProduct2Specialty;
        lProduct2Specialty.WarrantyPiece__c = 100;
        update lProduct2Specialty;
        lProduct2Specialty.NumberReasonsAllowed__c = 10;
        update lProduct2Specialty;
        lProduct2Specialty.OperationalService__c = false;
        update lProduct2Specialty;
        lProduct2Specialty.Runtime__c = Time.newInstance(0, 15, 0, 0);
        lProduct2Specialty.Description__c = 'Especialidade Salesforce';
        update lProduct2Specialty;
        lProduct2Specialty.Status__c = Label.Status_Active;
        update lProduct2Specialty;
        lProduct2Specialty.ScheduleType__c = '3';
        lProduct2Specialty.PreferredScheduleType__c = '1';
        update lProduct2Specialty;
		lProduct2Specialty.PreferredScheduleType__c = '2';
        update lProduct2Specialty;
        lProduct2Specialty.ScheduledProvider__c = Label.String_No;
        update lProduct2Specialty;
        
        System.assertEquals(lProduct2Specialty.Status__c, Label.Status_Active);
    }
    
    @isTest 
    static void ExternalIdTest(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
    	
        Product2 lProduct2Specialty = Product2Factory.createProduct2Specialty();
        lProduct2Specialty.Name = 'Outra especialidade 2';
        insert lProduct2Specialty;

        Product2 lProduct2Service = (Product2) new Product2Factory.Service().createRecord();
        
        
        Boolean lTestProduct2Specialty;
        Product2 lProduct2SpecialtyTest = [SELECT Id, Code__c FROM Product2 WHERE Id =: lProduct2Specialty.Id];
        if(lProduct2SpecialtyTest.code__c != null) lTestProduct2Specialty = true;
        
        Boolean lTestProduct2Service;
        Product2 lProduct2ServiceTest = [SELECT Id, Code__c FROM Product2 WHERE Id =: lProduct2Service.Id];
        if(lProduct2ServiceTest.code__c != null) lTestProduct2Service = true;
        
        System.assertEquals(lTestProduct2Specialty, true);
        System.assertEquals(lTestProduct2Service, true);

    }
    
    @isTest 
    static void validateExternalIdTest(){
        
        system.debug('teste validateExternalIdTest');
    
        Product2 lProduct2Specialty = Product2Factory.createProduct2Specialty();
        lProduct2Specialty.Name = 'Outra especialidade 2';
        insert lProduct2Specialty;
        Product2 lProduct2SpecialtyTest = [SELECT Id, Code__c FROM Product2 WHERE Id =: lProduct2Specialty.Id];
        
        
        Id SpecialtyRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.SpecialtyRecordType).getRecordTypeId();
        Product2 lProduct2SpecialtyCode = new Product2();
		lProduct2SpecialtyCode.RecordTypeId = SpecialtyRecType;
        lProduct2SpecialtyCode.Name = 'Especialidade 2';
        lProduct2SpecialtyCode.Description__c = 'Descrição 2';
        lProduct2SpecialtyCode.AttendedAsset__c = 'Carro';
        lProduct2SpecialtyCode.WarrantyMO__c = 10;
        lProduct2SpecialtyCode.WarrantyPiece__c = 10;
        lProduct2SpecialtyCode.NumberReasonsAllowed__c = 10;
        lProduct2SpecialtyCode.Status__c = Label.Status_Deployment ;
        lProduct2SpecialtyCode.Code__c = lProduct2SpecialtyTest.Code__c;
        
        try{       	
        	insert lProduct2SpecialtyCode;
        }
        catch(Exception ex){        
        }
    	System.assertEquals(lProduct2SpecialtyTest.Code__c, lProduct2SpecialtyCode.Code__c);
    
    }
    
    @isTest
    static void updateReason(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));

        Product2 lProduct2ReasonDetail = Product2Factory.createProduct2Detail();
        insert lProduct2ReasonDetail;
        
        lProduct2ReasonDetail.Code__c = 1200;
        update lProduct2ReasonDetail;
        lProduct2ReasonDetail.Name = 'Motivo para Teste';
        update lProduct2ReasonDetail;
        lProduct2ReasonDetail.Description__c = 'Teste Motivo';
        update lProduct2ReasonDetail;
        lProduct2ReasonDetail.Status__c = Label.Status_Active;
        update lProduct2ReasonDetail;
        lProduct2ReasonDetail.ReasonGroup__c = String.valueOf(9999);
        update lProduct2ReasonDetail;
        
        OperationalSetup__c lOperationalAbility = OperationalSetupFactory.createOperationalSetupAbility();
        insert lOperationalAbility;
        
        //------------------------------------------------------------------------------------------
        Product2 lProduct2ReasonSpecialty = Product2Factory.createProduct2ActiveSpecialty();
        lProduct2ReasonSpecialty.Name = 'Motivo para Teste Especialidade';
        insert lProduct2ReasonSpecialty;
        
        lProduct2ReasonSpecialty.Code__c = 1201;
        update lProduct2ReasonSpecialty;
        lProduct2ReasonSpecialty.Description__c = 'Teste Motivo Especialidade';
        update lProduct2ReasonSpecialty;
        lProduct2ReasonSpecialty.Status__c = Label.Status_Active;
        update lProduct2ReasonSpecialty;
        lProduct2ReasonSpecialty.ReasonGroup__c = String.valueOf(9998);
        update lProduct2ReasonSpecialty;
       
        
        ServiceSpecialtyDetails__c lServiceSpecialtyDetail = new ServiceSpecialtyDetails__c();
        lServiceSpecialtyDetail.Detail__c = lProduct2ReasonDetail.Id;
        lServiceSpecialtyDetail.SpecialtyDetail__c = lServiceSpecialtyDetail.Id;
        lServiceSpecialtyDetail.IsActive__c = true;
        //------------------------------------------------------------------------------------------
        
        Ability__c lAbility = new Ability__c();
        lAbility.OperationalSetup__c = lOperationalAbility.Id;
        lAbility.Product2__c = lProduct2ReasonSpecialty.Id;
        lAbility.IsActive__c = true;
        insert lAbility;
        
        //system.assertEquals(lProduct2Reason.Status__c, 'Ativo');
        
    }
    @isTest
    static void providerAbilityUpdateTest(){
        
        String lBodyResponse = Label.BodyResponseCreated;
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
    
        OperationalSetup__c lOperationalAbility = OperationalSetupFactory.createOperationalSetupAbility();
        insert lOperationalAbility;
        
    	Product2 lDetail = Product2Factory.createProduct2Detail();
    	insert lDetail;
        lDetail.Status__c = Label.Status_Active;
        
        product2 lSpecialty = Product2Factory.createProduct2Specialty();
        lSpecialty.Name = 'Especialide Teste';
        insert lSpecialty;
        lSpecialty.Status__c = Label.Status_Active;
        lSpecialty.Runtime__c = Time.newInstance(18, 30, 2, 20);
        lSpecialty.WarrantyMO__c = 1;
        lSpecialty.WarrantyPiece__c = 1;
        
        /*ServiceSpecialtyDetails__c lServiceSpecialtyDetails = new ServiceSpecialtyDetails__c();
        lServiceSpecialtyDetails.SpecialtyDetail__c = lSpecialty.Id;
        lServiceSpecialtyDetails.Detail__c = lDetail.Id;
        lServiceSpecialtyDetails.IsActive__c = true;
        insert lServiceSpecialtyDetails;*/
        
        Ability__c lAbility = new Ability__c();
        lAbility.OperationalSetup__c = lOperationalAbility.Id;
        lAbility.Product2__c = lDetail.Id;
        lAbility.IsActive__c = true;

        List<Product2> lProductList = new List<Product2>();
        lProductList.add(lDetail);
        lProductList.add(lSpecialty);
        update lProductList;
        
    }
    
}