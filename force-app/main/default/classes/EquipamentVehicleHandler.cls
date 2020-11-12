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
public with sharing class EquipamentVehicleHandler {
    private static final String ACTIVE = Label.Status_Active;
    private static final String INACTIVE = Label.Status_Inactive;
    private static final String RELEASED = Label.Status_Released;
    private static final String YES = Label.String_Yes;
    private static final String NOTNECESSARY = Label.String_Not_Necessary;
    private static final String DEPLOYMENT = Label.Status_Deployment; 

    public static void checkSurveyInsuranceAuto(Map<Id,EquipamentVehicle__c> aMapNew) {        
        TriggerCheck.assert();
		
        List<Id> lVehicleIdSet = new List<Id>();
        for (EquipamentVehicle__c lEquipVehicle :aMapNew.values()) {
            if(lEquipVehicle.EquipmentStatus__c == ACTIVE && TriggerCheck.isChangedTo(lEquipVehicle, EquipamentVehicle__c.IsActive__c,true)) {
                lVehicleIdSet.add(lEquipVehicle.Vehicle__c);
            }
        }            
             
        Set<Id> lVehicleToIgnoreSet = new Set<Id>();
        List<Vehicle__c> lVehicleToUpdateLst = new List<Vehicle__c>();
        for (Vehicle__c lVehicle :[SELECT Id, SurveyStatus__c, InsuranceAuto__c, VehicleStatus__c 
                                   FROM Vehicle__c WHERE Id IN :lVehicleIdSet AND VehicleStatus__c = :DEPLOYMENT AND
                                   ((SurveyStatus__c = :RELEASED AND InsuranceAuto__c = :ACTIVE AND Standardization__c = :YES) OR 
                                   (SurveyStatus__c = :NOTNECESSARY AND InsuranceAuto__c = :NOTNECESSARY))]) {
            lVehicle.VehicleStatus__c = ACTIVE;
            lVehicleToUpdateLst.add(lVehicle);
            lVehicleToIgnoreSet.add(lVehicle.Id);
        }

        if(!lVehicleToUpdateLst.isEmpty()){
            update lVehicleToUpdateLst;
        }

        if(lVehicleToIgnoreSet.size() != aMapNew.size()) {
            synchronizeVehicle(aMapNew.values(), lVehicleToIgnoreSet, false);
        }
    }

    public static void checkSurveyInsuranceAutoDelete(Map<Id,EquipamentVehicle__c> aMapOld) {        
        TriggerCheck.assert();
                
		List<Id> lVehicleIdSet = new List<Id>();
        for (EquipamentVehicle__c lEquipVehicle :aMapOld.values()) {
            //if(lEquipVehicle.EquipmentStatus__c == ACTIVE) { 
                lVehicleIdSet.add(lEquipVehicle.Vehicle__c);
            //}
        }            
             
        Set<Id> lVehicleToIgnoreSet = new Set<Id>();
        List<Vehicle__c> lVehicleToUpdateLst = new List<Vehicle__c>();
        for (Vehicle__c lVehicle :[SELECT Id, SurveyStatus__c, InsuranceAuto__c, VehicleStatus__c,
                                   (SELECT Id FROM EquipamentosVeiculos__r WHERE Id NOT IN: aMapOld.keySet() AND EquipmentStatus__c = :ACTIVE)
                                   FROM Vehicle__c WHERE Id IN :lVehicleIdSet AND VehicleStatus__c != :INACTIVE AND VehicleStatus__c != :'Cancelado' AND
                                   ((SurveyStatus__c =: RELEASED AND InsuranceAuto__c =: ACTIVE AND Standardization__c =: YES) OR 
                                   (SurveyStatus__c =: NOTNECESSARY AND InsuranceAuto__c =: NOTNECESSARY))]) {
            if(lVehicle.EquipamentosVeiculos__r.isEmpty()) {
            	lVehicle.VehicleStatus__c = INACTIVE;
            	lVehicleToUpdateLst.add(lVehicle);  
                lVehicleToIgnoreSet.add(lVehicle.Id);                        
            }            
        }

        if(!lVehicleToUpdateLst.isEmpty()){
            update lVehicleToUpdateLst;
        }  
        
        if(lVehicleToIgnoreSet.size() != aMapOld.size()) {
            synchronizeVehicle(aMapOld.values(), lVehicleToIgnoreSet, true);
        }
    }

    public static void addOrRemoveEquipment(List<EquipamentVehicle__c> aNewLst){
        TriggerCheck.assert();

        Set<Id> lVehicleToIntegrateSet = new  Set<Id>();
        for(EquipamentVehicle__c lEquip :aNewLst){
            if(TriggerCheck.isChanged(lEquip, EquipamentVehicle__c.IsActive__c) && lEquip.VehicleStatus__c == ACTIVE){
                lVehicleToIntegrateSet.add(lEquip.Vehicle__c);
            }
        }
        system.debug('Veículos que tiveram equipamentos inseridos ou alterados: ' + lVehicleToIntegrateSet);
        if(lVehicleToIntegrateSet.isEmpty()) return;
        VehicleWebService_cls.setVehicleToSynchronize(lVehicleToIntegrateSet);
    }

    public static void synchronizeVehicle(List<EquipamentVehicle__c> aNewLst, Set<Id> aVehicleToIgnoreSet, Boolean aIsDelete){
        TriggerCheck.assert();
        
        Set<Id> lVehicleIdSet = new Set<Id>();
        Set<Id> lProviderIdSet = new Set<Id>();
        for(EquipamentVehicle__c lEquipVehicle :aNewLst){
            // Caso este veiculo já tenha sido atualizado não reenvia novamente para integração
            System.debug('Aqui');
            if(aVehicleToIgnoreSet.contains(lEquipVehicle.Vehicle__c)) continue;

            if(aIsDelete || 
                    TriggerCheck.isChanged(lEquipVehicle, EquipamentVehicle__c.Vehicle__c) || 
                    TriggerCheck.isChanged(lEquipVehicle, EquipamentVehicle__c.Equipament__c ) || 
                    TriggerCheck.isChanged(lEquipVehicle, EquipamentVehicle__c.Provider__c )) {
                if(lEquipVehicle.Vehicle__c != null) {
                    lVehicleIdSet.add(lEquipVehicle.Vehicle__c);
                    lProviderIdSet.add(lEquipVehicle.Provider__c);
                } 
                if(trigger.isUpdate) {
                    lVehicleIdSet.add(((EquipamentVehicle__c)trigger.oldMap.get(lEquipVehicle.id)).Vehicle__c);
                }                 
            }            
        }
        if(lVehicleIdSet.isEmpty()) return;

        VehicleWebService_cls.setVehicleToSynchronize(lVehicleIdSet);
    }

    public static void validateJunctionEquipamentVehicle(List<EquipamentVehicle__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lVehicleSet = new Set<Id>();
        Set<Id> lEquipmentSet = new Set<Id>();
        for(EquipamentVehicle__c lEquipmentVehicle :aNewLst){
            lVehicleSet.add(lEquipmentVehicle.Vehicle__c);
            lEquipmentSet.add(lEquipmentVehicle.Equipament__c);
        }

        Set<String> lRecordsSet = new Set<String>();
        for(EquipamentVehicle__c lEquipamentVehicle :[SELECT Vehicle__c, Equipament__c FROM EquipamentVehicle__c WHERE Vehicle__c =: lVehicleSet AND Equipament__c =: lEquipmentSet]){
           lRecordsSet.add(lEquipamentVehicle.Equipament__c +''+lEquipamentVehicle.Vehicle__c);
        }
        system.debug('lRecordsSet ' + lRecordsSet);
        if(lRecordsSet.isEmpty()) return;

        for(EquipamentVehicle__c lEquipamentVehicle :aNewLst){
            if(lRecordsSet.contains(lEquipamentVehicle.Equipament__c +''+lEquipamentVehicle.Vehicle__c)){
                lEquipamentVehicle.addError(Label.MessageError_JunctionEquipamentVehicle);
            }
        }
    }

    public static void occupyProviderInJunction(List<EquipamentVehicle__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lVehicleSet = new Set<Id>();
        for(EquipamentVehicle__c lEquipmentVehicle :aNewLst){
            lVehicleSet.add(lEquipmentVehicle.Vehicle__c);
        }

        Map<Id, Id> lMapProvider = new Map<Id, Id>();
        for(Vehicle__c lVehicle :[SELECT Id, Provider__c FROM Vehicle__c WHERE Id IN :lVehicleSet]){
            lMapProvider.put(lVehicle.Id, lVehicle.Provider__c);
        }

        if(lMapProvider == null) return;

        for(EquipamentVehicle__c lEquipamentVehicle :aNewLst){
            lEquipamentVehicle.Provider__c = lMapProvider.get(lEquipamentVehicle.Vehicle__c);
        }
    }

    public static void createJunctionInProvider(List<EquipamentVehicle__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lEquipSet = new Set<Id>();
        Set<Id> lProviderSet = new Set<Id>();
        Set<String> lEquipVehicleSet = new Set<String>();

        for(EquipamentVehicle__c lEquipmentVehicle :aNewLst){
            if(lEquipmentVehicle.IsActive__c){
                lEquipSet.add(lEquipmentVehicle.Equipament__c);
                lProviderSet.add(lEquipmentVehicle.Provider__c);
                lEquipVehicleSet.add(lEquipmentVehicle.Equipament__c+''+lEquipmentVehicle.Provider__c);
            }
        }

        List<ProviderEquipment__c> lEquipProviderLst = [SELECT Id, Equipment__c, Provider__c, IsActive__c  FROM ProviderEquipment__c WHERE Equipment__c IN: lEquipSet OR Provider__c IN: lProviderSet];

        System.debug('lEquipProviderLst: '+lEquipProviderLst);
        List<ProviderEquipment__c> lEquipProviderToUpdate = new List<ProviderEquipment__c>();
        Set<String> lEquipProviderSet = new Set<String>();

        if(!lEquipProviderLst.isEmpty()){
            for(ProviderEquipment__c lEquipProvider: lEquipProviderLst){
                if(lEquipVehicleSet.contains(lEquipProvider.Equipment__c+''+lEquipProvider.Provider__c)){
                    lEquipProvider.IsActive__c = true;
                    lEquipVehicleSet.remove(lEquipProvider.Equipment__c+''+lEquipProvider.Provider__c);
                    lEquipProviderToUpdate.add(lEquipProvider);
                }else{
                    lEquipProviderSet.add(lEquipProvider.Equipment__c+''+lEquipProvider.Provider__c);
                }
            }
        }     
        
        System.debug('lEquipProviderSet: '+lEquipProviderSet);
        System.debug('lEquipVehicleSet: '+lEquipVehicleSet);

        if(lEquipVehicleSet.isEmpty()){
            update lEquipProviderToUpdate;
            return;
        } 

        List<ProviderEquipment__c> lEquipProviderToInsert = new List<ProviderEquipment__c>();

        for(EquipamentVehicle__c lEquipmentVehicle :aNewLst){
            if(!lEquipProviderSet.contains(lEquipmentVehicle.Equipament__c+''+lEquipmentVehicle.Provider__c)){
                lEquipProviderToInsert.add(new ProviderEquipment__c(Equipment__c= lEquipmentVehicle.Equipament__c, Provider__c= lEquipmentVehicle.Provider__c));
            }
        }

        System.debug('lEquipProviderToInsert: '+lEquipProviderToInsert);
        System.debug('lEquipProviderToUpdate: '+lEquipProviderToUpdate);

        if (!lEquipProviderToInsert.isEmpty()){
            insert lEquipProviderToInsert;
        } 
        if (!lEquipProviderToUpdate.isEmpty()){
            update lEquipProviderToUpdate;
        } 

    }

    public static void deleteJunctionProviderEquipament(Map<Id,EquipamentVehicle__c> aMapOld) {        
        TriggerCheck.assert();
                
		List<Id> lVehicleIdSet = new List<Id>();
		Set<Id> lProviderIdSet = new Set<Id>();
		Set<Id> lEquipaIdSet = new Set<Id>();
        for (EquipamentVehicle__c lEquipVehicle :aMapOld.values()) {
            if(TriggerCheck.isChangedTo(lEquipVehicle, EquipamentVehicle__c.isActive__c, false)) { 
                lEquipaIdSet.add(lEquipVehicle.Equipament__c);
                lVehicleIdSet.add(lEquipVehicle.Vehicle__c);
                lProviderIdSet.add(lEquipVehicle.Provider__c);
            }
        }  

        List<EquipamentVehicle__c> lEquipVehicleLst = [SELECT Id, Equipament__c, isActive__c, Vehicle__c FROM EquipamentVehicle__c WHERE Equipament__c IN :lEquipaIdSet AND Provider__c IN :lProviderIdSet AND isActive__c = true];

        if(!lEquipVehicleLst.isEmpty()){
            System.debug('lEquipVehicleLst '+ lEquipVehicleLst);
            for(EquipamentVehicle__c lEquipVehicle: lEquipVehicleLst){
                if(lEquipaIdSet.contains(lEquipVehicle.Equipament__c)){
                    lEquipaIdSet.remove(lEquipVehicle.Equipament__c);
                }
            }
        }

        System.debug('lEquipaIdSet '+ lEquipaIdSet);

        List<ProviderEquipment__c> lEquiProviderLst = [SELECT Id, isActive__c, Provider__r.Name, Equipment__r.Name  FROM ProviderEquipment__c WHERE Equipment__c IN :lEquipaIdSet AND Provider__c IN :lProviderIdSet];

        String lProviderName = '';
        String lEquipName = '';

        if(!lEquiProviderLst.isEmpty()){
            if(lEquiProviderLst.size()>1){
                for(ProviderEquipment__c lEquiProvider: lEquiProviderLst){
                    lProviderName = lEquiProvider.Provider__r.Name;
                    lEquipName = lEquiProvider.Equipment__r.Name+ ', '+lEquipName;
                    lEquiProvider.isActive__c = false;
                }
            }else{
                lProviderName = lEquiProviderLst[0].Provider__r.Name;
                lEquipName = lEquiProviderLst[0].Equipment__r.Name;
                lEquiProviderLst[0].isActive__c = false;
            }

            update lEquiProviderLst;

            String lPath = Label.ParameterNotificationCustom;
            List<Object> lParameters = new List<Object> {lEquipName, lProviderName};
            String lFormattedPath = String.format(lPath, lParameters); 

            BellNotification_cls.notifyCurrentUser(lFormattedPath, Label.EquipmentRemove, Label.NotifyUserAfterDeletionEquipment);
        }
    }
}