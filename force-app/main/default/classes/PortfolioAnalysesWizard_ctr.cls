/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Controlador do component do Wizard de criação de novo serviço
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-11-06      Jean Sganzerla          class created 
**************************************************************************************************************/
public class PortfolioAnalysesWizard_ctr {    

    @AuraEnabled
    public static ValueWrapper searchParameters(String aStatus, String aRecordType){
        
        List<WizardFields__mdt> lWizardFields = [SELECT Fields__c, HelpText__c FROM WizardFields__mdt WHERE MasterLabel = :aStatus AND RecordType__c = :aRecordType AND IsActive__c = true];
        if(lWizardFields.isEmpty()) return null;

        ValueWrapper lWrapperValue = new ValueWrapper();
        lWrapperValue.lHelpText = lWizardFields[0].HelpText__c != null? lWizardFields[0].HelpText__c :null;
        lWrapperValue.lFields = lWizardFields[0].Fields__c != null? lWizardFields[0].Fields__c.replace(' ', '').split(',') :null;
        return lWrapperValue;
    }

    public class ValueWrapper{
        @AuraEnabled public String lHelpText;
        @AuraEnabled public List<String> lFields;
    }
}