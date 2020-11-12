/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de Contact
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-03-05      Eduardo Costa           class created 
**************************************************************************************************************/
public with sharing class ContactHandler {

    private static final String BASE_EMPLOYEES_RECTYPEID = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.BaseEmployeesRecordType).getRecordTypeId();    
    private static final String PARTNER_RECTYPEID = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.PartnerRecordType).getRecordTypeId();    
    private static final String PROVIDER_TYPE_DEFAULT = Label.ProviderTypeDefault;   
    private static final String COLABORADOR_DA_BASE = Label.BaseEmployeeLabel;   
    private static final String ROLE_ADMINISTRATIVO = Label.RoleAdministrative;    
    private static final String ROLE_GESTOR = Label.RoleGestor;    
    private static final String STATUS_RELEASED = Label.Status_Released;
    private static final String STATUS_RELEASED_RADAR = Label.String_L;    
    private static final String STATUS_ACTIVE = Label.Status_Active;
    private static final String STATUS_INACTIVE = Label.Status_Inactive;
    private static final String STATUS_BLOCKED = Label.StatusTemporarilyInactive;
    private static final String STATUS_CANCELED= Label.StatusCanceled;
    private static final String IN_DEPLOYMENT = Label.Status_Deployment ;
    private static final String STATUS_LIFE_PLAN = Label.String_A;
    private static final Integer STEP_WIZARD = 3;
    
    public static void removeJunctionContactToContact(List<Contact> aContactLstNew){        
        TriggerCheck.assert();
        Set<String> lContactAccountJunctionSet = new Set<String>();
        Set<Id> lBaseEmployeesToRemoveJunctionIdSet = new Set<Id>();
        Map<Id,Boolean> lStatusIsChangeBlockOrCancelIdmap = new Map<Id,Boolean>();
        for(Contact lContact: aContactLstNew){
            if(lContact.RecordTypeId == BASE_EMPLOYEES_RECTYPEID) {
                if(TriggerCheck.isChanged(lContact, Contact.AccountId) || TriggerCheck.isChanged(lContact, Contact.Status__c)) {
                    lBaseEmployeesToRemoveJunctionIdSet.add(lContact.Id);
                    lContactAccountJunctionSet.add(lContact.Id+''+lContact.AccountId);
                    lStatusIsChangeBlockOrCancelIdmap.put(lContact.AccountId, 
                        (lContact.Status__c == STATUS_INACTIVE || 
                        lContact.Status__c == STATUS_BLOCKED || 
                        lContact.Status__c == STATUS_CANCELED));
                }                
            }   
        }   

        if(lBaseEmployeesToRemoveJunctionIdSet.isEmpty()) return;

        Map<Id,Integer> lContactRelationQtdMap = new Map<Id,Integer>();
        for(AggregateResult lAr :[SELECT Count(AccountId) qtd, ContactId contact FROM AccountContactRelation 
                WHERE ContactId IN :lBaseEmployeesToRemoveJunctionIdSet GROUP BY ContactId ]) {
            lContactRelationQtdMap.put((Id)lAr.get('contact'), Integer.ValueOf(lAr.get('qtd')));
        }

        List<AccountContactRelation> lAccountContactRelationToDelete = new List<AccountContactRelation>();
        List<AccountContactRelation> lAccountContactRelationToUpdate = new List<AccountContactRelation>();
        for(AccountContactRelation lAccCttRelation :[SELECT AccountId, ContactId, CreatedDate, IsActive, IsDirect FROM AccountContactRelation 
                WHERE ContactId IN :lBaseEmployeesToRemoveJunctionIdSet]) {
            if(!lContactAccountJunctionSet.contains(lAccCttRelation.ContactId+''+lAccCttRelation.AccountId) || 
                    (lAccCttRelation.IsActive && lStatusIsChangeBlockOrCancelIdmap.get(lAccCttRelation.AccountId))) {
                Date lDueDate = date.newInstance(lAccCttRelation.CreatedDate.year(), lAccCttRelation.CreatedDate.month(), lAccCttRelation.CreatedDate.day());
                Integer lContactRelationQtd = lContactRelationQtdMap.get(lAccCttRelation.ContactId);
                if(!lAccCttRelation.IsDirect && date.today().isSameDay(lDueDate) && lContactRelationQtd != null && lContactRelationQtd > 1) {
                    lAccountContactRelationToDelete.add(lAccCttRelation);
                }
                else {
                    if(lAccCttRelation.IsActive) {
                        lAccCttRelation.IsActive = false;
                        lAccCttRelation.EndDate = system.today();
                        lAccountContactRelationToUpdate.add(lAccCttRelation);
                    }                    
                }
            }
            else {
                lAccCttRelation.IsActive = true;
                lAccCttRelation.Roles = COLABORADOR_DA_BASE;
                lAccCttRelation.StartDate = system.today();
                lAccCttRelation.EndDate = Date.valueOf(Label.MaximumDate);
                lAccountContactRelationToUpdate.add(lAccCttRelation);
            }
        }

        if(!lAccountContactRelationToDelete.isEmpty()) delete lAccountContactRelationToDelete;
        if(!lAccountContactRelationToUpdate.isEmpty()) update lAccountContactRelationToUpdate;
    }
    
    public static void generateQRA(List<Contact> aContactLstNew) {
        TriggerCheck.assert();
        List<Contact> lContactToGenerateQraLst = new List<Contact>();
        for(Contact lContact :aContactLstNew) {
            if(lContact.RecordTypeId == BASE_EMPLOYEES_RECTYPEID &&
                    lContact.QRA__c == null && 
                    lContact.StepWizard__c == 3 && 
                    (lContact.Role__c == ROLE_ADMINISTRATIVO ||  
                    TriggerCheck.isChangedTo(lContact, Contact.StatusRadar__c, STATUS_RELEASED_RADAR) || 
                    TriggerCheck.isChangedTo(lContact, Contact.RisksStatus__c, STATUS_RELEASED))){
                lContactToGenerateQraLst.add(lContact);
            }
            /* 
			if(lContact.RecordTypeId == BASE_EMPLOYEES_RECTYPEID &&
               lContact.QRA__c == null &&
               lContact.LegalSituationProvider__c == 'PF'
              ){
                lContactToGenerateQraLst.add(lContact);
              }
			*/      
        }  
        
        if(lContactToGenerateQraLst.isEmpty()) return;

        List<Contact> lContactQraMax = [SELECT Id, QRA__c FROM Contact WHERE QRA__c != null ORDER BY QRA__c DESC LIMIT 1];
        Decimal lQraMax = lContactQraMax.isEmpty()?0:lContactQraMax[0].QRA__c;

        for(Contact lContact :lContactToGenerateQraLst) {
            lContact.QRA__c = ++lQraMax;
        }
    }
    
    public static void validateQRA(List<Contact> aContactLstNew) {
        Map<Decimal,Contact> lContactValidateIdQraMap = new Map<Decimal,Contact>();
        Set<Id> lContactIdSet = new Set<Id>();
        for(Contact lContact :aContactLstNew) {
            if(TriggerCheck.isChanged(lContact, Contact.QRA__c) && lContact.QRA__c != null){
                lContactValidateIdQraMap.put(lContact.QRA__c,lContact);
                lContactIdSet.add(lContact.Id);
            }            
        }  
        
        if(lContactValidateIdQraMap.isEmpty()) return;

        for(Contact lContact :[SELECT QRA__c FROM Contact WHERE QRA__c IN :lContactValidateIdQraMap.keySet() AND Id NOT IN :lContactIdSet]) {
            Contact lCtToNotify = lContactValidateIdQraMap.get(lContact.QRA__c);
            if(lCtToNotify != null) {
                lCtToNotify.addError(Label.ErrorQRARegistered);
            }
        }
    }

    public static void providerActivation(List<Contact> aContactLstNew){
        TriggerCheck.assert();
        List<Contact> lContactToActivateLst = new List<Contact>();
        for(Contact lContact: aContactLstNew){
            if(lContact.RecordTypeId == BASE_EMPLOYEES_RECTYPEID && lContact.Status__c != STATUS_ACTIVE && 
                    (TriggerCheck.isChangedTo(lContact, Contact.StatusRadar__c, STATUS_RELEASED_RADAR) || 
                    TriggerCheck.isChangedTo(lContact, Contact.RisksStatus__c, STATUS_RELEASED) || 
                    TriggerCheck.isChangedTo(lContact, Contact.ApprovedSelectionProcess__c, true))) { 
                system.debug('teste Tipo pessoa: ' + lContact.LegalSituationProvider__c);
                if((lContact.StatusRadar__c == STATUS_RELEASED_RADAR || 
                        lContact.RisksStatus__c == STATUS_RELEASED) &&
                        (lContact.ProviderType__c != PROVIDER_TYPE_DEFAULT || 
                        lContact.ApprovedSelectionProcess__c == true) &&
                  		lContact.LegalSituationProvider__c == Label.LegalPerson) {
                    lContact.Status__c = STATUS_ACTIVE;
                    lContactToActivateLst.add(lContact);                    
                }
            }
        }
        // Colocar aqui o método futuro para ativação do socorrista, respeitanto o limite de 50 chamadas de métodos futuros por thread e no maximo 100 callout por transação     
    }   
    
    public static void legacyIntegration(List<Contact> aContactLst) {
        TriggerCheck.assert();

        List<Contact> lContactLst = new List<Contact>();
        for(Contact lContact: aContactLst){
            system.debug('###lContact ' + lContactLst);
            if(lContact.QRA__c !=null && lContact.RecordTypeId == BASE_EMPLOYEES_RECTYPEID){
                lContactLst.add(lContact);
            }
        }
        system.debug('lContactLst ' + lContactLst);
        if(lContactLst.isEmpty()) return;               
        
        SpecialtyWrapper_cls lContactToIntegration = RescuerWebService_cls.getContactToIntegration(lContactLst);
        if(lContactToIntegration != null) {
            System.enqueueJob(new IntegrationHandler_cls(lContactToIntegration));
        }   
    }

    public static void generateExternalId(List<Contact> aContLstNew) {
        TriggerCheck.assert();
        
        List<Contact> lContactCreateIdLst = new List<Contact>();
        for(Contact lCont :aContLstNew){
            if(lCont.Code__c == null && lCont.RecordTypeId == PARTNER_RECTYPEID){
                lContactCreateIdLst.add(lCont);
            }               
        }
        if(lContactCreateIdLst.isEmpty()) return;

        Decimal lLastCode;
        for(AggregateResult lAgr :[SELECT MAX(Code__c) lastValue FROM Contact WHERE RecordTypeId = :PARTNER_RECTYPEID]) {
            lLastCode = (Decimal)lAgr.get('lastValue');
        }

        for(Contact lCont :lContactCreateIdLst){
          if(lLastCode == null) lLastCode = 0;
          lCont.Code__c = ++lLastCode;
          ++lLastCode;
        }
    }

    /* 
    Método para realizar os Roll-Up dos Socorristas Ativos do prestador
    */
    public static void rollUpContactProvider(List<Contact> aContactLstNew) {
        TriggerCheck.assert();

        Set<Id> lProviderToUpdateIdSet = new Set<Id>();
        for(Contact lContact: aContactLstNew){
            if(TriggerCheck.isChanged(lContact, Contact.AccountId)){
                lProviderToUpdateIdSet.add(lContact.AccountId);
                if(trigger.isUpdate) {
                    lProviderToUpdateIdSet.add(((Contact)trigger.oldMap.get(lContact.id)).AccountId);
                }
            } 
            if(TriggerCheck.isChanged(lContact, Contact.Status__c) || TriggerCheck.isChanged(lContact, Contact.Role__c) ){
                lProviderToUpdateIdSet.add(lContact.AccountId);
            }
        }

        if(lProviderToUpdateIdSet.isEmpty()) return;

        Map<Id,Account> lProviderToUpdateMap = new Map<Id,Account>();
        List<Account> lProviderSetLst = new List<Account>();
        for(Id lProviderId :lProviderToUpdateIdSet){
            lProviderToUpdateMap.put(lProviderId,new Account(Id = lProviderId, QuantityQRA__c = 0));             
        }

        for(AggregateResult lAr :[SELECT COUNT(Id) total, AccountId provider FROM Contact 
                WHERE Contact.Status__c = :STATUS_ACTIVE AND Contact.Role__c = :Label.RoleRescuer AND AccountId IN :lProviderToUpdateIdSet GROUP BY AccountId ]) {
            Account lProvider = lProviderToUpdateMap.get((Id)lAr.get('provider'));
            if(lProvider != null) {
                lProvider.QuantityQRA__c = Integer.valueOf(lAr.get('total'));
                lProviderSetLst.add(lProvider);
            }
        }

        if(!lProviderSetLst.isEmpty()) update lProviderSetLst; 
    }
    
}