/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de AccountContactRelation
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-05-14      Eduardo Costa           class created 
**************************************************************************************************************/
public with sharing class AccountContactRelationHandler {
    
    private static final String COLABORADOR_DA_BASE = Label.BaseEmployeeLabel;  
    private static final String PARTNER = Label.PartnerLabel; 
    private static final String BASE_EMPLOYEES_RECORDTYPE = Label.BaseEmployeesRecordType;
    private static final String PARTNER_RECORDTYPE = Label.PartnerRecordType;

    public static void predefinedValues(List<AccountContactRelation> aAccountContactRelationLstNew){        

        TriggerCheck.assert();
        Set<Id> lContactIdSet = new Set<Id>();
        for(AccountContactRelation lAccCttRelation :aAccountContactRelationLstNew){
            lContactIdSet.add(lAccCttRelation.ContactId);
        }
        
        
        Map<Id,String> lRelationMap = new Map<Id,String>();
        for(Contact lContact :[SELECT Id, RecordType.DeveloperName FROM Contact WHERE Id IN :lContactIdSet]){
            if(lContact.RecordType.DeveloperName == BASE_EMPLOYEES_RECORDTYPE){
                lRelationMap.put(lContact.Id,COLABORADOR_DA_BASE);
            }
            else if(lContact.RecordType.DeveloperName == PARTNER_RECORDTYPE){
                lRelationMap.put(lContact.Id,PARTNER);
            }
            
        }
        for(AccountContactRelation lAccCttRelation :aAccountContactRelationLstNew) {            
            lAccCttRelation.Roles = lRelationMap.get(lAccCttRelation.ContactId);
            lAccCttRelation.StartDate = system.today();
            lAccCttRelation.EndDate = Date.valueOf(Label.MaximumDate);
        }
    }

    public static void blockExclusion(List<AccountContactRelation> aAccountContactRelationLstNew){        

        TriggerCheck.assert();

        for(AccountContactRelation lAccCttRelation :aAccountContactRelationLstNew) {            
            Date lDueDate = date.newInstance(lAccCttRelation.CreatedDate.year(), lAccCttRelation.CreatedDate.month(), lAccCttRelation.CreatedDate.day());
            if((lAccCttRelation.IsDirect || !date.today().isSameDay(lDueDate)) && lAccCttRelation.Roles == COLABORADOR_DA_BASE) {
                lAccCttRelation.addError(Label.AccountContactRelationExclusionError);
            }
        }
    }
}