/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Controlador do component de criação de Requisitos da POC do fluxo de Análise de Portfólio
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-11-04      Jean Sganzerla          class created 
**************************************************************************************************************/
public class POCRequirements_ctr {

    private static final Id POC_REQUIREMENTS_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('POCRequirements').getRecordTypeId();

    @AuraEnabled
    public static String createPOCRequeriment(String aPOCRequirements, String aExpectedOutcome, String aRecordId){
        
        String lReturnMsg;
        System.debug('record id '+aRecordId);
        Case lCaseToInsert = new Case();
        lCaseToInsert.RecordTypeId = POC_REQUIREMENTS_RECTYPE;
        lCaseToInsert.POCRequirements__c = aPOCRequirements;
        lCaseToInsert.ExpectedOutcome__c = aExpectedOutcome;
        lCaseToInsert.ParentId = Id.valueOf(aRecordId);
        lCaseToInsert.Status = 'New';
        lCaseToInsert.Subject = 'Objetivo da POC';

        try{
            Insert lCaseToInsert;
            lReturnMsg = 'Success';
        }
        catch(Exception e){
            lReturnMsg = 'Insert failed: ' + e.getMessage();
        }
        return lReturnMsg;
    }    
}