/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para gerar a cobertura das classes IntegrationHandler_cls
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0     2019-03-17      Matheus Branco          class created 
**************************************************************************************************************/

@isTest
public class PortfolioAnalysesWizard_tst {
    @TestSetup
    static void makeData(){
        Product2 lService = (Product2) new Product2Factory.Service().createRecord();
        Case lPortfolioAnalysis = (Case) new CaseFactory.PortfolioAnalysis(lService).createRecord();
        
    }
    @isTest
    static void metadataCreate(){       
        Case lPortfolioAnalysis = [SELECT Id, Status FROM Case LIMIT 1];
        System.assertEquals(lPortfolioAnalysis.Status, Label.Status_PortfolioAnalysis);

        WizardFields__mdt lWizardFields = [SELECT Fields__c, HelpText__c FROM WizardFields__mdt WHERE MasterLabel = 'Análise de Portfólio' AND RecordType__c = 'PortfolioAnalysis' AND IsActive__c = true];

        Test.startTest();

        PortfolioAnalysesWizard_ctr.searchParameters(Label.Status_PortfolioAnalysis, Label.PortfolioAnalysisRecordType);
        
        Test.stopTest();
    } 
}