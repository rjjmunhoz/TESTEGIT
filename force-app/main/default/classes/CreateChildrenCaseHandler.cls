public class CreateChildrenCaseHandler {

    private static final Id PORTFOLIO_ANALYSIS_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PortfolioAnalysis').getRecordTypeId();
    private static final Id PROJECTION_AND_SIZING_SERVICE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ProjectionAndSizingService').getRecordTypeId();
    private static final Id SERVICE_PRICING_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ServicePricing').getRecordTypeId();
    private static final Id CONTRACT_REVIEW_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ContractReview').getRecordTypeId();
    private static final Id TRAINING_ANALYSIS_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TrainingAnalysis').getRecordTypeId();
    private static final Id SERVICE_DEPLOYMENT_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ServiceDeployment').getRecordTypeId();
    private static final Id PROTOTYPING_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prototyping').getRecordTypeId();
    private static final Id IMPACT_ANALYSIS_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ImpactAnalysis').getRecordTypeId();

    public static void startOperationalAnalysisAndDeployment(List<Case> aNewLst){
        TriggerCheck.assert();

        List<Case> lParentCaseLst = new List<Case>();
        for(Case lCase :aNewLst){
            if((TriggerCheck.isChangedTo(lCase, Case.Status, 'Análise Operacional') && lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE &&
            (lCase.Ability__c != 'Não será avaliado(a)' || lCase.Parts__c != 'Não será avaliado(a)' || lCase.Problem__c != 'Não será avaliado(a)' || 
            lCase.Modal__c != 'Não será avaliado(a)' || lCase.OperationalService__c != 'Não será avaliado(a)' || lCase.Specialty__c != 'Não será avaliado(a)'))
            || (TriggerCheck.isChangedTo(lCase, Case.Status, 'Em Implantação') && lCase.RecordTypeId == PORTFOLIO_ANALYSIS_RECTYPE)){
                lParentCaseLst.add(lCase);
            }
        }
        if(lParentCaseLst.isEmpty()) return;

        Map<String,Id> lQueueMap = new  Map<String,Id>();
        for(Group lQueue : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND (DeveloperName = 'ProjectionAndSizing' OR DeveloperName = 'Pricing' OR DeveloperName = 'Contract' OR DeveloperName = 'Course' OR DeveloperName = 'Recruitment' OR DeveloperName = 'EquipmentAndSupply')]){
            lQueueMap.put(lQueue.DeveloperName,lQueue.Id);
        }
        List<Entitlement> lEntitlementLst = [SELECT Id FROM Entitlement WHERE Name = 'Tempo de resolução Caso'];
        
        List<Case> lCaseToInsertLst;
        Map<Id,Case> lServiceDeploymentCaseMap = new Map<Id,Case>();
        for(Case lCase :lParentCaseLst){
            if(lCase.Status == 'Análise Operacional'){
                if(lCase.OperationalService__c != 'Não será avaliado(a)' || lCase.Specialty__c != 'Não será avaliado(a)' || lCase.Modal__c != 'Não será avaliado(a)'){           
                    lCaseToInsertLst = new List<Case>{getCase('ProjectionAndSizing' , lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('ServicePricing', lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('ContractReview', lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('TrainingAnalysis', lCase.Id, lQueueMap, lEntitlementLst[0].Id)};
                }
                else if(lCase.Ability__c != 'Não será avaliado(a)' && lCase.Problem__c != 'Não será avaliado(a)'){
                    lCaseToInsertLst = new List<Case>{getCase('ProjectionAndSizing' , lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('ServicePricing', lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('TrainingAnalysis', lCase.Id, lQueueMap, lEntitlementLst[0].Id)};
                }
                else if(lCase.Ability__c != 'Não será avaliado(a)'){
                    lCaseToInsertLst = new List<Case>{getCase('ProjectionAndSizing' , lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('TrainingAnalysis', lCase.Id, lQueueMap, lEntitlementLst[0].Id)};
                }
                else if(lCase.Problem__c != 'Não será avaliado(a)'){
                    lCaseToInsertLst = new List<Case>{getCase('ServicePricing', lCase.Id, lQueueMap, lEntitlementLst[0].Id), getCase('TrainingAnalysis', lCase.Id, lQueueMap, lEntitlementLst[0].Id)};
                }
                else if(lCase.Parts__c != 'Não será avaliado(a)'){
                    lCaseToInsertLst = new List<Case>{getCase('TrainingAnalysis', lCase.Id, lQueueMap, lEntitlementLst[0].Id)};
                }
            }
            else{
                lServiceDeploymentCaseMap.put(lCase.Id,lCase);
            }
        }

        if(lServiceDeploymentCaseMap.isEmpty()){
            // System.debug('lCaseToInsertLst --------> ' + lCaseToInsertLst);
            insert lCaseToInsertLst; 
        }
        else{
            if(lCaseToInsertLst == null){
                lCaseToInsertLst = new List<Case>();
            }
            for(Case lCase :[SELECT Id, ParentId, NeedReviewContract__c, NeedReviewTraining__c, RecordTypeId FROM Case WHERE ParentId IN :lServiceDeploymentCaseMap.keySet() AND (RecordtypeId = :CONTRACT_REVIEW_RECTYPE OR RecordtypeId = :TRAINING_ANALYSIS_RECTYPE) ORDER BY ParentId]){
                if(lCase.RecordTypeId == CONTRACT_REVIEW_RECTYPE){
                    if(lCase.NeedReviewContract__c){
                        lCaseToInsertLst.add(getCase('RiskAndCost', lCase.ParentId, lQueueMap, lEntitlementLst[0].Id));
                    }
                    continue;
                }
                if(lCase.RecordTypeId == TRAINING_ANALYSIS_RECTYPE && lCase.NeedReviewTraining__c){ 
                    lCaseToInsertLst.add(getCase('School', lCase.ParentId, lQueueMap, lEntitlementLst[0].Id));           
                }
            }
            for(Case lCase :lServiceDeploymentCaseMap.values()){

                lCaseToInsertLst.add(getCase('Recruitment', lCase.Id, lQueueMap, lEntitlementLst[0].Id));           

                if(lCase.NewEquipmentRequired__c){
                    lCaseToInsertLst.add(getCase('EquipmentAndSupply', lCase.Id, lQueueMap, lEntitlementLst[0].Id));                       
                }
            }
            if(!lCaseToInsertLst.isEmpty()){
                // System.debug('lCaseToInsertLst --------> ' + lCaseToInsertLst);
                insert lCaseToInsertLst;    
            }
        } 
    }

    //Método auxiliar, utilizado no método startOperationalAnalysisAndDeployment para criação de casos filhos do fluxo de criação de novo serviço
    public static Case getCase(String aType , Id aParentId, Map<String,Id> aQueueMap, Id aEntitlement) {
        Case lCase = new Case();
        lCase.ParentId = aParentId;
        lCase.Status = 'New';                   


        switch on aType {
            when 'ProjectionAndSizing' 
            {
                lCase.RecordTypeId = PROJECTION_AND_SIZING_SERVICE_RECTYPE;
                lCase.OwnerId = aQueueMap.get('ProjectionAndSizing');
                lCase.Subject = Label.ProjectionAndSizingLabel;
                lCase.EntitlementId = aEntitlement;
            }
            when 'ServicePricing' {
                lCase.RecordTypeId = SERVICE_PRICING_RECTYPE;
                lCase.OwnerId = aQueueMap.get('Pricing');
                lCase.Subject = Label.PricingLabel; 
                lCase.EntitlementId = aEntitlement;

            }
            when 'ContractReview' {
                lCase.RecordTypeId = CONTRACT_REVIEW_RECTYPE;
                lCase.OwnerId = aQueueMap.get('Contract');        
                lCase.Subject = Label.ContractReviewLabel;
                lCase.EntitlementId = aEntitlement;
            }
            when 'TrainingAnalysis' {
                lCase.RecordTypeId = TRAINING_ANALYSIS_RECTYPE;
                lCase.OwnerId = aQueueMap.get('Course');   
                lCase.Subject = Label.TraningReviewLabel;
                lCase.EntitlementId = aEntitlement;
            }
            when 'RiskAndCost' {
                lCase.RecordTypeId = SERVICE_DEPLOYMENT_RECTYPE;    
                lCase.Subject = Label.RiskAndCostLabel;
                lCase.OwnerId = aQueueMap.get('Contract'); 
                lCase.EntitlementId = aEntitlement;  
            }
            when 'School' {
                lCase.RecordTypeId = SERVICE_DEPLOYMENT_RECTYPE;  
                lCase.Subject = Label.SchoolLabel;
                lCase.OwnerId = aQueueMap.get('Course');
                lCase.EntitlementId = aEntitlement;
            }
            when 'Recruitment' {
                lCase.RecordTypeId = SERVICE_DEPLOYMENT_RECTYPE; 
                lCase.Subject = Label.RecruitmentLabel ; 
                lCase.OwnerId = aQueueMap.get('Recruitment');
                lCase.EntitlementId = aEntitlement;
            }
            when 'EquipmentAndSupply' {
                lCase.RecordTypeId = SERVICE_DEPLOYMENT_RECTYPE; 
                lCase.Subject = Label.EquipmentAndSupplyLabel; 
                lCase.OwnerId = aQueueMap.get('EquipmentAndSupply');
                lCase.EntitlementId = aEntitlement;                         
            }           
        }
        return lCase;
    }

    public static void activateSelectedAreas(List<Case> aNewLst){
        TriggerCheck.assert();

        List<Case> lCaseLst = new List<Case>();
        for(Case lCase : aNewLst){
            if(TriggerCheck.isChanged(lCase, Case.TriggeredAreas__c) && lCase.RecordTypeId == PROTOTYPING_RECTYPE){
                lCaseLst.add(lCase);
            }
        }
        if(lCaseLst.isEmpty()) return;

        Map<String,Id> lQueueMap = new  Map<String,Id>();
        for(Group lQueue : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND (DeveloperName = 'Course' OR DeveloperName = 'Recruitment' OR DeveloperName = 'CostRiskManagement' OR DeveloperName = 'OperationalEfficiency' OR DeveloperName = 'ManagementInformation' OR DeveloperName = 'QualityMonitoring' OR DeveloperName = 'ProjectsAndTechnologicalSolutions' OR DeveloperName = 'Relationship' OR DeveloperName = 'Support' OR DeveloperName = 'SuppliesManagement' OR DeveloperName = 'Planning' OR DeveloperName = 'FinancialManagement' OR DeveloperName = 'SAC' OR DeveloperName = 'InternClient')]){
            lQueueMap.put(lQueue.DeveloperName,lQueue.Id);
        }
        List<Entitlement> lEntitlementLst = [SELECT Id FROM Entitlement WHERE Name = 'Tempo de resolução Caso'];
        List<Case> lCaseToUpdate = [SELECT Assignments__c, TriggeredAreas__c, AuxiliarTriggeredArea__c FROM Case WHERE Id IN :lCaseLst];
        List<Case> lNewChildrenCase = new List<Case>();
        for(Case lCase : lCaseToUpdate){
            if(lCase.TriggeredAreas__c != null){
                if(lCase.TriggeredAreas__c.contains('Cliente Interno') && !lCase.AuxiliarTriggeredArea__c.contains('Cliente Interno')){
                    lCase.AuxiliarTriggeredArea__c += 'Cliente Interno, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Cliente Interno', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'InternClient', lCase.Assignments__c));
                }

                if(lCase.TriggeredAreas__c.contains('Eficiência operacional') && !lCase.AuxiliarTriggeredArea__c.contains('Eficiência operacional')){
                    lCase.AuxiliarTriggeredArea__c += 'Eficiência operacional, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Eficiência operacional', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'OperationalEfficiency', lCase.Assignments__c));
                }    
    
                if(lCase.TriggeredAreas__c.contains('Escola') && !lCase.AuxiliarTriggeredArea__c.contains('Escola')){
                    lCase.AuxiliarTriggeredArea__c += 'Escola, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Escola', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'Course', lCase.Assignments__c));
                } 

                if(lCase.TriggeredAreas__c.contains('Gestão de custos e riscos') && !lCase.AuxiliarTriggeredArea__c.contains('Gestão de custos e riscos')){
                    lCase.AuxiliarTriggeredArea__c += 'Gestão de custos e riscos, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Gestão de custos e riscos', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'CostRiskManagement', lCase.Assignments__c));          
                } 

                if(lCase.TriggeredAreas__c.contains('Informações gerenciais') && !lCase.AuxiliarTriggeredArea__c.contains('Informações gerenciais')){
                    lCase.AuxiliarTriggeredArea__c += 'Informações gerenciais, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Informações gerenciais', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'ManagementInformation', lCase.Assignments__c));          
                } 

                if(lCase.TriggeredAreas__c.contains('Monitoria da qualidade') && !lCase.AuxiliarTriggeredArea__c.contains('Monitoria da qualidade')){
                    lCase.AuxiliarTriggeredArea__c += 'Monitoria da qualidade, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Monitoria da qualidade', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'QualityMonitoring', lCase.Assignments__c));
                } 

                if(lCase.TriggeredAreas__c.contains('Projetos e soluções tecnológicas') && !lCase.AuxiliarTriggeredArea__c.contains('Projetos e soluções tecnológicas')){
                    lCase.AuxiliarTriggeredArea__c += 'Projetos e soluções tecnológicas, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Projetos e soluções tecnológicas', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'ProjectsAndTechnologicalSolutions', lCase.Assignments__c));
                } 

                if(lCase.TriggeredAreas__c.contains('Relacionamento') && !lCase.AuxiliarTriggeredArea__c.contains('Relacionamento')){
                    lCase.AuxiliarTriggeredArea__c += 'Relacionamento, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Relacionamento', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'Relationship', lCase.Assignments__c));
                } 

                if(lCase.TriggeredAreas__c.contains('Seleção') && !lCase.AuxiliarTriggeredArea__c.contains('Seleção')){
                    lCase.AuxiliarTriggeredArea__c += 'Seleção, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Seleção', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'Recruitment', lCase.Assignments__c));
                } 

                if(lCase.TriggeredAreas__c.contains('Sustentação') && !lCase.AuxiliarTriggeredArea__c.contains('Sustentação')){
                    lCase.AuxiliarTriggeredArea__c += 'Sustentação, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Sustentação', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'Support', lCase.Assignments__c));
                } 

                if(lCase.TriggeredAreas__c.contains('Gestão de insumos') && !lCase.AuxiliarTriggeredArea__c.contains('Gestão de insumos')){
                    lCase.AuxiliarTriggeredArea__c += 'Gestão de insumos, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Gestão de insumos', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'SuppliesManagement', lCase.Assignments__c));
                } 

                if(lCase.TriggeredAreas__c.contains('Planejamento') && !lCase.AuxiliarTriggeredArea__c.contains('Planejamento')){
                    lCase.AuxiliarTriggeredArea__c += 'Planejamento, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Planejamento', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'Planning', lCase.Assignments__c));
                } 

                if(lCase.TriggeredAreas__c.contains('Gestão financeira') && !lCase.AuxiliarTriggeredArea__c.contains('Gestão financeira')){
                    lCase.AuxiliarTriggeredArea__c += 'Gestão financeira, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('Gestão financeira', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'FinancialManagement', lCase.Assignments__c));
                } 

                if(lCase.TriggeredAreas__c.contains('SAC') && !lCase.AuxiliarTriggeredArea__c.contains('SAC')){
                    lCase.AuxiliarTriggeredArea__c += 'SAC, ';
                    lNewChildrenCase.add(createImpactAnalysisCase('SAC', lCase.Id, lEntitlementLst.get(0).Id, lQueueMap, 'SAC', lCase.Assignments__c));
                } 
            }
            System.debug(lNewChildrenCase.size());
            insert lNewChildrenCase;
            update lCaseToUpdate;


        }
    }

    public static Case createImpactAnalysisCase(String aSubject, Id aParentId, Id aEntitlement, Map<String,Id> aQueueMap, String aQueueName, String aAssignments){
        Case lCase = new Case();
        lCase.Status = 'new';
        lCase.ParentId = aParentId;
        lCase.RecordTypeId = IMPACT_ANALYSIS_RECTYPE;
        lCase.OwnerId = aQueueMap.get(aQueueName);
        lCase.Subject = 'Análise de Impacto - ' + aSubject;
        lCase.EntitlementId = aEntitlement;
        lCase.Assignments__c = aAssignments;
        return lCase;
    }
}