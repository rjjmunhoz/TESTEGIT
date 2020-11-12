/**************************************************************************************************************
 * Avanxo Brasil
 * @author           Eduardo Costa (eduardo.borges@globant.com)
 * Project:          Porto Socorro 
 * Description:      Scheduler/Batch que retorna para a integração o sucesso ou não da anonimização do contato
 *
 * Changes (Version)
 * -------------------------------------
 *           No.     Date            Author                  Description     
 *           -----   ----------      --------------------    ---------------   
 * @version   1.0    2020-08-25      Eduardo Costa           class created 
 **************************************************************************************************************/
global class LgpdProcessContactIntegrate_bch implements Database.Batchable < SObject > , Database.Stateful, Database.AllowsCallouts {

    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();
    
    Set<Id> fContactErrorToUpdate;

    global LgpdProcessContactIntegrate_bch(Set<Id> aContactErrorToUpdate) {
        this.fContactErrorToUpdate = aContactErrorToUpdate;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, PesCod__c, LgpdTicket__c, LgpdStatus__c, IsDeleted 
            FROM Contact
            WHERE Id IN :fContactErrorToUpdate ALL ROWS
        ]);
    }

    global void execute(Database.BatchableContext BC, List < Contact > aContactLst) {

        LgpdFields__mdt lLgpdStatus = [SELECT FieldValue__c FROM LgpdFields__mdt WHERE FieldName__c = 'LgpdStatus__c' AND Object__c = 'Contact' LIMIT 1];
        
        try {   
            List<Case> lCaseToCreateLst = new List<Case>();
            List<Contact> lContactToEmptyRecycleBinLst = new List<Contact>();
            List<Contact> lContactToEraseLgpdFieldsLst = new List<Contact>();
            for (Contact lContact: aContactLst) {
                LgpdForgetWebService lWebServ = new LgpdForgetWebService(lContact, lLgpdStatus.FieldValue__c);
                AWS_API.ResponseWrapper lResult = lWebServ.setLgpdForget();
                if(!lResult.success) {  
                    String lSubject = Label.String_StatusCode + ' ' + String.Valueof(lResult.response.getStatusCode());                          
                    lCaseToCreateLst.add(createSupportCase(lSubject, lContact.Id, Label.FieldValueRescuer, lResult.message));  
                }
                else {
                    if(lContact.IsDeleted) {
                        lContactToEmptyRecycleBinLst.add(lContact);
                    }
                    else {
                        lContact.LgpdTicket__c = null;
                        lContact.LgpdStatus__c = null;
                        lContact.PesCod__c = null;
                        lContactToEraseLgpdFieldsLst.add(lContact);
                    }
                }
            }  
            if (!lCaseToCreateLst.isEmpty()) insert lCaseToCreateLst;   
            // Deleta permanentemente os contatos da lixeira
            //if (!lContactToEmptyRecycleBinLst.isEmpty()) Database.emptyRecycleBin(lContactToEmptyRecycleBinLst);   
            // Apaga os campos da LGPD nos contatos anonimizados
            if (!lContactToEraseLgpdFieldsLst.isEmpty()) update lContactToEraseLgpdFieldsLst;                   
        }
        catch(DmlException e) {
            system.debug('Catch1: ' + e.getMessage());
            //cria caso aqui
            insert createSupportCase(Label.ErrorSubjectLGPD, '', Label.LGPDBatchObject, e.getMessage());
        }
        catch(Exception e) {
            system.debug('Catch2: ' + e.getMessage());
            //cria caso aqui
            insert createSupportCase(Label.ErrorSubjectLGPD, '', Label.LGPDBatchObject, e.getMessage());        
        }
    }

    public Case createSupportCase(String aErrorSubject, String aObjectId, String aObjectName, String aErrorDescription) {
        return new Case(
            Subject = aErrorSubject, 
            Status = Label.String_OnHold , 
            RecordCode__c = aObjectId, 
            Description = aErrorDescription, 
            ObjectType__c = aObjectName, 
            RecordTypeId = SUPPORT_API, 
            Origin = Label.FieldValueIntegrationFailure
        );
    }

    global void finish(Database.BatchableContext BC) {}
}