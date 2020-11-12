/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Classe que inativa um serviço caso a data de inativação seja menor ou igual à data de execução
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-12-06      Jean Sganzerla          class created 
**************************************************************************************************************/
global class RemoveService_sch implements Schedulable{

    // RemoveService_sch lRemoveService = new RemoveService_sch();
    // String lSch = '0 0 0 * * ?';
    // system.schedule('Remoção de Serviço', lSch, lRemoveService);

    private static final Id REMOVE_SERVICE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RemoveServiceRecordType).getRecordTypeId();
    private static final Id SPECIALTY_REASONS_RECTYPE = SObjectType.ServiceSpecialtyDetails__c.getRecordTypeInfosByDeveloperName().get(Label.SpecialtyReasonsRecordType).getRecordTypeId();
    
    global void execute(SchedulableContext ctx) {
        
        Set<Id> lServiceSet = new Set<Id>();
        for(Case lCase :[SELECT Service__c FROM Case WHERE RecordTypeId = :REMOVE_SERVICE_RECTYPE AND DateWithdrawalFromService__c = TODAY AND Status = :Label.Status_Withdrawn]){
            lServiceSet.add(lCase.Service__c);
        }
        System.debug('lServiceSet ' + lServiceSet);
        if(lServiceSet.isEmpty()) return;
        
        Map<Id,Product2> lServiceSpecialties = new Map<Id,Product2>();
        for(Product2 lSpecialty :[SELECT Id, Status__c FROM Product2 WHERE Id IN (SELECT Specialty__c FROM ServiceSpecialtyDetails__c WHERE Service__c IN :lServiceSet)]){
            lServiceSpecialties.put(lSpecialty.Id,lSpecialty);
            System.debug('########## ----> map: ' + lServiceSpecialties);
        }

        for(ServiceSpecialtyDetails__c lAlreadyUsedSpecialty :[SELECT Specialty__c FROM ServiceSpecialtyDetails__c WHERE Service__c NOT IN :lServiceSet AND Specialty__c != null]){
            if(lServiceSpecialties.containsKey(lAlreadyUsedSpecialty.Specialty__c)){
                lServiceSpecialties.remove(lAlreadyUsedSpecialty.Specialty__c);
            }
        }
        
        List<Product2> lServiceAndSpecialtyToUpdateLst = [SELECT Status__c FROM Product2 WHERE Id IN :lServiceSet];
        lServiceAndSpecialtyToUpdateLst.addAll(lServiceSpecialties.values());

        for(Product2 lSpecialty :lServiceAndSpecialtyToUpdateLst){
            lSpecialty.Status__c = Label.Status_Inactive;
        }
        system.debug('lServiceAndSpecialtyToUpdateLst ' + lServiceAndSpecialtyToUpdateLst);
        update lServiceAndSpecialtyToUpdateLst;
    }
}