@isTest
public class POCRequirements_tst {
    
    @TestSetup
    static void makeData(){
        Product2 lService = (Product2) new Product2Factory.Service().createRecord();
        Case lPortfolioAnalysis = (Case) new CaseFactory.PortfolioAnalysis(lService).createRecord();
    }
    
    @isTest
    static void recordTypeTest(){
        Case lCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'PortfolioAnalysis' LIMIT 1];
        POCRequirements_ctr.createPOCRequeriment('POCRequirements', 'Resultado da POC', lCase.Id);
    }
}