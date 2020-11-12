/**************************************************************************************************************
 * Globant Brasil
 * @author           Clayton Calvante (clayton.wellington@aglobant.com)
 * Project:          Porto Socorro 
 * Description:      Scheduler/Batch que anoniminiza/exclui as pessoas que querem ter seus dados protegidos(LGPD)
 *
 * Changes (Version)
 * -------------------------------------
 *           No.     Date            Author                  Description     
 *           -----   ----------      --------------------    ---------------   
 * @version   1.0    2020-08-21      Clayton/Matheus         class created 
 **************************************************************************************************************/
global class LgpdProcessContact_sch_bch implements Schedulable, Database.Batchable < SObject > , Database.Stateful, Database.AllowsCallouts {

    /* LgpdProcessContact_sch_bch lSb = new LgpdProcessContact_sch_bch();
	String lSch = '0 0 0 * * ? * ';
    String jobID = system.schedule('Lgpd Process Contact', lSch, lSb);*/

    Set<Id> fContactToIntegrate;
    List<User> fUserToUpdateLst;
    List<Case> lCaseToCreateLst = new List<Case>();
    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();



    global void execute(SchedulableContext sc) {
        LgpdProcessContact_sch_bch lLgpdProcessContactBatch = new LgpdProcessContact_sch_bch();
        Database.executeBatch(lLgpdProcessContactBatch,1);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        this.fContactToIntegrate = new Set<Id>();
        this.fUserToUpdateLst = new List<User>();
        return Database.getQueryLocator([SELECT Id, AccountId, LastName
            FROM Contact
            WHERE LgpdStatus__c = 'P'
        ]);
    }

    global void execute(Database.BatchableContext BC, List < Contact > aContactLst) {

        Set < Id > lContactIdSet = new Set < Id > ();
        for (Contact lContact: aContactLst) {
            lContactIdSet.add(lContact.Id);
        }

        // Create a savepoint
        Savepoint sp = Database.setSavepoint();

        try {
            
            List<Dependent__c> lDependent = [SELECT Id FROM Dependent__c WHERE PersonHolder__c IN :lContactIdSet];
            if(!lDependent.isEmpty()){
                delete lDependent;
            }

            Map < String, List < LgpdFields >> lObjectFieldsMap = new Map < String, List < LgpdFields >> ();
            for (LgpdFields__mdt lLgpdFields: [SELECT Id, FieldName__c, Object__c, FieldValue__c, FieldType__c FROM LgpdFields__mdt]) {
                List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get(lLgpdFields.Object__c);
                if (lLgpdFieldsLst == null) {
                    lLgpdFieldsLst = new List < LgpdFields > ();
                    lObjectFieldsMap.put(lLgpdFields.Object__c, lLgpdFieldsLst);
                }
                lLgpdFieldsLst.add(new LgpdFields(lLgpdFields.FieldName__c, lLgpdFields.FieldValue__c, lLgpdFields.FieldType__c));
            }

            if (lObjectFieldsMap.containsKey('Case')) {
                List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get('Case');
                List < Case > lCaseToUpdateLst = new List < Case > ();
                for (Case lCase: [SELECT Id, ContactId FROM Case WHERE ContactId =: lContactIdSet]) {
                    lCaseToUpdateLst.add((Case)sobjectUpdateFields(lCase, lLgpdFieldsLst));
                }
                if (!lCaseToUpdateLst.isEmpty()) update lCaseToUpdateLst;
            }

            Set < Id > lContacHasUser = new Set < Id > ();
            Set<String> lUserNameSet = new Set<String>(); 
            if (lObjectFieldsMap.containsKey('User')) {
                List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get('User');
                List<User> lUserLst = [SELECT Id, ContactId, Username, Email FROM User WHERE ContactId =: lContactIdSet];
                for (User lUser: lUserLst) {
                    while (true) {
                        String lUserName =  Datetime.Now().format('MMddyyyyHHmmss') + String.valueOf(RanNumber());   
                        if (!lUserNameSet.contains(lUserName)) {
                            lUserNameSet.add(lUserName);
                            if(test.isRunningTest() && lUser.Email == 'GenerateException@portosocorro.com') {
                                lUser.Username = '';
                            }
                            else {
                                lUser.Username = lUserName + Label.UserNameanonymizationValue;
                                lUser.CommunityNickname = Label.LGPDAnonymous + ' ' + lUserName;
                            }                            
                            system.debug('Usuário' + lUser.Username);
                            break;
                        }                        
                    }
                    lUser = (User)sobjectUpdateFields(lUser, lLgpdFieldsLst);
                    fUserToUpdateLst.add(lUser);
                    lContacHasUser.add(lUser.ContactId);
            }
        }
            if (lObjectFieldsMap.containsKey('AccountContactRelation')) {
                List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get('AccountContactRelation');
                List<AccountContactRelation> lAccountContactRelationLst = new List<AccountContactRelation>();
                for (AccountContactRelation lACR: [SELECT Id, ContactId FROM AccountContactRelation WHERE ContactId =: lContactIdSet]) {
                    if(lContacHasUser.contains(lACR.ContactId)) {
                        lAccountContactRelationLst.add((AccountContactRelation)sobjectUpdateFields(lACR, lLgpdFieldsLst));
                    }
                }
                if(!lAccountContactRelationLst.isEmpty()) update lAccountContactRelationLst;
            }

            if (lObjectFieldsMap.containsKey('Contact')) {
                List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get('Contact');
                List < Contact > lContactToUpdateLst = new List < Contact > ();
                List < Contact > lContactToDeleteLst = new List < Contact > ();
                for (Contact lContact: aContactLst) {
                    system.debug('lContacHasUser.contains: ' + lContacHasUser.contains(lContact.Id));                    
                    if (lContacHasUser.contains(lContact.Id)) {
                        system.debug('lLgpdFieldsLst: ' + lLgpdFieldsLst);
                        if(test.isRunningTest() && lContact.LastName == 'GenerateException') {
                                lContact.Id = null;
                        }
                        lContactToUpdateLst.add((Contact)sobjectUpdateFields(lContact, lLgpdFieldsLst));
                        
                    }
                    else {
                        lContactToDeleteLst.add(lContact);
                    }
                }
                system.debug('##Contact to update: ' + lContactToUpdateLst);
                system.debug('##Contact to delete: ' + lContactToDeleteLst);

                Database.SaveResult[] saveResultList = Database.update(lContactToUpdateLst, false);
                for (Database.SaveResult sr : saveResultList) {
                    if (!sr.isSuccess()) {
                        String lMsgErro = '';
                        for(Database.Error err : sr.getErrors()) {                 
                            lMsgErro += err.getStatusCode() + ': ' + err.getMessage() + '\nCampos: ' + err.getFields();
                        }
                        lCaseToCreateLst.add(createSupportCase(sr.getId(), lMsgErro));
                    }
                    else {
                        fContactToIntegrate.add(sr.getId());
                    }
                }

                Database.DeleteResult[] deleteResultList = Database.delete(lContactToDeleteLst, false);
                for (Database.DeleteResult sr : deleteResultList) {
                    if (!sr.isSuccess()) {
                        String lMsgErro = '';
                        for(Database.Error err : sr.getErrors()) {                 
                            lMsgErro += err.getStatusCode() + ': ' + err.getMessage() + '\nCampos: ' + err.getFields();
                        }
                        lCaseToCreateLst.add(createSupportCase(sr.getId(), lMsgErro));
                    }
                    else {
                        fContactToIntegrate.add(sr.getId());
                    }
                }
            }

            if (!lCaseToCreateLst.isEmpty()){
                saveSupportCase(lCaseToCreateLst);
            }
            
        }
        catch(DmlException e) {
            system.debug('Catch1: ' + e);
            Database.rollback(sp);
            saveSupportCase(new List<Case>{createSupportCase(Label.LGPDException, e.getMessage())});
        }
        catch(Exception e) {
            system.debug('Catch2: ' + e);
            Database.rollback(sp);
            saveSupportCase(new List<Case>{createSupportCase(Label.LGPDException, e.getMessage())});
        }
    }
   

     public String RanNumber(){
            return String.valueOf(Math.round((Math.random() * (9000) + 1000))); //metódo para gerar o número aleatório a ser inserido no nome do usuário
        }
    
    public class LgpdFields {
        String fieldName;
        String fieldValue;
        String fieldType;

        public LgpdFields(String aFieldName, String aFieldValue, String aFieldType) {
            this.fieldName = aFieldName;
            this.fieldValue = aFieldValue;
            this.fieldType = aFieldType ;
        }
    }

    public SObject sobjectUpdateFields(SObject aSObject, List<LgpdFields> aLgpdFieldsLst) {
        for (LgpdFields lField: aLgpdFieldsLst) {
            if(String.isBlank(lField.fieldValue)) {
                aSObject.put(lField.fieldName, null);
            }
            else {
                switch on lField.fieldType {
                    when 'Boolean' {
                        aSObject.put(lField.fieldName, Boolean.valueOf(lField.fieldValue));
                    }
                    when 'Number' {
                        aSObject.put(lField.fieldName, Decimal.valueOf(lField.fieldValue));
                    }
                    when 'Date' {
                        aSObject.put(lField.fieldName, Date.valueOf(lField.fieldValue));
                    }
                    when 'Datetime' {
                        aSObject.put(lField.fieldName, Datetime.valueOf(lField.fieldValue));
                    }
                    when 'Text' {
                        aSObject.put(lField.fieldName, String.valueOf(lField.fieldValue));
                    }
                } 
            }
        }
        return aSObject;
    }

    public void saveSupportCase(List<Case> aCaseLst) {
        List<AssignmentRule>  lAssigmentRuleIdLst = [SELECT Id FROM AssignmentRule WHERE SobjectType = :Label.SObjectNameCase and Active = true];
        Database.DMLOptions lDMLOptions = new Database.DMLOptions();
        lDMLOptions.EmailHeader.triggerUserEmail = true;
        lDMLOptions.assignmentRuleHeader.assignmentRuleId = lAssigmentRuleIdLst[0].Id;
        Database.insert(aCaseLst, lDMLOptions);
    }

    public Case createSupportCase(String aCodeRecord ,String aErrorDescription) {
        return new Case(
            Subject = Label.ErrorSubjectLGPD,
            Status = Label.String_OnHold , 
            RecordCode__c = aCodeRecord, 
            Description = aErrorDescription, 
            ObjectType__c = Label.LGPDBatchObject, 
            RecordTypeId = SUPPORT_API, 
            Origin = Label.ExceptionSalesforceErrorAnonymizeLGPD
        );
    }

    global void finish(Database.BatchableContext BC) {
        // Atualiza os usuários nesta thread para não ter problemas com atualização de 
        // objetos do sistema com objetos de configuração
        if (!fUserToUpdateLst.isEmpty()){
            try{
            	Database.SaveResult[] saveResultList = Database.update(fUserToUpdateLst, false);
        		for (Database.SaveResult sr : saveResultList) {
					if (!sr.isSuccess()) {
						String lMsgErro = '';
						for(Database.Error err : sr.getErrors()) {                 
							lMsgErro += err.getStatusCode() + ': ' + err.getMessage() + '\nCampos: ' + err.getFields();
						}
						lCaseToCreateLst.add(createSupportCase(sr.getId(), lMsgErro));
					}
				}
            }
            catch(DmlException e) {
            	system.debug('Catch1: ' + e);
            	saveSupportCase(new List<Case>{createSupportCase(Label.LGPDException, e.getMessage())});
        	}
        	catch(Exception e) {
            	system.debug('Catch2: ' + e);
            	saveSupportCase(new List<Case>{createSupportCase(Label.LGPDException, e.getMessage())});
        	}
        
        	if (!lCaseToCreateLst.isEmpty()){
                saveSupportCase(lCaseToCreateLst);
        	}
        }

        // Chama o batch de integração do retorno da aninimização do contato LGPD
        if(!Test.isRunningTest()) {           
            LgpdProcessContactIntegrate_bch lLgpdProcessContactIntegrate = new LgpdProcessContactIntegrate_bch(fContactToIntegrate);
            Database.executeBatch(lLgpdProcessContactIntegrate);        
        }
    }
}