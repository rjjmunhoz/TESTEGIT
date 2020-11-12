/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de WorkOrder 
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-07-15      Matheus Branco           class created 
**************************************************************************************************************/
public without sharing class WorkOrderHandler_cls {
    public static void insertWorkOrderWithRelationship(List<WorkOrder> aWorkOrderLst) {
        Id SPECIALTY_RECTYPE = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.SpecialtyRecordType).getRecordTypeId();

        Set<Decimal> lProviderCodeSet = new Set<Decimal>();
        Set<Decimal> lRescuerQRASet = new Set<Decimal>();
        Set<String> lVehicleAcronymSet = new Set<String>();
        Set<Decimal> lSpecialtyCodeSet = new Set<Decimal>();
        Set<String> lParentServiceOrderNumSet = new Set<String>();

        for(WorkOrder lWorkOrder :aWorkOrderLst){
            lProviderCodeSet.add(lWorkOrder.ProviderCode__c);
            lRescuerQRASet.add(lWorkOrder.RescuerQRA__c);
            lVehicleAcronymSet.add(lWorkOrder.VehicleAcronym__c);
            lSpecialtyCodeSet.add(lWorkOrder.SpecialtyCode__c);
            lParentServiceOrderNumSet.add(lWorkOrder.ParentServiceOrderNumber__c);
        }
        
        Map<Decimal,Id> lAccountCodeIdMap = new Map<Decimal,Id>();
        for(Account lAccount :[SELECT Id, Code__c FROM Account WHERE Code__c = :lProviderCodeSet]) {
            lAccountCodeIdMap.put(lAccount.Code__c, lAccount.Id);
        }

        Map<Decimal,Id> lContactCodeIdMap = new Map<Decimal,Id>();
        for(Contact lContact :[SELECT Id, QRA__c FROM Contact WHERE QRA__c = :lRescuerQRASet]) {
            lContactCodeIdMap.put(lContact.QRA__c, lContact.Id);
        }

        Map<String,Id> lVehicleCodeIdMap = new Map<String,Id>();
        for(Vehicle__c lVehicle :[SELECT Id, Initials__c FROM Vehicle__c WHERE Initials__c = :lVehicleAcronymSet]) {
            lVehicleCodeIdMap.put(lVehicle.Initials__c, lVehicle.Id);
        }

        Map<Decimal,Id> lSpecialtyCodeIdMap = new Map<Decimal,Id>();
        for(Product2 lSpecialty :[SELECT Id, Code__c FROM Product2 WHERE Code__c = :lSpecialtyCodeSet AND RecordTypeId = :SPECIALTY_RECTYPE]) {
            lSpecialtyCodeIdMap.put(lSpecialty.Code__c, lSpecialty.Id);
        }

        Map<String,Id> lParentWorkOrderCodeIdMap = new Map<String,Id>();
        for(WorkOrder lWorkOrder :[SELECT Id, ServiceOrderNumber__c FROM WorkOrder WHERE ServiceOrderNumber__c = :lParentServiceOrderNumSet]) {
            lParentWorkOrderCodeIdMap.put(lWorkOrder.ServiceOrderNumber__c,lWorkOrder.Id);
        }

        for(WorkOrder lWorkOrder :aWorkOrderLst){
            Id lAccountId = lAccountCodeIdMap.get(Integer.valueOf(lWorkOrder.ProviderCode__c));
            if(lAccountId != null) {
                lWorkOrder.AccountId = lAccountId;
            }
            Id lContactId = lContactCodeIdMap.get(Integer.valueOf(lWorkOrder.RescuerQRA__c));
            if(lContactId != null) {
                lWorkOrder.ContactId = lContactId;
            }
            Id lVehicleId = lVehicleCodeIdMap.get(lWorkOrder.VehicleAcronym__c);
            if(lVehicleId != null) {
                lWorkOrder.Vehicle__c = lVehicleId;
            }
            Id lSpecialtyId = lSpecialtyCodeIdMap.get(Integer.valueOf(lWorkOrder.SpecialtyCode__c));
            if(lSpecialtyId != null) {
                lWorkOrder.Specialty__c = lSpecialtyId;
            }
            Id lParentWorkOrderId = lParentWorkOrderCodeIdMap.get(lWorkOrder.ParentServiceOrderNumber__c);
            if(lParentWorkOrderId != null) {
                lWorkOrder.ParentWorkOrderId = lParentWorkOrderId;
            }
        }        
    }
}