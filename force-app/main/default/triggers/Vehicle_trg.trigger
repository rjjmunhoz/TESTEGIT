trigger Vehicle_trg on Vehicle__c (after insert, after update, before insert){

    if(trigger.isAfter){
        if (trigger.isUpdate) {
            VehicleHandler.checkSurveyInsuranceAuto(trigger.newMap);
            VehicleHandler.initialsGenerator(trigger.newMap);
            VehicleHandler.deleteJunctions(trigger.newMap);
        }
    }

    if(trigger.isAfter){
        if (trigger.isUpdate || trigger.isInsert) {
            VehicleHandler.legacyIntegration(trigger.new);
            // Método para calcular os veículos do prestador
            VehicleHandler.rollUpVehicleProvider(trigger.new);            
        }
    }

    if (trigger.isBefore) {
        if(trigger.isInsert){
            VehicleHandler.generateExternalId(trigger.new);
        }
    }
}