/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de OperationalService
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-08      Mariana Ribeiro         class created 
**************************************************************************************************************/
public class VehicleRegistrationWizard_ctr {
    private static final String NO = Label.String_No;
    private static final String NOTNECESSARY = Label.String_Not_Necessary;
    private static final String SOBJECTNAMECASE = Label.SObjectNameCase;
    private static final String STATUS_IN_DEPLOYMENT = Label.Status_Deployment;
    private static final String INACTIVE = Label.Status_Inactive;
    private static final String RELATIONSHIP_QUEUE = Label.String_Relationship;
    private static final String SUPPLIES_QUEUE = Label.ModalTypeSupplies;
    private static final String SUPPORT_QUEUE = Label.String_Support;
    private static final String MODAL_TYPE_SUSTAINABLE = Label.ModalTypeSustainable;
    private static final String MODAL_TYPE_BYKE = Label.ModalTypeBike;
    private static final String QUEUE = Label.String_Queue;
    private static final String STEP2 = Label.String_Step2;
    private static final String STEP3 = Label.String_Step3;
    private static final String STEP4 = Label.String_Step4;

    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();
    
    @AuraEnabled
    public static Vehicle__c searchVehicle(String aPlateChassi){
        aPlateChassi = aPlateChassi.toUpperCase();

        List<Vehicle__c> lVehicle = [SELECT Id,OwnerName__c,Color__c, Name, plate__c,Provider__r.Name,TypeModal__r.Name,DateLastSurvey__c,Chassi__c,
                                        secondaryphone__c,phone__c,Company__c,TypeRegistration__c,TypeFuel__c,VehicleStatus__c,Step__c,
                                        TypeAcquisition__c,ModelYear__c,Supplier__c,Nonstop__c,InsuranceAuto__c,SurveyStatus__c,
                                        YearManufacture__c,RenavamCode__c,Standardization__c, IPVA__c,StandardVehicle__c, InsuranceExpiration__c,
                                        DateNextSurvey__c, OwnerId, TypeModal__c, TypeModal__r.ModalType__c, TypeModal__r.Status__c, TrafficFines__c,Restrictions__c,FinancingDate__c,FinancingMonth__c,FinancingYear__c
                                        FROM Vehicle__c WHERE Plate__c = :aPlateChassi OR Chassi__c = :aPlateChassi];
        //system.debug('lVehicle: '+lVehicle );

        Group s =  [SELECT Id FROM Group WHERE Name = :RELATIONSHIP_QUEUE AND Type = :QUEUE LIMIT 1];
        
        if(lVehicle.isEmpty() || lVehicle.size() == 0){
            
            Vehicle__c lVehicleToInsert =  new VehicleSearchWebService_cls().getVehicleSearch(aPlateChassi);
            if(lVehicleToInsert == null){
                System.debug('Chassi ou Placa não existe');
                return null;
            }else{
                try {
                    lVehicleToInsert.Step__c = STEP2;
                    lVehicleToInsert.VehicleStatus__c = STATUS_IN_DEPLOYMENT;
                    lVehicleToInsert.OwnerId = s.id;
                    insert lVehicleToInsert;
                    //system.debug('lVehicleToInsert: '+ lVehicleToInsert);
                    return lVehicleToInsert;           
                }
                catch(DmlException e) {
                    throw new AuraHandledException(e.getDmlMessage(0));
                }
            }            
        }else{
            return lVehicle[0];
        }
         
    }

    @AuraEnabled
    public static Vehicle__c saveVehicle(String aVehicleJson, String step, List<String> valuesCompany){

        Vehicle__c lVehicle = (Vehicle__c)System.JSON.deserializeStrict(aVehicleJson, Vehicle__c.Class);
        String QueueName = '';
        lVehicle.Company__c = String.join(valuesCompany, ';');
        String lPhone = lVehicle.phone__c.replaceAll('[^0-9]','');
        String lPhoneSecundary = lVehicle.secondaryphone__c.replaceAll('[^0-9]','');
        lVehicle.phone__c = lPhone;
        lVehicle.secondaryphone__c = lPhoneSecundary;

        if(step == STEP3){
            lVehicle.Step__c = STEP4;
            QueueName = SUPPORT_QUEUE;
        }else if(step == STEP2){
            List<AssignmentRule>  lAssigmentRuleIdLst = [SELECT Id FROM AssignmentRule WHERE SobjectType = :Label.SObjectNameCase and Active = true];
            Vehicle__c lVehicleInsuranceAuto = new VehicleInsuranceAutoWebService_cls().getInsuranceAutoStatus(lVehicle.plate__c,lVehicle.Chassi__c,lAssigmentRuleIdLst[0].Id,lVehicle.Code__c);
            if(lVehicleInsuranceAuto != null){
                //system.debug('lVehicleInsuranceAuto.InsuranceAuto__c: '+ lVehicleInsuranceAuto.InsuranceAuto__c);
                lVehicle.InsuranceAuto__c = lVehicleInsuranceAuto.InsuranceAuto__c;
                lVehicle.policy__c = lVehicleInsuranceAuto.policy__c;
                lVehicle.BranchCode__c = lVehicleInsuranceAuto.BranchCode__c;
                lVehicle.InsuranceExpiration__c = lVehicleInsuranceAuto.InsuranceExpiration__c;
                lVehicle.ModelCode__c = lVehicleInsuranceAuto.ModelCode__c;
            }
            
            if(String.isNotBlank(lVehicle.TypeModal__c)) {
                Modal__c lModal = [SELECT ModalType__c FROM Modal__c WHERE Id =:lVehicle.TypeModal__c LIMIT 1 ];
                if(lVehicle.StandardVehicle__c == NO || lModal.ModalType__c == MODAL_TYPE_SUSTAINABLE || lModal.ModalType__c == MODAL_TYPE_BYKE){
                    lVehicle.InsuranceAuto__c = NOTNECESSARY;
                    lVehicle.InsuranceExpiration__c = null;
                    lVehicle.SurveyStatus__c = NOTNECESSARY;
                }
            }            

            if(lVehicle.StandardVehicle__c == NO){
                lVehicle.Step__c = STEP4;
                QueueName = SUPPORT_QUEUE;
            }else{
                lVehicle.Step__c = STEP3;
                QueueName = SUPPLIES_QUEUE;
            }
            
        }
        
        try {
            Group lGroup =  [SELECT Id FROM Group WHERE Name =: QueueName AND Type = :QUEUE LIMIT 1];
            lVehicle.OwnerId = lGroup.id;
            update lVehicle;
        }
        catch(DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
        return lVehicle;
    }

    @AuraEnabled
    public static Vehicle__c updateCompany(String aVehicleJson, List<String> lValuesCompany){
        Vehicle__c lVehicle = (Vehicle__c)System.JSON.deserializeStrict(aVehicleJson, Vehicle__c.Class);
        lVehicle.Company__c = String.join(lValuesCompany, ';');

        return lVehicle;
    }

    @AuraEnabled
    public static List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> updateCompanyLoad(String aVehicleJson, List<String> lValuesCompany){
        Vehicle__c lVehicle = (Vehicle__c)System.JSON.deserializeStrict(aVehicleJson, Vehicle__c.Class);
        List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> lValuesUpdate = new List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper>();
        if(lVehicle.Company__c != null){
            List<String> lValuesNow = lVehicle.Company__c.split(';');
            for(String v: lValuesNow){
                lValuesUpdate.add(
                    new GenericWrapperClass_cls.PopulateSelectOptionsWrapper(
                        v,
                        v
                    )
                );
            }
            //System.debug('lValuesNow: '+ lValuesNow);
            if(lValuesUpdate.size() == lValuesCompany.size()){
                lValuesUpdate = getCompanyPicklistObj();
            }
        }else{
            lValuesUpdate = getCompanyPicklistObj();
        }
        return lValuesUpdate;  
    }

    @AuraEnabled
    public static List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> getCompanyPicklistObj(){
        List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> lPickListValuesLst= new List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper>();
		Schema.DescribeFieldResult lFieldResult = Vehicle__c.Company__c.getDescribe();
        List<Schema.PicklistEntry> lPicklistEntry = lFieldResult.getPicklistValues();
		for( Schema.PicklistEntry lPickListVal : lPicklistEntry){            
			lPickListValuesLst.add(
                new GenericWrapperClass_cls.PopulateSelectOptionsWrapper(
                    lPickListVal.getLabel(),
                    lPickListVal.getValue()
                )
            );
		}     
        //system.debug('pickListValuesList ' + lPickListValuesLst);
		return lPickListValuesLst;
    }

    @AuraEnabled
    public static String getProfileName(){
        String profileName = [SELECT Id, Name FROM Profile 
                                WHERE Id=:Userinfo.getProfileId()].Name;
        //System.debug('profileName: '+ profileName);
        return profileName;  
    }

}