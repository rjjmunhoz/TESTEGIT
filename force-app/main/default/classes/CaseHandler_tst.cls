/**************************************************************************************************************
* Globant Brasil
* @author        	Igor Novaes (igor.novaes@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para gerar a cobertura das classes CaseHandler e CreateChildrenCaseHandler
*
* Changes (Version)--
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0     2019-11-21      Igor Novaes             class created 
            1.1     2020-02-10      Matheus Branco          class update to coverage
**************************************************************************************************************/

@isTest
public class giCaseHandler_tst { 

    private static final Id PORTFOLIO_ANALYSIS_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PortfolioAnalysis').getRecordTypeId();
    
    @TestSetup
    static void makeData(){
        Account lProvider = (Account) new AccountFactory.Provider().createRecord();
        Entitlement lEntitlement = new Entitlement();
        lEntitlement.Name = 'Tempo de resolução Caso';
        lEntitlement.AccountId = lProvider.Id;
        insert lEntitlement;

        Product2 lService = (Product2) new Product2Factory.Service().createRecord();
        Case lPortfolioAnalysis = (Case) new CaseFactory.PortfolioAnalysis(lService).createRecord();
        Case lMagnificationService = (Case) new CaseFactory.ServiceMagnification(lService).createRecord();
        Case lRemoveService = (Case) new CaseFactory.RemoveService(lService).createRecord();
    	Case lPrototyping = CaseFactory.createCasePrototyping();
        insert lPrototyping;
    }
    
    @isTest
    static void implantedPrototypingTest(){
        User lUser = UserFactory.createUser();
        insert lUser;
        Case lPrototyping = [SELECT Id, Status FROM Case WHERE RecordType.DeveloperName = 'Prototyping' LIMIT 1];
        System.runAs(lUser){
            lPrototyping.Status = 'Análise de Prototipação';
            lPrototyping.OwnerId = lUser.Id;
            lPrototyping.TriggeredAreas__c = 'Cliente Interno;Eficiência operacional;Escola;Gestão de custos e riscos;Informações gerenciais;Monitoria da qualidade;Projetos e soluções tecnológicas;Relacionamento;Seleção;Sustentação;Gestão de insumos;Planejamento;Gestão financeira;SAC';
            lPrototyping.Assignments__c = 'Para essas áreas necessário atualizar valores';
            update lPrototyping;
            
            lPrototyping.Status = 'POC';
            lPrototyping.AmountServiceAnalyzed__c = 2;
			lPrototyping.QRAsQuantity__c = 3;
            update lPrototyping;
            
            lPrototyping.Status = 'Parecer Final';
            lPrototyping.SeemPrototyping__c = 'Viável';
            lPrototyping.Note__c = 'teste';
            update lPrototyping;
            
			lPrototyping.Status = 'closed';
            update lPrototyping;            
        }
    }
    
    @isTest
    static void implantedPortfolioAnalysisTest(){
        User lUser = UserFactory.createUser();
        //User lUser = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do Sistema' LIMIT 1];
        Case lPortfolioAnalysis = [SELECT Id, Status FROM Case 
                                  WHERE RecordType.DeveloperName = 'PortfolioAnalysis' LIMIT 1];
        System.assertEquals(lPortfolioAnalysis.Status, 'Análise de Portfólio');

        Test.startTest();
        System.runAs(lUser){
            lPortfolioAnalysis.Status = 'Análise do Laboratório';
            lPortfolioAnalysis.OwnerId = lUser.Id;
            update lPortfolioAnalysis;
            
            try{
                lPortfolioAnalysis.Status = 'Análise de Equipamento';
                update lPortfolioAnalysis;                
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('É necessário criar ao menos um registro de "Objetivo da POC"') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);    
            }

            Case lPocRequirement = (Case) new CaseFactory.PocRequirements(lPortfolioAnalysis).createRecord();            
            
            lPortfolioAnalysis.Status = 'Análise de Equipamento';
            update lPortfolioAnalysis;

            lPortfolioAnalysis.Status = 'Requisitos Operacionais';
            lPortfolioAnalysis.Specialty__c = 'Novo(a)';
            lPortfolioAnalysis.SpecialtyDescription__c = 'Nova especialidade';
            update lPortfolioAnalysis;

            lPortfolioAnalysis.Status = 'Análise Operacional';
            update lPortfolioAnalysis;

            try{
                lPortfolioAnalysis.Status = 'Alinhar Execução';
                update lPortfolioAnalysis;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Favor aguardar as demais áreas da "Análise Operacional" finalizarem suas tarefas.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }

            Case lProjectionAndSizing = [SELECT ProjectedAnnualAmountServices__c, InitialTerm__c, FinalTerm__c, ManyResourcesNeeded__c 
                                        FROM Case WHERE ParentId = :lPortfolioAnalysis.Id AND RecordType.DeveloperName = 'ProjectionAndSizingService'];
            lProjectionAndSizing.OwnerId = lUser.Id;
            update lProjectionAndSizing;
            lProjectionAndSizing.ProjectedAnnualAmountServices__c = 123;
            lProjectionAndSizing.InitialTerm__c = Date.newInstance(2020, 12, 12);
            lProjectionAndSizing.FinalTerm__c = Date.newInstance(2020, 12, 13);
            lProjectionAndSizing.ManyResourcesNeeded__c = 123;
            lProjectionAndSizing.Status = 'Dimensionamento de Serviços';
            update lProjectionAndSizing;
            lProjectionAndSizing.Status = 'Closed';           
            update lProjectionAndSizing;
            
            Case lServicePricing = [SELECT HowMuch__c, Term__c, DescriptionReasonPricing__c
                                   FROM Case WHERE ParentId = :lPortfolioAnalysis.Id AND RecordType.DeveloperName = 'ServicePricing'];
            lServicePricing.OwnerId = lUser.Id;
            update lServicePricing;
            lServicePricing.HowMuch__c = 123.00;
            lServicePricing.Term__c = '30 dias';
            lServicePricing.DescriptionReasonPricing__c = 'Descrição';
            update lServicePricing;
            lServicePricing.Status = 'Closed';
            update lServicePricing;
            
            Case lContractReview = [SELECT Term__c, ContractNote__c
                                   FROM Case WHERE ParentId = :lPortfolioAnalysis.Id AND RecordType.DeveloperName = 'ContractReview'];
            lContractReview.OwnerId = lUser.Id;
            update lContractReview;
            lContractReview.Term__c = '30 dias';
            lContractReview.ContractNote__c = 'Observação';
            update lContractReview;
            lContractReview.Status = 'Closed';
            update lContractReview;
            
            Case lTrainingAnalysis = [SELECT Term__c, EstimatedValue__c 
                                     FROM Case WHERE ParentId = :lPortfolioAnalysis.Id AND RecordType.DeveloperName = 'TrainingAnalysis'];
            lTrainingAnalysis.OwnerId = lUser.Id;
            update lTrainingAnalysis;
            lTrainingAnalysis.Term__c = '30 dias';
            lTrainingAnalysis.EstimatedValue__c = 123.00;
            update lTrainingAnalysis;
            lTrainingAnalysis.Status = 'Closed';
            update lTrainingAnalysis;

            try{
                lPortfolioAnalysis.Status = 'Executar';
                update lPortfolioAnalysis;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Para avançar o Status é necessário criar um Compromisso') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }

            Event lEvent = new Event();
            lEvent.Subject = 'Alinhar execução';
            lEvent.Description = 'Descrição';
            lEvent.startDateTime = DateTime.newInstance(2020, 1, 31, 7, 8, 16);
            lEvent.EndDateTime = DateTime.newInstance(2020, 2, 10, 7, 8, 16);
            lEvent.WhatId = lPortfolioAnalysis.Id;
            insert lEvent;

            try{
                lPortfolioAnalysis.Status = 'Executar';
                update lPortfolioAnalysis;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Para avançar o Status é necessário anexar a ata da reunião') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }

            ContentDocumentLink lDocLink = CaseFactory.createAttachment(lPortfolioAnalysis);
            insert lDocLink;       

            lPortfolioAnalysis.Status = 'Executar';
            update lPortfolioAnalysis;

            lPortfolioAnalysis.Status = 'Avaliar Resultado';
            update lPortfolioAnalysis;

            try{
            	lPortfolioAnalysis.Status = 'Parecer Final';
            	update lPortfolioAnalysis;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Para avançar o Status é necessário preencher o Resultado da POC') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            
            lPocRequirement.POCOutcome__c = 'Resultado da POC';
            update lPocRequirement;
            
            lPortfolioAnalysis.Status = 'Parecer Final';
            update lPortfolioAnalysis;
            
            lPortfolioAnalysis.Status = 'Em implantação';
            update lPortfolioAnalysis;

            List<Case> lCaseUpdateLst = new List<Case>();
            List<Case> lCaseUpdateSecondLst = new List<Case>();
            List<Case> lChildrenCases = [SELECT Description FROM Case 
                                        WHERE ParentId = :lPortfolioAnalysis.Id AND RecordType.DeveloperName = 'ServiceDeployment'];
            for(Case lCase : lChildrenCases){
                lCase.OwnerId = lUser.Id;
                lCase.Term__c = 'Imediato';
                lCase.Description = 'Descrição';
                lCase.Status = 'Em andamento';
                lCaseUpdateLst.add(lCase);
            } 
            	update lCaseUpdateLst;

            try{
                lPortfolioAnalysis.Status = 'Definição de Recursos';
                update lPortfolioAnalysis;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Favor aguardar as demais áreas da "Implantação" finalizarem suas tarefas.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }

            for(Case lCase : lChildrenCases){
                lCase.Status = 'Concluído';
                lCaseUpdateSecondLst.add(lCase);
            }
            update lCaseUpdateSecondLst;

            lPortfolioAnalysis.Status = 'Implantado';
            update lPortfolioAnalysis;
        }
        Test.stopTest();
    }

    @isTest
    static void magnificatedServiceMagnificationTest(){
        User lUser = UserFactory.createUser();
        //User lUser = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do Sistema' LIMIT 1];
        Case lMagnificationService = [SELECT Status FROM Case WHERE RecordType.DeveloperName = 'ServiceMagnification' LIMIT 1];
        System.assertEquals(lMagnificationService.Status, 'Análise de Ampliação');

        Test.startTest();
        System.runAs(lUser){
            lMagnificationService.OwnerId = lUser.Id;
            lMagnificationService.Status = 'Análise de Recursos';
            update lMagnificationService;

            lMagnificationService.Status = 'Precificação';
            update lMagnificationService;

            Case lContractReview = [SELECT Term__c, ContractNote__c FROM Case 
                                   WHERE RecordType.DeveloperName = 'ContractReview' AND ParentId = :lMagnificationService.Id];
            lContractReview.OwnerId = lUser.Id;
            update lContractReview;
            lContractReview.Term__c = '5 dias';
            lContractReview.ContractNote__c = 'Descrição do contrato';
            update lContractReview;

            Case lServicePricing = [SELECT HowMuch__c, Term__c, DescriptionReasonPricing__c FROM Case
                                   WHERE RecordType.DeveloperName = 'ServicePricing' AND ParentId = :lMagnificationService.Id];
            lServicePricing.OwnerId = lUser.Id;
            update lServicePricing;
            lServicePricing.HowMuch__c = 123.00;
            lServicePricing.Term__c = '10 dias';
            lServicePricing.DescriptionReasonPricing__c = 'Descrição do motivo';
            update lServicePricing;

            try{
                lMagnificationService.Status = 'Viabilidade';
                update lMagnificationService;
            } 
            catch(Exception ex) {
                Boolean expectedExceptionThrown = ex.getMessage().contains('Favor aguardar as demais áreas da "Precificação" finalizarem suas tarefas.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }

            lContractReview.Status = 'Closed';
            update lContractReview;

            lServicePricing.Status = 'Closed';
            update lServicePricing;
        }
        Test.stopTest();
    }

    @isTest
    static void removedRemoveServiceTest(){
        User lUser = UserFactory.createUser();
        //User lUser = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do Sistema' LIMIT 1];
        Case lRemoveService = [SELECT Status FROM Case WHERE RecordType.DeveloperName = 'RemoveService' LIMIT 1];
        System.assertEquals(lRemoveService.Status, 'Análise de Retirada');

        Test.startTest();
        System.runAs(lUser){
            lRemoveService.OwnerId = lUser.Id;
            lRemoveService.Status = 'Impacto Operacional';
            update lRemoveService;

            List<Case> lChildrenList = [SELECT Term__c, ImpactGenerated__c, DeadlineExecution__c FROM Case 
                                       WHERE ParentId = :lRemoveService.Id AND RecordType.DeveloperName = 'OperationalImpact'];
            System.debug('### lista de filhos: ' + lChildrenList);
            for(Case lCase : lChildrenList){
                lCase.OwnerId = lUser.Id;
                lCase.ImpactGenerated__c = 'Impacto gerado';
                lCase.DeadlineExecution__c = 'Prazo para execução';
                lCase.Term__c = '10 dias';
            }
            update lChildrenList;
            
            try{
                lRemoveService.Status = 'Parecer Final';
                update lRemoveService;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Favor aguardar as demais áreas do "Impacto Operacional" finalizarem suas tarefas.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }

            for(Case lCase : lChildrenList){
                lCase.Status = 'Concluído';
            }
            update lChildrenList;
        }
        Test.stopTest();
    }

    @isTest 
    static void operationalRequirementsTest01(){
        User lUser = UserFactory.createUser();
        //User lUser = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do Sistema' LIMIT 1];
        Case lPortfolioAnalysis = [SELECT Status, Ability__c, Problem__c FROM Case 
                                  WHERE RecordType.DeveloperName = 'PortfolioAnalysis' LIMIT 1];
        System.assertEquals(lPortfolioAnalysis.Status, 'Análise de Portfólio');

        Test.startTest();
        System.runAs(lUser){
            lPortfolioAnalysis.OwnerId = lUser.Id;
            lPortfolioAnalysis.Status = 'Análise do Laboratório';
            update lPortfolioAnalysis;

            Case lPocRequirement = (Case) new CaseFactory.PocRequirements(lPortfolioAnalysis).createRecord();   

            lPortfolioAnalysis.Status = 'Análise de Equipamento';
            update lPortfolioAnalysis;

            lPortfolioAnalysis.Status = 'Requisitos Operacionais';
            lPortfolioAnalysis.Ability__c = 'Existente';
            lPortfolioAnalysis.AbilityDescription__c = 'Habilidade';
            lPortfolioAnalysis.Problem__c = 'Existente';
            lPortfolioAnalysis.ProblemDescription__c = 'Problema';
            lPortfolioAnalysis.Status = 'Requisitos Operacionais';
            update lPortfolioAnalysis;

            lPortfolioAnalysis.Status = 'Análise Operacional';
            update lPortfolioAnalysis;
        }
        Test.stopTest();
    }

    @isTest 
    static void operationalRequirementsTest02(){
        User lUser = UserFactory.createUser();
        //User lUser = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do Sistema' LIMIT 1];
        Case lPortfolioAnalysis = [SELECT Status, Ability__c, Problem__c FROM Case 
                                  WHERE RecordType.DeveloperName = 'PortfolioAnalysis' LIMIT 1];
        System.assertEquals(lPortfolioAnalysis.Status, 'Análise de Portfólio');

        Test.startTest();
        System.runAs(lUser){
            lPortfolioAnalysis.OwnerId = lUser.Id;
            lPortfolioAnalysis.Status = 'Análise do Laboratório';
            update lPortfolioAnalysis;

            Case lPocRequirement = (Case) new CaseFactory.PocRequirements(lPortfolioAnalysis).createRecord();   

            lPortfolioAnalysis.Status = 'Análise de Equipamento';
            update lPortfolioAnalysis;

            lPortfolioAnalysis.Status = 'Requisitos Operacionais';
            lPortfolioAnalysis.Ability__c = 'Existente';
            lPortfolioAnalysis.AbilityDescription__c = 'Habilidade';
            update lPortfolioAnalysis;

            lPortfolioAnalysis.Status = 'Análise Operacional';
            update lPortfolioAnalysis;
        }
        Test.stopTest();
    }

    @isTest 
    static void operationalRequirementsTest03(){
        User lUser = UserFactory.createUser();
        //User lUser = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do Sistema' LIMIT 1];
        Case lPortfolioAnalysis = [SELECT Status, Ability__c, Problem__c FROM Case 
                                  WHERE RecordType.DeveloperName = 'PortfolioAnalysis' LIMIT 1];
        System.assertEquals(lPortfolioAnalysis.Status, 'Análise de Portfólio');

        Test.startTest();
        System.runAs(lUser){
            lPortfolioAnalysis.OwnerId = lUser.Id;
            lPortfolioAnalysis.Status = 'Análise do Laboratório';
            update lPortfolioAnalysis;

            Case lPocRequirement = (Case) new CaseFactory.PocRequirements(lPortfolioAnalysis).createRecord();   

            lPortfolioAnalysis.Status = 'Análise de Equipamento';
            update lPortfolioAnalysis;

            lPortfolioAnalysis.Status = 'Requisitos Operacionais';
            lPortfolioAnalysis.Problem__c = 'Existente';
            lPortfolioAnalysis.ProblemDescription__c = 'Problema';
            update lPortfolioAnalysis;

            lPortfolioAnalysis.Status = 'Análise Operacional';
            update lPortfolioAnalysis;
        }
        Test.stopTest();
    }

    @isTest 
    static void operationalRequirementsTest04(){
        User lUser = UserFactory.createUser();
        //User lUser = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do Sistema' LIMIT 1];
        Case lPortfolioAnalysis = [SELECT Status, Ability__c, Problem__c FROM Case 
                                  WHERE RecordType.DeveloperName = 'PortfolioAnalysis' LIMIT 1];
        System.assertEquals(lPortfolioAnalysis.Status, 'Análise de Portfólio');

        Test.startTest();
        System.runAs(lUser){
            lPortfolioAnalysis.OwnerId = lUser.Id;
            lPortfolioAnalysis.Status = 'Análise do Laboratório';
            update lPortfolioAnalysis;

            Case lPocRequirement = (Case) new CaseFactory.PocRequirements(lPortfolioAnalysis).createRecord(); 

            lPortfolioAnalysis.Status = 'Análise de Equipamento';
            update lPortfolioAnalysis;  

            lPortfolioAnalysis.Status = 'Requisitos Operacionais';
            lPortfolioAnalysis.Parts__c = 'Existente';
            lPortfolioAnalysis.PartsDescription__c = 'Peça';
            update lPortfolioAnalysis;

            lPortfolioAnalysis.Status = 'Análise Operacional';
            update lPortfolioAnalysis;
        }
        Test.stopTest();
    }

    @isTest
    public static void duplicateControlTest(){
        Id RemoveServiceRecType = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RemoveService').getRecordTypeId();
        User lUser = UserFactory.createUser();
        insert lUser;
        //User lUser = [SELECT Id FROM User WHERE Profile.Name = 'Administrador do Sistema' LIMIT 1];

        Case lPortfolioAnalysis = [SELECT Id, Status FROM Case WHERE RecordType.DeveloperName = 'PortfolioAnalysis' LIMIT 1];
        System.assertEquals(lPortfolioAnalysis.Status, 'Análise de Portfólio');

        Case lRemoveService = [SELECT Id, Status FROM Case WHERE RecordType.DeveloperName = 'RemoveService' LIMIT 1];
        System.assertEquals(lRemoveService.Status, 'Análise de Retirada');

        Product2 lService = [SELECT Id, Status__c FROM Product2 WHERE RecordType.DeveloperName = 'Service' LIMIT 1];
        System.assertEquals(lService.Status__c, 'Em implantação');

        Test.startTest();
        System.runAs(lUser){
            Case lPortfolioAnalysis2 = new Case(Service__c = lService.Id, RecordTypeId = PORTFOLIO_ANALYSIS_RECTYPE);
            try{
                insert lPortfolioAnalysis2;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Este serviço está em processo de implantação ou já foi implantado.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);            
            }

            Case lRemoveService2 = new Case(Service__c = lService.Id, RecordTypeId = RemoveServiceRecType);
            try{
                insert lRemoveService2;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown = ex.getMessage().contains('Este serviço não faz mais parte do nosso portfólio de serviços ou está em processo de retirada.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true); 
            }
        }
        Test.stopTest();
    }   
}