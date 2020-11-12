/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger do Caso
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-11-07      Jean Sganzerla          class created 
**************************************************************************************************************/
public class CaseHandler {
    
    private static final Id PORTFOLIO_ANALYSIS_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.PortfolioAnalysisRecordType).getRecordTypeId();
    private static final Id PROJECTION_AND_SIZING_SERVICE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.ProjectionAndSizingServiceRecordType).getRecordTypeId();
    private static final Id SERVICE_PRICING_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.ServicePricingRecordType).getRecordTypeId();
    private static final Id CONTRACT_REVIEW_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.ContractReviewRecordType).getRecordTypeId();
    private static final Id TRAINING_ANALYSIS_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.TrainingAnalysisRecordType).getRecordTypeId();
    private static final Id POC_REQUIREMENTS_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.POCRequirementsRecordType).getRecordTypeId();
    private static final Id SERVICE_DEPLOYMENT_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.ServiceDeploymentRecordType).getRecordTypeId();
    private static final Id SERVICE_RECTYPE = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.ServiceRecordType).getRecordTypeId();
    private static final Id SERVICE_MAGNIFICATION_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.ServiceMagnificationRecordType).getRecordTypeId();
    private static final Id OPERATIONAL_IMPACT_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.OperationalImpactRercordType).getRecordTypeId();
    private static final Id REMOVE_SERVICE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RemoveServiceRecordType).getRecordTypeId();
    private static final Id PROTOTYPING_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.PrototypingRecordType).getRecordTypeId();
    private static final Id IMPACT_ANALYSIS_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.ImpactAnalysisRecordType).getRecordTypeId();
    private static final Id SUPPORT_APIS_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();

    private static final String INTEGRATION = Label.IntegrationgNameField;
    

    public static void requiresRequirements(Map<Id,Case> aMapNew){
        TriggerCheck.assert();
        
        List<Case> lCaseToCheckLst = new List<Case>();
        for(Case lCase :aMapNew.values()){
            if(TriggerCheck.isChangedFromTo(lCase, Case.Status, Label.Status_LaboratoryAnalysis, Label.Status_EquipmentAnalysis) && lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE){
                lCaseToCheckLst.add(lCase);
            }
        }
        // System.debug('lCaseToCheckLst ------> ' + lCaseToCheckLst);
        if(lCaseToCheckLst.isEmpty()) return;

        Set<Id> lRequirementsSet = new Set<Id>();
        for(Case lRequirements :[SELECT Id, ParentId FROM Case WHERE RecordType.DeveloperName = :Label.POCRequirementsRecordType AND ParentId IN :lCaseToCheckLst ORDER BY ParentId]){
            lRequirementsSet.add(lRequirements.ParentId);
        }
        // System.debug('lRequirementsSet ------> ' + lRequirementsSet);
        for(Case lCase :lCaseToCheckLst){
            if(!lRequirementsSet.contains(lCase.Id)){
                aMapNew.get(lCase.Id).addError(Label.CaseError_AoMenosUmRegObjetivoPoc);
            }
        }
    }

    public static void waitForOperationalAnalysis(Map<Id,Case> aMapNew){
        TriggerCheck.assert();
        
        List<Case> lCaseToCheckLst = new List<Case>();
        for(Case lCase :aMapNew.values()){
            if((TriggerCheck.isChangedFromTo(lCase, Case.Status, Label.OperationalAnalysisStatus, Label.Status_LineUpExecution) && lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE) || 
              (TriggerCheck.isChangedFromTo(lCase, Case.Status, Label.Status_Pricing, Label.Status_Viability) && lCase.RecordTypeId == SERVICE_MAGNIFICATION_RECTYPE) || 
              (TriggerCheck.isChangedFromTo(lCase, Case.Status, Label.Status_OperationalImpact, Label.FinalDecisionStatus) && lCase.RecordTypeId == REMOVE_SERVICE_RECTYPE)){
                lCaseToCheckLst.add(lCase);
            }
        }

        // System.debug('lCaseToCheckLst ------> ' + lCaseToCheckLst);
        if(lCaseToCheckLst.isEmpty()) return;

        Set<Id> lRequirementsSet = new Set<Id>();
        for(Case lRequirements :[SELECT Id, ParentId, Status FROM Case WHERE ParentId IN :lCaseToCheckLst AND ((RecordType.DeveloperName = :Label.ProjectionAndSizingServiceRecordType AND Status != :Label.Status_Closed) OR (RecordType.DeveloperName = :Label.ServicePricingRecordType AND Status != :Label.Status_Closed) OR (RecordType.DeveloperName = :Label.ContractReviewRecordType AND Status != :Label.Status_Closed) OR (RecordType.DeveloperName = :Label.TrainingAnalysisRecordType AND Status != :Label.Status_Closed) OR (RecordType.DeveloperName = :Label.OperationalImpactRercordType AND Status != :Label.Status_Concluded)) ORDER BY ParentId]){
            lRequirementsSet.add(lRequirements.ParentId);
        }
        // System.debug('waitForOperationalAnalysis: lRequirementsSet ------> ' + lRequirementsSet);
        if(lRequirementsSet.isEmpty()) return;

        for(Case lCase :lCaseToCheckLst){
            if(lRequirementsSet.contains(lCase.Id) && lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE){
                aMapNew.get(lCase.Id).addError(Label.ErrorMsgOperacionalAnalysis);
            }else if(lRequirementsSet.contains(lCase.Id) && lCase.RecordTypeId == SERVICE_MAGNIFICATION_RECTYPE){
                aMapNew.get(lCase.Id).addError(Label.ErrorWaitingPricingMsg);
            }else if(lRequirementsSet.contains(lCase.Id) && lCase.RecordTypeId == REMOVE_SERVICE_RECTYPE){
                aMapNew.get(lCase.Id).addError(Label.ErrorWaitingOperationalImpactMsg);
            }
        }
    }

    public static void changeCaseStatus(List<Case> aNewLst){
        TriggerCheck.assert();

        Set<Id> lParentIdSet = new Set<Id>();
        for(Case lCase :aNewLst){
            if((TriggerCheck.isChangedTo(lCase, Case.Status, Label.Status_Concluded) && lCase.RecordTypeId == SERVICE_DEPLOYMENT_RECTYPE || lCase.RecordTypeId == OPERATIONAL_IMPACT_RECTYPE) ||
            (TriggerCheck.isChangedTo(lCase, Case.Status, Label.Status_Closed) && (lCase.RecordTypeId == PROJECTION_AND_SIZING_SERVICE_RECTYPE || lCase.RecordTypeId == SERVICE_PRICING_RECTYPE || lCase.RecordTypeId == CONTRACT_REVIEW_RECTYPE || lCase.RecordTypeId == TRAINING_ANALYSIS_RECTYPE))){
                lParentIdSet.add(lCase.ParentId);
            }
        }
        System.debug('lParentIdSet' + lParentIdSet);
        if(lParentIdSet.isEmpty()) return;

        Map<String,Integer> lComparationDaysMap = new Map<String,Integer>();
        lComparationDaysMap.put('30 dias',30);
        lComparationDaysMap.put('15 dias',15);
        lComparationDaysMap.put('10 dias',10);
        lComparationDaysMap.put('5 dias',5);
        lComparationDaysMap.put('Imediato',0);

        Map<Id,Integer> lParentIdDateMap = new Map<Id,Integer>();

        for(Case lCase : [SELECT Id, Status, ParentId, RecordTypeId, Term__c FROM Case WHERE ParentId IN :lParentIdSet AND (RecordTypeId = :SERVICE_DEPLOYMENT_RECTYPE OR RecordTypeId = :OPERATIONAL_IMPACT_RECTYPE OR RecordTypeId = :PROJECTION_AND_SIZING_SERVICE_RECTYPE OR RecordTypeId = :SERVICE_PRICING_RECTYPE OR RecordTypeId = :CONTRACT_REVIEW_RECTYPE OR RecordTypeId = :TRAINING_ANALYSIS_RECTYPE) ORDER BY ParentId]){
            if(lCase.Status != Label.Status_Closed && lCase.Status != Label.Status_Concluded){
                lParentIdSet.remove(lCase.ParentId);
            }
            else if(lCase.RecordTypeId == SERVICE_PRICING_RECTYPE || lCase.RecordTypeId == CONTRACT_REVIEW_RECTYPE || lCase.RecordTypeId == OPERATIONAL_IMPACT_RECTYPE){
                if(lParentIdDateMap.containsKey(lCase.ParentId)){
                    //System.debug('Encontrou a chave do caso Pai');
                    if(lComparationDaysMap.get(lCase.Term__c) > lParentIdDateMap.get(lCase.ParentId)){
                        //System.debug('Entrou aqui');
                        lParentIdDateMap.put(lCase.ParentId,lComparationDaysMap.get(lCase.Term__c));
                        System.debug('lParentIdDateMap' + lParentIdDateMap);
                    }
                }
                else{
                    lParentIdDateMap.put(lCase.ParentId,lComparationDaysMap.get(lCase.Term__c));
                    //System.debug('populou a primeira vez com '+ lCase.Term__c );
                }
            }
        }
        System.debug('lParentIdDateMap ---> ' + lParentIdDateMap);
        List<Case> lParentCaseToUpdateLst = [SELECT Status, RecordTypeId, SendEmail__c, EmailHelperAlignExecution__c, EmailHelperFeatureDefinition__c, TermForMagnificationConclusion__c, DateWithdrawalFromService__c FROM Case WHERE Id IN :lParentIdSet];
        List<Group> lQueueLst = [SELECT Id FROM Group WHERE Type = :Label.String_Queue AND DeveloperName =:Label.Status_ResourcesDefinition];
        if(lParentCaseToUpdateLst.isEmpty()) return;
     
        for(Case lCase :lParentCaseToUpdateLst){
            if(lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE){
                if(lCase.Status == Label.Status_Deployment){
                    lCase.Status = Label.Status_ResourcesDefinition;
                    lCase.EmailHelperFeatureDefinition__c = true;
                    if(!lQueueLst.isEmpty()) {
                        lCase.OwnerId = lQueueLst[0].Id;
                    }                    
                }
                else{
                    lCase.Status = Label.Status_LineUpExecution;
                    lCase.EmailHelperAlignExecution__c = true;
                }
            }            
            else if(lCase.RecordTypeId == SERVICE_MAGNIFICATION_RECTYPE && lCase.Status == Label.Status_Pricing){
                lCase.Status = Label.Status_Viability;
                lCase.SendEmail__c = true;
                system.debug('lParentIdDateMap.get(lCase.Id)' + lParentIdDateMap.get(lCase.Id));
                lCase.TermForMagnificationConclusion__c = System.today().addDays(lParentIdDateMap.get(lCase.Id));
            }
            else if(lCase.RecordTypeId == REMOVE_SERVICE_RECTYPE && lCase.Status == Label.Status_OperationalImpact){
                //system.debug('entrou');
                lCase.Status = Label.FinalDecisionStatus;
                lCase.SendEmail__c = true;
                system.debug('lParentIdDateMap.get(lCase.Id)' + lParentIdDateMap.get(lCase.Id));
                //System.debug('### IGORITOS DEBUG: ' + lCase.DateWithdrawalFromService__c);
                //System.debug('### IGORITOS DEBUG2: ' + lParentIdDateMap.get(lCase.Id));
                lCase.DateWithdrawalFromService__c = System.today().addDays(lParentIdDateMap.get(lCase.Id));
            }
        }
        update lParentCaseToUpdateLst;    
    }

    public static void verifyAttachment(Map<Id,Case> aNewMap){
        TriggerCheck.assert();

        Set<Id> lCaseSet = new Set<Id>();
        for(Case lCase :aNewMap.values()){
            if(lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE && TriggerCheck.isChangedFromTo(lCase, Case.Status, Label.LineUpExecutionStatus, Label.ExecuteStatus)){
                lCaseSet.add(lCase.Id);
            }
        }
        if(lCaseSet.isEmpty()) return;

        Set<Id> lAttachSet = new Set<Id>();
        for(ContentDocumentLink lDoc :[SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :lCaseSet]){
            lAttachSet.add(lDoc.LinkedEntityId);
        }

        Set<Id> lEventSet = new Set<Id>();
        for(Event lEvent :[SELECT Id, WhatId FROM Event WHERE WhatId IN :lCaseSet]){
            lEventSet.add(lEvent.WhatId);
        }

        for(Id lCaseId :lCaseSet){
            if(!lAttachSet.contains(lCaseId) && !lEventSet.contains(lCaseId)){
                aNewMap.get(lCaseId).addError(Label.ErrorAdvanceStatus);
            }
            else if(!lAttachSet.contains(lCaseId)){
                aNewMap.get(lCaseId).addError(Label.ErrorAdvanceStatusMeeting);
            }
            else if(!lEventSet.contains(lCaseId)){
                aNewMap.get(lCaseId).addError(Label.ErrorAdvanceStatusSubject);
            }
        }
    }
    
    // public static void startOperationalAnalysisAndDeployment(List<Case> aNewLst){
    //     TriggerCheck.assert();

    //     List<Case> lParentCaseLst = new List<Case>();
    //     for(Case lCase :aNewLst){
    //         if((TriggerCheck.isChangedTo(lCase, Case.Status, 'Análise Operacional') && lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE &&
    //         (lCase.Ability__c != 'Não será avaliado(a)' || lCase.Parts__c != 'Não será avaliado(a)' || lCase.Problem__c != 'Não será avaliado(a)' || 
    //         lCase.Modal__c != 'Não será avaliado(a)' || lCase.OperationalService__c != 'Não será avaliado(a)' || lCase.Specialty__c != 'Não será avaliado(a)'))
    //         || (TriggerCheck.isChangedTo(lCase, Case.Status, 'Em Implantação') && lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE)){
    //             lParentCaseLst.add(lCase);
    //         }
    //     }
    //     if(lParentCaseLst.isEmpty()) return;

    //     Map<String,Id> lQueueMap = new  Map<String,Id>();
    //     for(Group lQueue : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND (DeveloperName = 'ProjectionAndSizing' OR DeveloperName = 'Pricing' OR DeveloperName = 'Contract' OR DeveloperName = 'Course' OR DeveloperName = 'Recruitment' OR DeveloperName = 'EquipmentAndSupply')]){
    //         lQueueMap.put(lQueue.DeveloperName,lQueue.Id);
    //     }
    //     List<Entitlement> lEntitlementLst = [SELECT Id FROM Entitlement WHERE Name = 'Tempo de resolução Caso'];
        
    //     List<Case> lCaseToInsertLst;
    //     Map<Id,Case> lServiceDeploymentCaseMap = new Map<Id,Case>();
    //     for(Case lCase :lParentCaseLst){
    //         if(lCase.Status == 'Análise Operacional'){
    //             if(lCase.OperationalService__c != 'Não será avaliado(a)' || lCase.Specialty__c != 'Não será avaliado(a)' || lCase.Modal__c != 'Não será avaliado(a)'){           
    //                 lCaseToInsertLst = new List<Case>{getCase('ProjectionAndSizing' , lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('ServicePricing', lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('ContractReview', lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('TrainingAnalysis', lCase.Id, lQueueMap, lEntitlementLst[0].Id)};
    //             }
    //             else if(lCase.Ability__c != 'Não será avaliado(a)' && lCase.Problem__c != 'Não será avaliado(a)'){
    //                 lCaseToInsertLst = new List<Case>{getCase('ProjectionAndSizing' , lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('ServicePricing', lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('TrainingAnalysis', lCase.Id, lQueueMap, lEntitlementLst[0].Id)};
    //             }
    //             else if(lCase.Ability__c != 'Não será avaliado(a)'){
    //                 lCaseToInsertLst = new List<Case>{getCase('ProjectionAndSizing' , lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('TrainingAnalysis', lCase.Id, lQueueMap, lEntitlementLst[0].Id)};
    //             }
    //             else if(lCase.Problem__c != 'Não será avaliado(a)'){
    //                 lCaseToInsertLst = new List<Case>{getCase('ServicePricing', lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('TrainingAnalysis', lCase.Id, lQueueMap, lEntitlementLst[0].Id)};
    //             }
    //             else if(lCase.Parts__c != 'Não será avaliado(a)'){
    //                 lCaseToInsertLst = new List<Case>{getCase('TrainingAnalysis', lCase.Id, lQueueMap, lEntitlementLst[0].Id)};
    //             }
    //         }
    //         else{
    //             lServiceDeploymentCaseMap.put(lCase.Id,lCase);
    //         }
    //     }

    //     if(lServiceDeploymentCaseMap.isEmpty()){
    //         // System.debug('lCaseToInsertLst --------> ' + lCaseToInsertLst);
    //         insert lCaseToInsertLst; 
    //     }
    //     else{
    //         if(lCaseToInsertLst == null){
    //             lCaseToInsertLst = new List<Case>();
    //         }
    //         for(Case lCase :[SELECT Id, ParentId, NeedReviewContract__c, NeedReviewTraining__c, RecordTypeId FROM Case WHERE ParentId IN :lServiceDeploymentCaseMap.keySet() AND (RecordtypeId = :CONTRACT_REVIEW_RECTYPE OR RecordtypeId = :TRAINING_ANALYSIS_RECTYPE) ORDER BY ParentId]){
    //             if(lCase.RecordTypeId == CONTRACT_REVIEW_RECTYPE){
    //                 if(lCase.NeedReviewContract__c){
    //                     lCaseToInsertLst.add(getCase('RiskAndCost', lCase.ParentId, lQueueMap, lEntitlementLst[0].Id));
    //                 }
    //                 continue;
    //             }
    //             if(lCase.RecordTypeId == TRAINING_ANALYSIS_RECTYPE && lCase.NeedReviewTraining__c){ 
    //                 lCaseToInsertLst.add(getCase('School', lCase.ParentId, lQueueMap, lEntitlementLst[0].Id));           
    //             }
    //         }
    //         for(Case lCase :lServiceDeploymentCaseMap.values()){

    //             lCaseToInsertLst.add(getCase('Recruitment', lCase.Id, lQueueMap, lEntitlementLst[0].Id));           

    //             if(lCase.NewEquipmentRequired__c){
    //                 lCaseToInsertLst.add(getCase('EquipmentAndSupply', lCase.Id, lQueueMap, lEntitlementLst[0].Id));                       
    //             }
    //         }
    //         if(!lCaseToInsertLst.isEmpty()){
    //             // System.debug('lCaseToInsertLst --------> ' + lCaseToInsertLst);
    //             insert lCaseToInsertLst;    
    //         }
    //     } 
    // }

    // //Método auxiliar, utilizado no método startOperationalAnalysisAndDeployment para criação de casos filhos do fluxo de criação de novo serviço
    // public static Case getCase(String aType , Id aParentId, Map<String,Id> aQueueMap, Id aEntitlement) {
    //     Case lCase = new Case();
    //     lCase.ParentId = aParentId;
    //     lCase.Status = 'New';                   


    //     switch on aType {
    //         when 'ProjectionAndSizing' 
    //         {
    //             lCase.RecordTypeId = PROJECTION_AND_SIZING_SERVICE_RECTYPE;
    //             lCase.OwnerId = aQueueMap.get('ProjectionAndSizing');
    //             lCase.Subject = Label.ProjectionAndSizingLabel;
    //             lCase.EntitlementId = aEntitlement;
    //         }
    //         when 'ServicePricing' {
    //             lCase.RecordTypeId = SERVICE_PRICING_RECTYPE;
    //             lCase.OwnerId = aQueueMap.get('Pricing');
    //             lCase.Subject = Label.PricingLabel; 
    //             lCase.EntitlementId = aEntitlement;

    //         }
    //         when 'ContractReview' {
    //             lCase.RecordTypeId = CONTRACT_REVIEW_RECTYPE;
    //             lCase.OwnerId = aQueueMap.get('Contract');        
    //             lCase.Subject = Label.ContractReviewLabel;
    //             lCase.EntitlementId = aEntitlement;
    //         }
    //         when 'TrainingAnalysis' {
    //             lCase.RecordTypeId = TRAINING_ANALYSIS_RECTYPE;
    //             lCase.OwnerId = aQueueMap.get('Course');   
    //             lCase.Subject = Label.TraningReviewLabel;
    //             lCase.EntitlementId = aEntitlement;
    //         }
    //         when 'RiskAndCost' {
    //             lCase.RecordTypeId = SERVICE_DEPLOYMENT_RECTYPE;    
    //             lCase.Subject = Label.RiskAndCostLabel;
    //             lCase.OwnerId = aQueueMap.get('Contract'); 
    //             lCase.EntitlementId = aEntitlement;  
    //         }
    //         when 'School' {
    //             lCase.RecordTypeId = SERVICE_DEPLOYMENT_RECTYPE;  
    //             lCase.Subject = Label.SchoolLabel;
    //             lCase.OwnerId = aQueueMap.get('Course');
    //             lCase.EntitlementId = aEntitlement;
    //         }
    //         when 'Recruitment' {
    //             lCase.RecordTypeId = SERVICE_DEPLOYMENT_RECTYPE; 
    //             lCase.Subject = Label.RecruitmentLabel ; 
    //             lCase.OwnerId = aQueueMap.get('Recruitment');
    //             lCase.EntitlementId = aEntitlement;
    //         }
    //         when 'EquipmentAndSupply' {
    //             lCase.RecordTypeId = SERVICE_DEPLOYMENT_RECTYPE; 
    //             lCase.Subject = Label.EquipmentAndSupplyLabel; 
    //             lCase.OwnerId = aQueueMap.get('EquipmentAndSupply');
    //             lCase.EntitlementId = aEntitlement;                         
    //         }           
    //     }
    //     return lCase;
    // }

    public static void checkResults(Map<Id,Case> aNewCase){
        TriggerCheck.assert();

        Set<Id> lCaseId = new Set<Id>();
        for(Case lCase : aNewCase.values()){             
            if(lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE && TriggerCheck.isChangedFromTo(lCase, Case.Status, Label.EvaluateResultStatus, Label.FinalDecisionStatus)){
                lCaseId.add(lCase.Id);
            }
        }
        if(lCaseId.isEmpty()) return;

        for(Case lChildCase : [SELECT Id, ParentId, POCOutcome__c FROM Case WHERE ParentId IN : lCaseId AND RecordTypeId = :POC_REQUIREMENTS_RECTYPE]){
            if(String.isBlank(lChildCase.POCOutcome__c)) { 
                aNewCase.get(lChildCase.ParentId).addError(Label.ErrorAdvanceStatusPOCResults);
            }           
        }        
    }

    //Método que impede avançar o status dos casos do tipo "Análise de Portfólio", de "Implantação" para "Definição de Recursos" se os casos filhos gerados nessa fase não estiverem concluídos.
    public static void waitForDeployment(Map<Id,Case> aMapNew){
        TriggerCheck.assert();
        
        List<Case> lCaseToCheckLst = new List<Case>();
        for(Case lCase :aMapNew.values()){
            if(TriggerCheck.isChangedFromTo(lCase, Case.Status, Label.Status_Deployment, Label.Status_ResourcesDefinition) && lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE){
                lCaseToCheckLst.add(lCase);
            }
        }
        // System.debug('waitForDeployment: lCaseToCheckLst ------> ' + lCaseToCheckLst);
        if(lCaseToCheckLst.isEmpty()) return;

        Set<Id> lRequirementsSet = new Set<Id>();
        for(Case lRequirements :[SELECT Id, ParentId, Status FROM Case WHERE ParentId IN :lCaseToCheckLst AND RecordTypeId = :SERVICE_DEPLOYMENT_RECTYPE AND Status != :Label.Status_Concluded ORDER BY ParentId]){
            lRequirementsSet.add(lRequirements.ParentId);
        }        
        // System.debug('waitForDeployment: lRequirementsSet ------> ' + lRequirementsSet);
        if(lRequirementsSet.isEmpty()) return;
        
        for(Case lCase :lCaseToCheckLst){
            if(lRequirementsSet.contains(lCase.Id)){
                aMapNew.get(lCase.Id).addError(Label.ErrorWaitingResourceDefinitionMsg);
            }
        }
    }

    public static void activateService(List<Case> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lServiceToActivateSet = new Set<Id>();
        for(Case lCase :aNewLst){
            if(TriggerCheck.isChangedTo(lCase, Case.Status, Label.Status_Deployed) && lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE){
                lServiceToActivateSet.add(lCase.Service__c);
            }
        }
        if(lServiceToActivateSet.isEmpty()) return;
        List<Product2> lServiceLst = [SELECT Id, Status__c, Name__c FROM Product2 WHERE Id IN :lServiceToActivateSet];
        // ActivateService_cls lQueue = new ActivateService_cls();
        // lQueue.getRecords(lServiceLst);
    }

    public static void duplicateRuleCase (List<Case> aNewList){
        TriggerCheck.assert();
         
        List<Case> lNewList = new List<Case>();
        for(Case lNewCase:aNewList){
            if(lNewCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE ||lNewCase.RecordTypeId == REMOVE_SERVICE_RECTYPE){
                lNewList.add(lNewCase);
            }
        }
        if(lNewList.isEmpty()) return;
       
        Map<Id,Case> mapPortCase = New Map<id,Case>();
        Map<Id,Case> mapRemoveCase = New Map<id,Case>();
        
        List<Case> lCaseList = [SELECT Id, Service__c, Status, RecordTypeId FROM Case 
                                WHERE RecordTypeId = :PORTFOLIO_ANALYSIS_RECTYPE OR RecordTypeId = :REMOVE_SERVICE_RECTYPE];
        for(Case lCase : lCaseList){
            if(mapPortCase.containsKey(lCase.Service__c) || mapRemoveCase.containsKey(lCase.Service__c)){
                if(lCase.Status != Label.Status_NotDeployed && lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE){
                    mapPortCase.put(lCase.Service__c,lCase); 
                }
                else if(lCase.Status != Label.Status_NotWithdrawn && lcase.RecordTypeId == REMOVE_SERVICE_RECTYPE){
                    mapRemoveCase.put(lCase.Service__c,lCase); 
                }
            }
            else if(!mapPortCase.containsKey(lCase.Service__c) || !mapRemoveCase.containsKey(lCase.Service__c)){
                if(lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE){
                    mapPortCase.put(lCase.Service__c,lCase);
                }
                else if(lcase.RecordTypeId == REMOVE_SERVICE_RECTYPE){
                    mapRemoveCase.put(lCase.Service__c,lCase);
                }                   
            }
        }
         
        Case lCaseVal = New Case();
        for(Case lNewCase:lNewList){
            if(lNewCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE){
                lCaseVal = mapPortCase.get(lNewCase.Service__c);
                if(mapPortCase.containsKey(lNewCase.Service__c)){
                    if(lNewCase.Service__c == lCaseVal.Service__c && lCaseVal.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE 
                        && lCaseVal.Status != Label.Status_NotDeployed && lCaseVal.Status != Label.Status_Withdrawn){
                     	lNewCase.addError(Label.ErrorServiceDeployed);
                 	}
                }
            }
             else if(lNewCase.RecordTypeId == REMOVE_SERVICE_RECTYPE){
                 lCaseVal = mapRemoveCase.get(lNewCase.Service__c);
                if(mapRemoveCase.containsKey(lNewCase.Service__c)){
                    if(lNewCase.Service__c == lCaseVal.Service__c && lCaseVal.RecordTypeId == REMOVE_SERVICE_RECTYPE 
                        && lCaseVal.Status != Label.Status_NotWithdrawn && lCaseVal.Status != Label.DeployedStatus){
                     	lNewCase.addError(Label.ErrorServiceWithdrawn);
                 	}
                }
            }
        }
    }

    public static void valueFieldChildCase(List<Case> aNewList, Map<Id,Case> aOldList){
        TriggerCheck.assert();

        Map<Id,Case> lCaseMap = new Map<Id,Case>();
        for(Case lCase: aNewList){
            if(lCase.Assignments__c != aOldList.get(lCase.Id).Assignments__c  && lCase.RecordTypeId == PROTOTYPING_RECTYPE){
                lCaseMap.put(lCase.Id,lCase);
            }
        }
        if(lCaseMap.isEmpty()) return;

        List<Case> lChildCaseList = [SELECT Id,ParentId , Assignments__c FROM Case WHERE ParentId IN: lCaseMap.keySet()];
        if(lChildCaseList.isEmpty()) return;

        for(Case lChildCase: lChildCaseList){
            lChildCase.Assignments__c = lCaseMap.get(lChildCase.ParentId).Assignments__c;
        }
        update lChildCaseList;
    }
    
    /*
    Método para setar as regras de resposta da regra de atribuição, por uma falha o salesforce não envia o email
    da regra de atribuição, então o prorio Salesforce recomenda este workaround.
    https://help.salesforce.com/articleView?id=000334297&type=1&mode=1
    */
    public static void AutoResponseRulesUsingRESTAPI(List<Case> aNewLst) {

        List<Profile> lProfileIntegrationLst = [SELECT Id, Name FROM Profile WHERE Name = :INTEGRATION];
        
        // Somente avança se o perfil do usuário criador do caso for integração
        if(lProfileIntegrationLst.isEmpty() || UserInfo.getProfileId() != lProfileIntegrationLst[0].Id) return;

        List<Case> lCaseToAutoResponseEmailLst = new List<Case>(); 
        for(Case lCase: aNewLst){
            if(lCase.RecordTypeId == SUPPORT_APIS_RECTYPE){
                lCaseToAutoResponseEmailLst.add(new Case(Id = lCase.Id));
            }
        }

        if(lCaseToAutoResponseEmailLst.isEmpty()) return;

        Database.DMLOptions lAutoResponseOptions = new Database.DMLOptions(); 
        lAutoResponseOptions.AssignmentRuleHeader.useDefaultRule = true;
        lAutoResponseOptions.EmailHeader.triggerUserEmail = true;
        Database.update(lCaseToAutoResponseEmailLst, lAutoResponseOptions); 
    }

    /*public static void valueFieldAssigmentsChildCase(List<Case> aNewList){
        TriggerCheck.assert();
        
       
        Set<Id> lCaseIdSet = new Set<Id>();
        Set<Id> lParentCaseIdSet = new Set<Id>();
        for(Case lCase: aNewList){
            if(lCase.RecordTypeId == IMPACT_ANALYSIS_RECTYPE){
                lCaseIdSet.add(lCase.Id);
                lParentCaseIdSet.add(lCase.ParentId);
            }
        }
        if(lParentCaseIdSet.isEmpty()) return;
        List<Case> lCaseChildList = [SELECT Assignments__c, ParentId FROM Case WHERE Id IN :lCaseIdSet];
        
        Map<Id,Case> lCaseMap = new Map<Id,Case>();
        List<Case> lCaseParent = [SELECT Id, Assignments__c FROM Case WHERE Id IN: lParentCaseIdSet];
        if(lCaseParent.isEmpty()) return;
        
        for(Case lCaseP: lCaseParent){
            lCaseMap.put(lCaseP.Id,lCaseP);
        }
        
        for(Case lCaseChild: lCaseChildList){
            lCaseChild.Assignments__c = lCaseMap.get(lCaseChild.ParentId).Assignments__c;
        }
        update lCaseChildList;
    }*/
}