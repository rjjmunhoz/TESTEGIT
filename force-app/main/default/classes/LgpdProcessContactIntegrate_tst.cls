@isTest
public with sharing class LgpdProcessContactIntegrate_tst {

    private static final String OTHER_DISCOUNTS_RECTYPE = SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('OtherDiscounts').getRecordTypeId();

    @TestSetup
    static void makeData(){        
        Contact lContact = ContactFactory.createContactBaseEmployee();
        lContact.RG__c = '943761258';
        lContact.CPF__c = '76194385200';
        lContact.PHONE= '1149996532';
        lContact.Zip__c = '05544656';
        lContact.Email = 'teste@testeporto.com';
        lContact.Status__c = 'Ativo';
        lContact.LgpdStatus__c = 'P';
        lContact.PesCod__c = 12345;
        lContact.LgpdTicket__c = 54321;
        lContact.Role__c = 'Administrativo';
        insert lContact;
    }

    @isTest 
    static void GenerateDiscountOrderPaymentPortoSeg_Success(){     
        
        WebserviceConfiguration__mdt lToken = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lLgpdForget = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.LgpdForget];

        String lStringToken = lToken.EndPoint__c;
        String llLgpdForgetEndpoint = lLgpdForget.EndPoint__c;
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(lStringToken,'Token');
        multimock.setStaticResource(llLgpdForgetEndpoint,'MockAWSSuccess');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.setMock(HttpCalloutMock.class, multimock);

        Contact lContactToIntegrateLgpd = [SELECT Id, LgpdStatus__c, PesCod__c, LgpdTicket__c FROM Contact LIMIT 1];
        
        System.assert(lContactToIntegrateLgpd.LgpdStatus__c != null &&  lContactToIntegrateLgpd.PesCod__c != null && lContactToIntegrateLgpd.LgpdTicket__c != null, 'Erro ao criar o contato sem dados de pessoa para esquecimento!');  

        Test.startTest();            
            LgpdProcessContactIntegrate_bch lLgpdProcessContactIntegrate = new LgpdProcessContactIntegrate_bch(new Set<Id>{lContactToIntegrateLgpd.Id});
            Database.executeBatch(lLgpdProcessContactIntegrate);
        Test.stopTest();

        lContactToIntegrateLgpd = [SELECT Id, LgpdStatus__c, PesCod__c, LgpdTicket__c FROM Contact LIMIT 1];
        
        System.assert(lContactToIntegrateLgpd.LgpdStatus__c == null && lContactToIntegrateLgpd.PesCod__c == null && lContactToIntegrateLgpd.LgpdTicket__c == null, 'Erro ao integrar o contato na LGPD!');  
    }

    @isTest 
    static void GenerateDiscountOrderPaymentPortoSeg_Error404(){     
        
        WebserviceConfiguration__mdt lToken = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'TokenAWS'];
        WebserviceConfiguration__mdt lLgpdForget = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.LgpdForget];

        String lStringToken = lToken.EndPoint__c;
        String llLgpdForgetEndpoint = lLgpdForget.EndPoint__c;
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(lStringToken,'Token');
        multimock.setStaticResource(llLgpdForgetEndpoint,'MockAWSSuccess');
        multimock.setStatusCode(404);
        multimock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.setMock(HttpCalloutMock.class, multimock);

        Contact lContactToIntegrateLgpd = [SELECT Id, LgpdStatus__c, PesCod__c, LgpdTicket__c FROM Contact LIMIT 1];
        
        System.assert(lContactToIntegrateLgpd.LgpdStatus__c != null && lContactToIntegrateLgpd.PesCod__c != null && lContactToIntegrateLgpd.LgpdTicket__c != null, 'Erro ao criar o contato sem dados de pessoa para esquecimento!');  

        Test.startTest();            
            LgpdProcessContactIntegrate_bch lLgpdProcessContactIntegrate = new LgpdProcessContactIntegrate_bch(new Set<Id>{lContactToIntegrateLgpd.Id});
            Database.executeBatch(lLgpdProcessContactIntegrate);
        Test.stopTest();
        
        System.assert([SELECT Id FROM Case].size() > 0, 'Erro ao criar caso de erro ao integrar com o retorno do processo com a LGPD!');  
    }
}