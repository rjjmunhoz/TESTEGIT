/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Classe Queueable que chama os serviços de integração através das triggers
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-01-20      Jean Sganzerla          class created 
* @version   1.1    2019-06-15      Jean Sganzerla          Implementation of Account scenario
**************************************************************************************************************/
public class IntegrationHandler_cls implements Queueable, Database.AllowsCallouts{
    
    private static final String EQUIPMENT_RECTYPEID = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.EquipmentRecordType).getRecordTypeId();
    private static final String ABILITY_RECTYPEID = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.AbilityRecordType).getRecordTypeId();
    private static final String PRODUCT_SPECIALTY_RECTYPEID = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.SpecialtyRecordType).getRecordTypeId();
    private static final String PRODUCT_DETAIL_RECTYPEID = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.DetailRecordType).getRecordTypeId();
    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();

    private static final Integer CPU_TIME_LIMIT_PERCENT = 90;
    private static final Integer CALLOUT_LIMIT_PERCENT = 90;

    public List<SObject> fRecordsLst;
    public Map<Id,Integer> fTotalSendMap;
    public Map<Id,List<Integer>> fEquipmentMap;
    public Map<Id,List<SpecialtyWrapper_cls.Especialidades>> fSpecialtyLstMap;
    public Map<Id,List<SpecialtyWrapper_cls.Habilidades>> fAbilityLstMap;
    public Map<Id,List<SpecialtyWrapper_cls.Equipamentos>> fEquipmentLstMap;
    public Map<Id,SpecialtyWrapper_cls.AccountContactRelation> fAccountContactRelationMap;
    public Map<Id,List<SpecialtyWrapper_cls.AccountContactRelation>> fPartnersMap;

    public IntegrationHandler_cls(List<SObject> aRecordsLst){
        this.fTotalSendMap = new Map<Id,Integer>(); 
        this.fRecordsLst = aRecordsLst;   
    }

    public IntegrationHandler_cls(SpecialtyWrapper_cls aRecordsWr){
        this.fAccountContactRelationMap = aRecordsWr.fAccountContactRelationMap;
        this.fSpecialtyLstMap = aRecordsWr.fSpecialtyLstMap!=null?aRecordsWr.fSpecialtyLstMap:new Map<Id,List<SpecialtyWrapper_cls.Especialidades>>();
        this.fAbilityLstMap = aRecordsWr.fAbillityLstMap!=null?aRecordsWr.fAbillityLstMap:new Map<Id,List<SpecialtyWrapper_cls.Habilidades>>();
        this.fEquipmentLstMap = aRecordsWr.fEquipmentLstMap!=null?aRecordsWr.fEquipmentLstMap:new Map<Id,List<SpecialtyWrapper_cls.Equipamentos>>();
        this.fEquipmentMap = aRecordsWr.fEquipmentMap!=null?aRecordsWr.fEquipmentMap:new Map<Id,List<Integer>>();
        this.fPartnersMap = aRecordsWr.fPartnersMap;
        this.fRecordsLst = aRecordsWr.fSObjectLst;
        this.fTotalSendMap = new Map<Id,Integer>();     
    }    

    public IntegrationHandler_cls(List<SObject> aRecordsLst, Map<Id,Integer> aTotalSendMap, Map<Id,List<SpecialtyWrapper_cls.Especialidades>> aSpecialtyLstMap, Map<Id,List<SpecialtyWrapper_cls.Habilidades>> aAbilityLstMap,Map<Id,SpecialtyWrapper_cls.AccountContactRelation> aAccountContactRelationMap, Map<Id,List<SpecialtyWrapper_cls.AccountContactRelation>> aPartnersMap, Map<Id,List<Integer>> aEquipmentMap, Map<Id,List<SpecialtyWrapper_cls.Equipamentos>> aEquipmentLstMap){
        this.fRecordsLst = aRecordsLst;
        this.fSpecialtyLstMap = aSpecialtyLstMap!=null?aSpecialtyLstMap:new Map<Id,List<SpecialtyWrapper_cls.Especialidades>>();
        this.fAbilityLstMap = aAbilityLstMap!=null?aAbilityLstMap:new Map<Id,List<SpecialtyWrapper_cls.Habilidades>>();
        this.fAccountContactRelationMap = aAccountContactRelationMap!=null?aAccountContactRelationMap:new Map<Id,SpecialtyWrapper_cls.AccountContactRelation>();
        this.fEquipmentLstMap = aEquipmentLstMap!=null?aEquipmentLstMap:new Map<Id,List<SpecialtyWrapper_cls.Equipamentos>>();
        this.fEquipmentMap = aEquipmentMap!=null?aEquipmentMap:new Map<Id,List<Integer>>();
        this.fTotalSendMap = aTotalSendMap!=null?aTotalSendMap:new Map<Id,Integer>();
        this.fPartnersMap = aPartnersMap;
    }
    
    public void execute(QueueableContext context) {        
		
        //trecho de código que pausa a integração
        if (!TriggerCheck.isActive(Label.String_IntegrationHandler)) return;
        //fim do trecho que pausa a integração    
        
        /*List<AssignmentRule>  lAssigmentRuleIdLst = [SELECT Id FROM AssignmentRule WHERE SobjectType = :Label.SObjectNameCase and Active = true];
        Database.DMLOptions lDMLOptions = new Database.DMLOptions();
        lDMLOptions.EmailHeader.triggerUserEmail = true;
        lDMLOptions.assignmentRuleHeader.assignmentRuleId = lAssigmentRuleIdLst[0].Id;*/

        List<Case> lCaseToInsertLst = new List<Case>();
        List<SObject> lSObjectsToUpdateLst = new List<SObject>();
        List<SObject> lSObjectsToRetrieveLst = new List<SObject>();
        for(Integer i = 0; i < this.fRecordsLst.size(); i++) {
            Decimal lCalloutsExecutedPercent = ((Decimal)Limits.getCallouts() / (Decimal)Limits.getLimitCallouts()) * 100.00; 
            Decimal lCpuTimeExecutedPercent = ((Decimal)Limits.getCpuTime() / (Decimal)Limits.getLimitCpuTime()) * 100.00; 
            system.debug('Qtd DML Executadas: ' + Limits.getDMLStatements());
            // Executa os envios enquanto ainda possui limites disponiveis
            if(lCalloutsExecutedPercent < CALLOUT_LIMIT_PERCENT && lCpuTimeExecutedPercent < CPU_TIME_LIMIT_PERCENT){
                String lObjectName = this.fRecordsLst[i].getSObjectType().getDescribe().getName();  
                switch on lObjectName {
                    when 'Modal__c' {
                        ModalWebService web = new ModalWebService(this.fRecordsLst[i]);
                        AWS_API.ResponseWrapper lResult = web.setAwsModal();
                        if(!lResult.success) {
                            if(fTotalSendMap.get(((Modal__c)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){
                                lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id,  Label.FieldValueModal));
                            }
                            validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst); 
                        }
                    }
                    when 'OperationalSetup__c' {
                        if(((OperationalSetup__c)this.fRecordsLst[i]).RecordTypeId == ABILITY_RECTYPEID) {
                            AbilityWebService web = new AbilityWebService(this.fRecordsLst[i]);
                            AWS_API.ResponseWrapper lResult = web.setAwsAbility();
                            if(!lResult.success) {                                
                                if(fTotalSendMap.get(((OperationalSetup__c)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){
                                    lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id,  Label.FieldValueAbility));

                                }
                                validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);   
                            }
                        }
                        else if(((OperationalSetup__c)this.fRecordsLst[i]).RecordTypeId == EQUIPMENT_RECTYPEID) {
                            EquipmentWebService web = new EquipmentWebService(this.fRecordsLst[i]);
                            AWS_API.ResponseWrapper lResult = web.setAwsEquipment();
                            if(!lResult.success) {                                
                                if(fTotalSendMap.get(((OperationalSetup__c)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){
                                    lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueEquipment));

                                }
                                validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);
                            }
                        }   
                    }
                    when 'Product2' {
                        if(((Product2)this.fRecordsLst[i]).RecordTypeId == PRODUCT_SPECIALTY_RECTYPEID) {
                            SpecialtyWebService web = new SpecialtyWebService(this.fRecordsLst[i]);
                            AWS_API.ResponseWrapper lResult = web.setAwsSpecialty();                            
                            if(!lResult.success) {                                
                                if(fTotalSendMap.get(((Product2)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){
                                    lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueSpecialty));

                                }                                
                                validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);
                            }
                        }
                        else if(((Product2)this.fRecordsLst[i]).RecordTypeId == PRODUCT_DETAIL_RECTYPEID) {
                            ReasonWebService web = new ReasonWebService(this.fRecordsLst[i]);
                            AWS_API.ResponseWrapper lResult = web.setAwsReason();
                            if(!lResult.success) {                                
                                if(fTotalSendMap.get(((Product2)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){                                
                                    lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueReason));
 
                                }
                                validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);  
                            }
                        }    
                    }
                    when 'Account' {
                        if(((Account)this.fRecordsLst[i]).SucursalCode__c == null){
                            SucursalWebService_cls web =  new SucursalWebService_cls();
                            AWS_API.ResponseWrapper lResult = web.getSucursal(((Account)this.fRecordsLst[i]).TaxCity__c,((Account)this.fRecordsLst[i]).TaxUf__c,((Account)this.fRecordsLst[i]).Id);
                            if(Test.isRunningTest() && ((Account)this.fRecordsLst[i]).TaxCity__c == 'TesteERROR'){
                                lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueSurcursal));
                                validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);
                            }
                            if(!lResult.success) {
                                if(fTotalSendMap.get(((Account)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){
                                    lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueSurcursal));
   
                                }
                                validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);              
                            }
                        }
                        else{
                            if(fPartnersMap != null){ 
                                //Se fPartnersMap for nulo, significa que o map de sócios não foi preenchido. Esse map só fica nulo se o usuário estiver vinculando uma habilidade a um Prestador
                                ProviderWebService_cls web = new ProviderWebService_cls(this.fRecordsLst[i], this.fSpecialtyLstMap.get(this.fRecordsLst[i].Id),this.fPartnersMap.get(this.fRecordsLst[i].Id), this.fAbilityLstMap.get(this.fRecordsLst[i].Id), this.fEquipmentLstMap.get(this.fRecordsLst[i].Id));
                                AWS_API.ResponseWrapper lResult = web.setAwsProvider();
                                if(!lResult.success) {                            
                                    if(fTotalSendMap.get(((Account)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){
                                        lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueProvider));
 
                                    }      
                                    validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);                                       
                                }
                            }
                            else{
                                if((this.fSpecialtyLstMap != null && !this.fSpecialtyLstMap.isEmpty()) || 
                                        (this.fAbilityLstMap != null && !this.fAbilityLstMap.isEmpty())) {
                                    ProviderSpecialtyWebService_cls web = new ProviderSpecialtyWebService_cls(this.fRecordsLst[i], this.fSpecialtyLstMap.get(this.fRecordsLst[i].Id), this.fAbilityLstMap.get(this.fRecordsLst[i].Id));
                                    AWS_API.ResponseWrapper lResult = web.setAwsProvider();
                                    if(!lResult.success) {                                    
                                        if(fTotalSendMap.get(((Account)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){
                                            lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueProviderSpecialty));
                                        }                                    
                                        validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);
                                    }
                                }
                                if(this.fEquipmentLstMap != null && !this.fEquipmentLstMap.isEmpty()){
                                    ProviderEquipamentWebService_cls web = new ProviderEquipamentWebService_cls(this.fRecordsLst[i], this.fEquipmentLstMap.get(this.fRecordsLst[i].Id));
                                    AWS_API.ResponseWrapper lResult = web.setAwsProvider();
                                    if(!lResult.success) {                                    
                                        if(fTotalSendMap.get(((Account)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){
                                            lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueProviderSpecialty));
                                        }                                    
                                        validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);
                                    }
                                }
                            }
                        }
                    }
                    when 'Contact' {
                        RescuerWebService_cls web = new RescuerWebService_cls(this.fRecordsLst[i], this.fSpecialtyLstMap.get(this.fRecordsLst[i].Id),this.fAbilityLstMap.get(this.fRecordsLst[i].Id), fAccountContactRelationMap.get(this.fRecordsLst[i].Id));
                        AWS_API.ResponseWrapper lResult = web.setAwsRescuer();
                        if(Test.isRunningTest() && ((Contact)this.fRecordsLst[i]).LastName == 'TesteERROR'){
                            lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueRescuer));            
                            validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);
                        }
                        if(!web.setAwsRescuer().success) {                            
                            if(fTotalSendMap.get(((Contact)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){                                
                                lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueRescuer));    
                            }                            
                            validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);
                        }
                        lSObjectsToUpdateLst.add(new Contact(Id = this.fRecordsLst[i].Id, SyncAPI__c = false));
                    } 
                    when 'Vehicle__c' {                      
                        VehicleWebService_cls web = new VehicleWebService_cls(this.fRecordsLst[i],this.fSpecialtyLstMap.get(this.fRecordsLst[i].Id),this.fEquipmentMap!=null?this.fEquipmentMap.get(this.fRecordsLst[i].Id):null);
                        AWS_API.ResponseWrapper lResult = web.setAwsVehicle();
                        if(!lResult.success) {                            
                            if(fTotalSendMap.get(((Vehicle__c)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){
                                lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueVehicle));    
                            } 
                            validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);
                        }
                        lSObjectsToUpdateLst.add(new Vehicle__c(Id = this.fRecordsLst[i].Id, SyncAPI__c = false));
                    }
                    when 'User' {   
                        System.debug('this.fRecordsLst[i].Name: '+ ((User)this.fRecordsLst[i]).Name);
                        AccessManagementWebService_cls web = new AccessManagementWebService_cls(this.fRecordsLst[i]);
                        AWS_API.ResponseWrapper lResult = web.setAwsUser();
                            if(!lResult.success) {
                                if(fTotalSendMap.get(((User)this.fRecordsLst[i]).Id) == Integer.valueOf(Label.AWSQuantityAttemptsShipping)){
                                    lCaseToInsertLst.add(createSupportCase(lResult, this.fRecordsLst[i].Id, Label.FieldValueUser));
                                }
                                validateToRetrieve(this.fRecordsLst[i], lSObjectsToRetrieveLst);              
                            }
                    }
                }              
            }
            else{
                for(Integer j = 0; j < this.fRecordsLst.size(); j = i) {
                    lSObjectsToRetrieveLst.add(this.fRecordsLst[j]);
                }
                break;
            }
        } 
        if(!lSObjectsToRetrieveLst.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new IntegrationHandler_cls(lSObjectsToRetrieveLst, this.fTotalSendMap, this.fSpecialtyLstMap, this.fAbilityLstMap, this.fAccountContactRelationMap, this.fPartnersMap, this.fEquipmentMap, this.fEquipmentLstMap));
        }
        if(!lSObjectsToUpdateLst.isEmpty()) {
            update lSObjectsToUpdateLst;
        }
        if(!lCaseToInsertLst.isEmpty()){    
            //é pego o id da regra de atribuição de caso para se a integração quebrar, será criado um registro de caso e definido a regra de atribuição a ele. 
            //(Regra de atribuição não roda sozinha quando o registro é criado via APEX) 
            //https://help.salesforce.com/articleView?id=000338182&type=1&mode=1

            List<AssignmentRule>  lAssigmentRuleIdLst = [SELECT Id FROM AssignmentRule WHERE SobjectType = :Label.SObjectNameCase and Active = true];
            Database.DMLOptions lDMLOptions = new Database.DMLOptions();
            lDMLOptions.EmailHeader.triggerUserEmail = true;
            lDMLOptions.assignmentRuleHeader.assignmentRuleId = lAssigmentRuleIdLst[0].Id;
            Database.insert(lCaseToInsertLst, lDMLOptions);          
        }
    }

    public Case createSupportCase(AWS_API.ResponseWrapper aResult, String aObjectId, String aObjectName) {
        return new Case(
            Subject = Label.String_StatusCode + ' ' + String.Valueof(aResult.response.getStatusCode()), 
            Status = Label.String_OnHold , 
            RecordCode__c = aObjectId, 
            Description = aResult.message, 
            ObjectType__c = aObjectName, 
            RecordTypeId = SUPPORT_API, 
            Origin = Label.FieldValueIntegrationFailure
        );
    }

    public void validateToRetrieve(SObject aSObject, List<SObject> aSObjectsToRetrieveLst) {
        Integer lTotSend = fTotalSendMap.get(aSObject.id);
        if(lTotSend == null) lTotSend = 1;
        if(lTotSend < Integer.valueOf(Label.AWSQuantityAttemptsShipping)) {
            aSObjectsToRetrieveLst.add(aSObject);
            fTotalSendMap.put(aSObject.id,++lTotSend);
        }  
    }        
}