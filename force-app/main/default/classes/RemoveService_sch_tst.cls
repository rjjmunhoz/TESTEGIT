/**************************************************************************************************************
* Globant Brasil
* @author        	Igor Novaes (igor.novaes@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para gerar a cobertura das classe  RemoveService_sch
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0     2019-12-17      Igor Novaes             class created 
            1.1     2020-02-07      Misael Ribas            class update to coverage
**************************************************************************************************************/

@isTest
public class RemoveService_sch_tst {

    @TestSetup
    static void makeData(){
        Id ServiceRecType = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();

        Product2 lSpecialty = (Product2) new Product2Factory.Specialty().createRecord();
        Product2 lSpecialty2 = (Product2) new Product2Factory.Specialty().cloneRecord();
        lSpecialty2.Name = 'Especialidade 2';
        insert lSpecialty2;

        Product2 lService = Product2Factory.createProduct2Service();
        lService.Name = 'Serviço';
        Insert lService;
        Product2 lService2 = new Product2();
        lService2.Name = 'Serviço 2';
        lService2.RecordTypeId = ServiceRecType;
        lService2.AttendedAsset__c = 'Carro';
        lService2.Description__c = 'Descrição';
        lService2.SpecialtyType__c = 'AUTO';
        lService2.Status__c = 'Em implantação';
        insert lService2;

        Case lRemoveService = (Case) new CaseFactory.RemoveService(lService).createRecord();  
        Case lRemoveService2 =  (Case) new CaseFactory.RemoveService().cloneRecord();  
        lRemoveService2.Justification__c = 'Justificativa 2';
        lRemoveService2.Service__c = lService2.Id;
        insert lRemoveService2;
    }

    @isTest 
    static void testingFactoryLists(){

        String lBodyResponse = Label.BodyResponseCreated;
        test.setMock(HttpCalloutMock.class, new HTTPMockFactory(201,Label.StatusCreated,lBodyResponse));
        
        //User lUser = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do Sistema' LIMIT 1];        
        User lUser = UserFactory.createUser();
        Product2 lService = [SELECT Id FROM Product2 WHERE Name = 'Serviço' AND RecordType.DeveloperName = :Label.ServiceRecordType];
        Product2 lService2 = [SELECT Id FROM Product2 WHERE Name = 'Serviço 2' AND RecordType.DeveloperName = :Label.ServiceRecordType];
        Product2 lSpecialty = [SELECT Id FROM Product2 WHERE Name = 'Especialidade' AND RecordType.DeveloperName = :Label.SpecialtyRecordType];
        Product2 lSpecialty2 = [SELECT Id FROM Product2 WHERE Name = 'Especialidade 2' AND RecordType.DeveloperName = :Label.SpecialtyRecordType];
        Case lRemoveService = [SELECT Id FROM Case WHERE Justification__c = 'Justificativa' AND RecordType.DeveloperName = :Label.RemoveServiceRecordType];
        Case lRemoveService2 = [SELECT Id FROM Case WHERE Justification__c = 'Justificativa 2' AND RecordType.DeveloperName = :Label.RemoveServiceRecordType];

        Id ServiceSpecialtiesRecType = SObjectType.ServiceSpecialtyDetails__c.getRecordTypeInfosByDeveloperName().get(Label.ServiceSpecialtiesRecordType).getRecordTypeId();
        ServiceSpecialtyDetails__c lServiceSpecialty = new ServiceSpecialtyDetails__c(RecordTypeId = ServiceSpecialtiesRecType);
        lServiceSpecialty.Service__c = lService.Id;
        lServiceSpecialty.Specialty__c = lSpecialty.Id;
        insert lServiceSpecialty;  

        ServiceSpecialtyDetails__c lServiceSpecialty2 = new ServiceSpecialtyDetails__c(RecordTypeId = ServiceSpecialtiesRecType);
        lServiceSpecialty2.Service__c = lService.Id;
        lServiceSpecialty2.Specialty__c = lSpecialty2.Id;
        insert lServiceSpecialty2;  

        ServiceSpecialtyDetails__c lServiceSpecialty3 = new ServiceSpecialtyDetails__c(RecordTypeId = ServiceSpecialtiesRecType);
        lServiceSpecialty3.Service__c = lService2.Id;
        lServiceSpecialty3.Specialty__c = lSpecialty.Id;
        insert lServiceSpecialty3;  
        
        System.runAs(lUser){
            lRemoveService.OwnerId = lUser.Id;
            lRemoveService.Status = Label.Status_OperationalImpact;
            update lRemoveService;
            List<Case> lChildrenList = [SELECT Term__c, ImpactGenerated__c, DeadlineExecution__c, Status FROM Case 
                                       WHERE ParentId = :lRemoveService.Id AND RecordType.DeveloperName = :Label.OperationalImpactRercordType];
            for(Case lCase : lChildrenList){
                lCase.OwnerId = lUser.Id;
                lCase.ImpactGenerated__c = 'Impacto gerado';
                lCase.DeadlineExecution__c = 'Prazo para execução';
                lCase.Term__c = Label.String_Immediate;
            }
            update lChildrenList;
            for(Case lCase : lChildrenList){
                if(lCase.Status != Label.Status_Concluded) lCase.Status = Label.Status_Concluded;
            }
            update lChildrenList;
            lRemoveService.Status = Label.Status_FinalOpinion;
            update lRemoveService;
            lRemoveService.ClosureMarketing__c = Date.newInstance(2020, 12, 12);
            lRemoveService.Justification__c = 'Justificativa';
            update lRemoveService; 
            lRemoveService.Status = Label.Status_Withdrawn;
            update lRemoveService;
        }

        Test.startTest();
        RemoveService_sch scheduler = new RemoveService_sch();
        String lSch = '0 0 0 * * ?';
        System.schedule(Label.String_ServiceRemoval, lSch, scheduler);
        Test.stopTest();
    }
}