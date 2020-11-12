public with sharing class VehicleHandler {
    private static final String ATIVO = Label.Status_Active;
    private static final String LIBERADO = Label.Status_Released;
    private static final String STEP2 = Label.String_Step2;
    private static final String STEP3 = Label.String_Step3;
    private static final String STEP4 = Label.String_Step4;
    private static final String YES = Label.String_Yes;

    public static void checkSurveyInsuranceAuto(Map<Id,Vehicle__c> aMapNew) {

        TriggerCheck.assert();
        
        Set<Id> lVehicleIdSet = new Set<Id>();
        for(Vehicle__c lVehicle :aMapNew.values()){
            if(lVehicle.VehicleStatus__c == Label.Status_Deployment  && ((TriggerCheck.isChangedTo(lVehicle, Vehicle__c.SurveyStatus__c, LIBERADO) && lVehicle.InsuranceAuto__c == ATIVO) || (TriggerCheck.isChangedTo(lVehicle, Vehicle__c.InsuranceAuto__c, ATIVO) && lVehicle.SurveyStatus__c == LIBERADO)) && lVehicle.Standardization__c == YES){
                lVehicleIdSet.add(lVehicle.Id);
            }
        }
        
        Map<Id,EquipamentVehicle__c> lJunctionMap = new Map<Id,EquipamentVehicle__c>();
        for(EquipamentVehicle__c lEquipVeihicle :[SELECT Vehicle__c, Equipament__c  FROM EquipamentVehicle__c WHERE Vehicle__c IN :lVehicleIdSet]){
            lJunctionMap.put(lEquipVeihicle.Vehicle__c,lEquipVeihicle);
        }
        
        List<Vehicle__c> lVehicleToUpdate = [SELECT Id, VehicleStatus__c FROM Vehicle__c WHERE Id IN :lJunctionMap.keySet()];

        if(!(lVehicleToUpdate.isEmpty())){ 
            for(Vehicle__c lVehicle :lVehicleToUpdate){
                lVehicle.VehicleStatus__c = ATIVO;
            }
            update lVehicleToUpdate;  
        }               
    }

    public static void legacyIntegration(List<Vehicle__c>  aNewLst) {
        TriggerCheck.assert();

        List<Vehicle__c> lVehicleLst = new List<Vehicle__c>();
        for(Vehicle__c lVehicle: aNewLst){
            if(lVehicle.Step__c == STEP4){
                lVehicleLst.add(lVehicle);
            }
        }
        if(lVehicleLst.isEmpty()) return;               
        
        SpecialtyWrapper_cls lVehicleToIntegrationWr = VehicleWebService_cls.getVehicleToIntegration(lVehicleLst);
        if(lVehicleToIntegrationWr != null) {
            System.enqueueJob(new IntegrationHandler_cls(lVehicleToIntegrationWr)); 
        }   
    }
    
    public static void initialsGenerator(Map<Id,Vehicle__c> aMapNew) {
        TriggerCheck.assert();

        Map<Id, String> modalMapId = new Map<Id, String>();
        for(Vehicle__c lVehicle: aMapNew.values()){
            if((lVehicle.NumberTypeModal__c == 0 && TriggerCheck.isChangedFromTo(lVehicle, Vehicle__c.Step__c, STEP2, STEP3)) || TriggerCheck.isChanged(lVehicle, Vehicle__c.TypeModal__c) || (lVehicle.NumberTypeModal__c == 0 && TriggerCheck.isChangedFromTo(lVehicle, Vehicle__c.Step__c, STEP2, STEP4))){
                modalMapId.put(lVehicle.Id,lVehicle.TypeModal__c);
            }
        }
        
        Map<String,Decimal> fVehicleIdMap = new Map<String,Decimal>();
        if(!modalMapId.isEmpty()){	
            for(AggregateResult lAgr :[SELECT MAX(NumberTypeModal__c) lastValue, TypeModal__r.Initials__c initials FROM Vehicle__c WHERE TypeModal__c IN :modalMapId.values() AND Id NOT IN: modalMapId.keySet() GROUP BY TypeModal__r.Initials__c]) {
                fVehicleIdMap.put((String)lAgr.get(Label.String_Initials), (Decimal)lAgr.get(Label.String_LastValue));
            }
        }
        
        List<Vehicle__c> lVehicleToUpdate = [SELECT Id, TypeModal__r.Initials__c FROM Vehicle__c WHERE Id IN :modalMapId.keySet()];

        if(!(lVehicleToUpdate.isEmpty())){ 
            for(Vehicle__c lVehicle :lVehicleToUpdate){
                system.debug('VehicleIdMap.get(lVehicle.Initials__c): '+ fVehicleIdMap.get(lVehicle.TypeModal__r.Initials__c));
                Decimal lLastCode = fVehicleIdMap.get(lVehicle.TypeModal__r.Initials__c);
                if(lLastCode == null){
                	lLastCode = 0;  
                } 
               lVehicle.NumberTypeModal__c = ++lLastCode;
            }
            update lVehicleToUpdate;  
        }                  
    }

    public static void generateExternalId(List<Vehicle__c> aVehicleLstNew) {
        TriggerCheck.assert();
        
        List<Vehicle__c> lVehicleCreateIdLst = new List<Vehicle__c>();
        for(Vehicle__c lVehicle :aVehicleLstNew){
            if(lVehicle.Code__c == null){
                lVehicleCreateIdLst.add(lVehicle);
            }               
        }
        if(lVehicleCreateIdLst.isEmpty()) return;

        Decimal lLastCode = null;
        for(AggregateResult lAgr :[SELECT MAX(Code__c) lastValue FROM Vehicle__c]) {
            lLastCode = (Decimal)lAgr.get('lastValue');
        }

        for(Vehicle__c lVehicle :lVehicleCreateIdLst){
            if(lLastCode == null) lLastCode = 0;
            lVehicle.Code__c = ++lLastCode;
            ++lLastCode;
        }
    } 

    /* 
    Método para realizar os Roll-Up dos veículos Ativos e Inativos do prestador
    */
    public static void rollUpVehicleProvider(List<Vehicle__c> aVehicleLstNew) {
        TriggerCheck.assert();
        
        Set<Id> lProviderToUpdateIdSet = new Set<Id>();
        for(Vehicle__c lVehicle :aVehicleLstNew){
            if(TriggerCheck.isChanged(lVehicle, Vehicle__c.Provider__c)){
                lProviderToUpdateIdSet.add(lVehicle.Provider__c);
                if(trigger.isUpdate) {
                    lProviderToUpdateIdSet.add(((Vehicle__c)trigger.oldMap.get(lVehicle.id)).Provider__c);
                }
            } 
            if(TriggerCheck.isChanged(lVehicle, Vehicle__c.VehicleStatus__c)){
                lProviderToUpdateIdSet.add(lVehicle.Provider__c);
            }               
        }

        System.debug('lProviderToUpdateIdSet: '+ lProviderToUpdateIdSet);

        if(lProviderToUpdateIdSet.isEmpty()) return;

        Map<Id,Account> lProviderToUpdateMap = new Map<Id,Account>();
        List<Account> lProviderSetLst = new List<Account>();
        for(Id lProviderId :lProviderToUpdateIdSet){
            lProviderToUpdateMap.put(lProviderId,new Account(Id = lProviderId, TotalVehicles__c = 0));             
        }

        for(AggregateResult lAr :[SELECT COUNT(Id) total, Provider__c provider FROM Vehicle__c 
                WHERE VehicleStatus__c IN ('Ativo','Inativo') AND Provider__c IN :lProviderToUpdateIdSet GROUP BY Provider__c ]) {
            Account lProvider = lProviderToUpdateMap.get((Id)lAr.get('provider'));
            if(lProvider != null) {
                lProvider.TotalVehicles__c = Integer.valueOf(lAr.get('total'));
                lProviderSetLst.add(lProvider);
            }
        }

        System.debug('lProviderSetLst: '+ lProviderSetLst);

        if(!lProviderSetLst.isEmpty()) update lProviderSetLst;
    } 

    public static void deleteJunctions(Map<Id,Vehicle__c> aMapNew) {

        TriggerCheck.assert();
        
        Set<Id> lVehicleIdSet = new Set<Id>();
        Set<Id> lProviderIdSet = new Set<Id>();
        Set<Id> lEquipaIdSet = new Set<Id>();
        for(Vehicle__c lVehicle :aMapNew.values()){
            if(TriggerCheck.isChangedFromTo(lVehicle, Vehicle__c.VehicleStatus__c, 'Ativo', 'Cancelado')){
                lVehicleIdSet.add(lVehicle.Id);
                lProviderIdSet.add(lVehicle.Provider__c);
            }
        }
        
        List<EquipamentVehicle__c> lEquipVehicleToDeleteLst = [SELECT Id, Equipament__c, isActive__c, Provider__c, Vehicle__c FROM EquipamentVehicle__c WHERE Vehicle__c IN :lVehicleIdSet];

        if(!lEquipVehicleToDeleteLst.isEmpty()){
            for(EquipamentVehicle__c lEquipVehicle: lEquipVehicleToDeleteLst){
                lEquipVehicle.isActive__c = false;
                lEquipaIdSet.add(lEquipVehicle.Equipament__c);
            }

            update lEquipVehicleToDeleteLst;
        }

        System.debug('lEquipaIdSet '+ lEquipaIdSet);

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
    
        List<ProviderEquipment__c> lEquiProviderLst = [SELECT Id, Provider__r.Name, Equipment__r.Name, isActive__c  FROM ProviderEquipment__c WHERE Equipment__c IN :lEquipaIdSet AND Provider__c IN :lProviderIdSet AND IsActive__c = true];

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