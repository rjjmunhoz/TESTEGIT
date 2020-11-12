/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-08      Mariana Ribeiro         class created 
**************************************************************************************************************/
@isTest
public class ServiceSpecialtyDetailsHandler_tst {
    @isTest
    static void SpecialtyServiceJunctionTest(){
        
        String lReturnMsg;//Mensagem de erro
		
        Product2 lSpecialty = Product2Factory.createProduct2Specialty();
        insert lSpecialty;
        
        Product2 lService = Product2Factory.createProduct2Service();
        insert lService;
        
        ServiceSpecialtyDetails__c lJunction = new ServiceSpecialtyDetails__c();
        lJunction.Specialty__c	 = lSpecialty.Id;
        lJunction.Service__c = lService.Id;
        insert lJunction;
        system.debug('Teste: ' + lJunction.Id);

        try{
            update lJunction;
        }
        catch(Exception e){
           system.debug('Erro try/Catch: ');
            lReturnMsg = 'Insert failed: ' + e.getMessage();
        }
        
        ServiceSpecialtyDetails__c lJunction2 = new ServiceSpecialtyDetails__c();
        lJunction2.Specialty__c	 = lSpecialty.Id;
        lJunction2.Service__c = lService.Id;
        Test.startTest();
        	try{
            	insert lJunction2;
        	}
        	catch(Exception e){
            	lReturnMsg = 'Insert failed: ' + e.getMessage();
        	}
        Test.stopTest();
    }
    
    @isTest
    static void SpecialtyDetailJunctionTest(){
        
        String lReturnMsg;//Mensagem de erro
		
        Product2 lSpecialty = Product2Factory.createProduct2Specialty();
        lSpecialty.Name = 'Especialidade 003';
        insert lSpecialty;
        
        Product2 lDetail = Product2Factory.createProduct2Detail();
        lDetail.Name = 'Motivo 003';
        insert lDetail;
        
        
        ServiceSpecialtyDetails__c lJunction = new ServiceSpecialtyDetails__c();
        lJunction.SpecialtyDetail__c = lSpecialty.Id;
        lJunction.Detail__c = lDetail.Id;
        insert lJunction;
        system.debug('Teste: ' + lJunction.Id);

        try{
            update lJunction;
        }
        catch(Exception e){
           system.debug('Erro try/Catch: ');
            lReturnMsg = 'Insert failed: ' + e.getMessage();
        }
        
        ServiceSpecialtyDetails__c lJunction2 = new ServiceSpecialtyDetails__c();
        lJunction2.SpecialtyDetail__c = lSpecialty.Id;
        lJunction2.Detail__c = lDetail.Id;
        Test.startTest();
        	try{
            	insert lJunction2;
        	}
        	catch(Exception e){
            	lReturnMsg = 'Insert failed: ' + e.getMessage();
        	}
        Test.stopTest();
    }
    
    @TestSetup
    static void SpecialtyDetail(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        Product2 lSpecialty = Product2Factory.createProduct2Specialty();
        lSpecialty.Name = 'Especialidade 002';
        lSpecialty.Status__c = 'Ativo';
        insert lSpecialty;
        
        Product2 lDetail = Product2Factory.createProduct2Detail();
        lSpecialty.Name = 'Motivo 002';
        lDetail.Status__c = 'Ativo';
        insert lDetail;
        
        ServiceSpecialtyDetails__c lJunction = new ServiceSpecialtyDetails__c();
        lJunction.SpecialtyDetail__c = lSpecialty.Id;
        lJunction.Detail__c = lDetail.Id;
        insert lJunction;
    }
    
    @isTest
    static void legacyIntegration(){
        
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
        
        List<Product2> lRecordList = [SELECT Id FROM Product2 ORDER BY RecordType.DeveloperName DESC];
        
        String lReturnMsg;//Mensagem de erro
        
        ServiceSpecialtyDetails__c lJunction = new ServiceSpecialtyDetails__c();
        lJunction.SpecialtyDetail__c = lRecordList[0].Id;
        lJunction.Detail__c = lRecordList[1].Id;
        
        Test.startTest();
        	try{
            	insert lJunction;
                lJunction.IsActive__c = false;
        	}
        	catch(Exception e){
            	lReturnMsg = 'Insert failed: ' + e.getMessage();
        	}
        Test.stopTest();
    }
    
    @isTest
    static void validateJunction(){
         String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));
       
        List<Product2> lRecordList = [SELECT Id FROM Product2 ORDER BY RecordType.DeveloperName DESC];
        
        String lReturnMsg;//Mensagem de erro
        
        List<ServiceSpecialtyDetails__c> lJunctionLst = [SELECT Id FROM ServiceSpecialtyDetails__c];
        lJunctionLst[0].IsActive__c = false;
        Test.startTest();
        	try{
            	update lJunctionLst;
        	}
        	catch(Exception e){
            	lReturnMsg = 'Insert failed: ' + e.getMessage();
        	}
        Test.stopTest();
    }
    
    @isTest
    static void synchronizeRescuerTest(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));

    }
    
}