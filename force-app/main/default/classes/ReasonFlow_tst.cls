/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para cobertura da classe ReasonFlow_ctr
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-06-11      Matheus Branco          class created 
**************************************************************************************************************/

@isTest
public class ReasonFlow_tst {
    @isTest
    static void getSpecialtiesTest(){
        String lBodyResponse = '{'
            +'\"statusCode\": 201,'
            +'\"headers\": null,'
            +'\"multiValueHeaders\": null,'
            +'\"body\": \"{ \'messageId\': \'6b9978f1-95e2-5aee-9be4-2e37b3565dd0\' }\",'
            +'\"isBase64Encoded\": false'
            +'}';
        
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,'Created',lBodyResponse));

        List<List<Product2>> lSpecialtyToReturn = new List<List<Product2>>();
        List<Product2> lSpecialtyToAdd = new List<Product2>();
        Product2 lSpecialty = new Product2();
        Id SpecialtyRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Specialty').getRecordTypeId();
        lSpecialty.Name = 'Especialidade';
        lSpecialty.Status__c = 'Inativo';
        lSpecialty.WarrantyPiece__c = 90;
        lSpecialty.WarrantyMO__c = 90;
        lSpecialty.SpecialtiesGroup__c ='761' ;
        lSpecialty.NumberReasonsAllowed__c = 3;
        lSpecialty.Runtime__c = Time.newInstance(0,0,0,0);
        lSpecialty.SpecialtyType__c = 'AUTO';
        lSpecialty.ScheduleType__c = '3';
        lSpecialty.PreferredScheduleType__c = '1';
        lSpecialty.ScheduledProvider__c = 'Sim';
        lSpecialty.Description__c = 'Teste';
        lSpecialty.RecordTypeId = SpecialtyRecType;
        insert lSpecialty;

        lSpecialtyToAdd = [SELECT Id,Name,Status__c FROM Product2 LIMIT 1];

        lSpecialtyToReturn.add(lSpecialtyToAdd);

        lSpecialty.Status__c = 'Ativo';
        update lSpecialty;

        Product2 lReason = new Product2();
        Id DetailRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Detail').getRecordTypeId();
        lReason.Name = 'Motivo';
        lReason.Status__c = 'Em implantação';
        lReason.ReasonGroup__c = '20';
        lReason.Description__c = 'Teste';
        lReason.RecordTypeId = DetailRecType;
        insert lReason;

        lReason.Status__c = 'Ativo';
        update lReason;

        List<List<String>> lStringParameter = new List<List<String>>();
        ServiceSpecialtyDetails__c lJunction = new ServiceSpecialtyDetails__c();
        lJunction.Detail__c = lReason.Id;
        lJunction.SpecialtyDetail__c = lSpecialty.Id;
        insert lJunction;
        List<String> lStringJunction = new List<String>();
        lStringJunction.add(String.valueOf(lJunction.SpecialtyDetail__c));
        lStringParameter.add(lStringJunction);

        system.assertEquals(ReasonFlow_ctr.getSpecialties(lStringParameter), lSpecialtyToReturn);
    }
}