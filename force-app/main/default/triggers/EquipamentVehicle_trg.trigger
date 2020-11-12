trigger EquipamentVehicle_trg on EquipamentVehicle__c (after insert, after update, after delete, before insert) {
    if(trigger.isAfter){
        if (trigger.isUpdate) {
            EquipamentVehicleHandler.addOrRemoveEquipment(trigger.new);
            EquipamentVehicleHandler.checkSurveyInsuranceAuto(trigger.newMap);
            EquipamentVehicleHandler.createJunctionInProvider(trigger.new);
            EquipamentVehicleHandler.deleteJunctionProviderEquipament(trigger.newMap);
        }
        if(trigger.isInsert){
            EquipamentVehicleHandler.addOrRemoveEquipment(trigger.new);
            EquipamentVehicleHandler.createJunctionInProvider(trigger.new);
            EquipamentVehicleHandler.checkSurveyInsuranceAuto(trigger.newMap);
        }
        if(trigger.isDelete){
            EquipamentVehicleHandler.checkSurveyInsuranceAutoDelete(trigger.oldMap);
        }
    }

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            EquipamentVehicleHandler.validateJunctionEquipamentVehicle(trigger.new);
            EquipamentVehicleHandler.occupyProviderInJunction(trigger.new);
        }
    }
}