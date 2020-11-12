/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger do Setup Operacional
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0     2019-11-08      Matheus Branco          class created 
            1.1     2020-01-21      Jean Sganzerla          created legacyIntegration method
            1.2     2020-03-31      Jean Sganzerla          created generateExternalId and validateExternalId methods
            1.3     2020-03-31      Jean Sganzerla          created providerAbilityUpdate method
**************************************************************************************************************/
public class OperationalSetupHandler {

    private static final String ACTIVE = Label.Status_Active;
    private static final String IN_DEPLOYMENT = Label.Status_Deployment;
    private static final String INACTIVE = Label.Status_Inactive;

    private static final String EQUIPMENT_RECTYPE = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.EquipmentRecordType).getRecordTypeId();
    private static final String GMV_RECTYPE = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.GMVRecordType).getRecordTypeId();
    private static final String ABILITY_RECTYPE = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.AbilityRecordType).getRecordTypeId();
    private static final String SUPPLY_RECTYPE = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.SupplyRecordType).getRecordTypeId();
    private static final String PART_RECTYPE = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.PartRecordType).getRecordTypeId();
    private static final String CLOSEORDER_RECTYPE = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.CloseOrderRecordType).getRecordTypeId();
    private static final String CLOSEORDERDETAIL_RECTYPE = SObjectType.OperationalSetup__c.getRecordTypeInfosByDeveloperName().get(Label.CloseOrderDetailRecordType).getRecordTypeId();
    private static final String PROVIDER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProviderRecordType).getRecordTypeId();

    public static Map<Id,Decimal> fSetupeIdMap;

    public static void checkGMVEquipmentSupplyActivation(Map<Id,OperationalSetup__c> aMapNew) {
        TriggerCheck.assert();

        List<OperationalSetup__c> lGMVEquipmentSupplyToCheckLst = new List<OperationalSetup__c>();
        for(OperationalSetup__c lOperationalSetup: aMapNew.values()){
            if(TriggerCheck.isChangedTo(lOperationalSetup, OperationalSetup__c.Status__c, ACTIVE) && (lOperationalSetup.RecordTypeId == EQUIPMENT_RECTYPE
                || lOperationalSetup.RecordTypeId == GMV_RECTYPE || lOperationalSetup.RecordTypeId == SUPPLY_RECTYPE)){
                lGMVEquipmentSupplyToCheckLst.add(lOperationalSetup);
            }
        }
        
        if (lGMVEquipmentSupplyToCheckLst.isEmpty()) return;

        Set<Id> lEquipmentSet = new Set<Id>();
        for(Equipment__c lEquipment: [SELECT Id, OperationalSetup__c FROM Equipment__c WHERE OperationalSetup__c IN: lGMVEquipmentSupplyToCheckLst ORDER BY OperationalSetup__c]){
            lEquipmentSet.add(lEquipment.OperationalSetup__c);
        }

        Set<Id> lGMVSet = new Set<Id>();
        for (GMV__c lGMV: [SELECT Id, OperationalSetup__c FROM GMV__c WHERE OperationalSetup__c IN: lGMVEquipmentSupplyToCheckLst ORDER BY OperationalSetup__c]) {
            lGMVSet.add(lGMV.OperationalSetup__c);
        }

        Set<Id> lSupplySet = new Set<Id>();
        for(Supply__c lSupply: [SELECT Id, OperationalSetup__c FROM Supply__c WHERE OperationalSetup__c IN: lGMVEquipmentSupplyToCheckLst ORDER BY OperationalSetup__c]){
            lSupplySet.add(lSupply.OperationalSetup__c);
        }

        //Comentado para posteriormente quando houver o cadastro de fornecedores 
        /*
        Set<Id> lEquipmentSupplySet = new Set<Id>();
        for(EquipmentSupplyPart__c lEquipmentSupply: [SELECT Id, OperationalSetup__c FROM EquipmentSupplyPart__c WHERE OperationalSetup__c IN: lGMVEquipmentSupplyToCheckLst ORDER BY OperationalSetup__c]){
            lEquipmentSupplySet.add(lEquipmentSupply.OperationalSetup__c);
        }*/

        for(OperationalSetup__c lOperationalSetup: lGMVEquipmentSupplyToCheckLst){
            if((!lEquipmentSet.contains(lOperationalSetup.Id) /*|| !lEquipmentSupplySet.contains(lOperationalSetup.Id)*/) && lOperationalSetup.RecordTypeId == EQUIPMENT_RECTYPE){
                aMapNew.get(lOperationalSetup.Id).addError(Label.ErrorEquipmentModalUnbound);
            }else if((!lSupplySet.contains(lOperationalSetup.Id) /*|| !lEquipmentSupplySet.contains(lOperationalSetup.Id)*/) && lOperationalSetup.RecordTypeId == SUPPLY_RECTYPE){
                aMapNew.get(lOperationalSetup.Id).addError(Label.ErrorSupplyModalUnbound);
            }else if(!lGMVSet.contains(lOperationalSetup.Id) && lOperationalSetup.RecordTypeId == GMV_RECTYPE){
                aMapNew.get(lOperationalSetup.Id).addError(Label.ErrorGmvModalUnbound);
            }
        }
    }

    public static void legacyIntegration(Map<Id,OperationalSetup__c> aMapNew) {
        TriggerCheck.assert();

        List<OperationalSetup__c> lEquipmentLst = new List<OperationalSetup__c>();
        List<OperationalSetup__c> lAbilityLst = new List<OperationalSetup__c>();
        for(OperationalSetup__c lOperationalSetup: aMapNew.values()){
           if(lOperationalSetup.RecordTypeId == EQUIPMENT_RECTYPE && lOperationalSetup.Status__c != IN_DEPLOYMENT){
                    lEquipmentLst.add(lOperationalSetup);
                }
                else if(lOperationalSetup.RecordTypeId == ABILITY_RECTYPE && lOperationalSetup.Status__c != IN_DEPLOYMENT){
                    lAbilityLst.add(lOperationalSetup);
                }    
        }
        if(lAbilityLst.isEmpty() && lEquipmentLst.isEmpty()) return;
         
        List<OperationalSetup__c> lEquipmentIntegrationLst = EquipmentWebService.getEquipmentToIntegration(lEquipmentLst);
        List<OperationalSetup__c> lAbilityIntegrationLst = AbilityWebService.getAbilityToIntegration(lAbilityLst);       

        List<OperationalSetup__c> lOperationalSetupLst = new List<OperationalSetup__c>();
        lOperationalSetupLst.addAll(lEquipmentIntegrationLst);
        lOperationalSetupLst.addAll(lAbilityIntegrationLst);

        if(!lOperationalSetupLst.isEmpty()) {         
            System.enqueueJob(new IntegrationHandler_cls(lOperationalSetupLst));
        }
    }

    public static void generateExternalId(List<OperationalSetup__c> aOpStpLstNew) {
        TriggerCheck.assert();
        
        Set<Id> lRectTypeIdSet = new Set<Id>();
        List<OperationalSetup__c> lOperationalSetupCreateIdLst = new List<OperationalSetup__c>();
        for(OperationalSetup__c lOppStp :aOpStpLstNew){
            if(lOppStp.Code__c == null){
                lOperationalSetupCreateIdLst.add(lOppStp);
                lRectTypeIdSet.add(lOppStp.RecordTypeId);   
            }               
        }
        if(lOperationalSetupCreateIdLst.isEmpty()) return;

        if(fSetupeIdMap == null || !fSetupeIdMap.keySet().containsAll(lRectTypeIdSet)){
            fSetupeIdMap = new Map<Id,Decimal>();
            for(AggregateResult lAgr :[SELECT MAX(Code__c) lastValue, RecordTypeId typeId FROM OperationalSetup__c WHERE RecordTypeId IN :lRectTypeIdSet AND RecordTypeId NOT IN :fSetupeIdMap.keySet() GROUP BY RecordTypeId]) {
                fSetupeIdMap.put((Id)lAgr.get('typeId'), (Decimal)lAgr.get('lastValue'));
            }
        }

        for(OperationalSetup__c lOppStp :lOperationalSetupCreateIdLst){
            Decimal lLastCode = fSetupeIdMap.get(lOppStp.RecordTypeId);
            if(lLastCode == null) lLastCode = 0;
            lOppStp.Code__c = ++lLastCode;
            fSetupeIdMap.put(lOppStp.RecordTypeId,lLastCode);
        }
    }      

    public static void validateExternalId(List<OperationalSetup__c> aOpStpLstNew) {

        Map<String,OperationalSetup__c> lOpStptValidateIdCodeMap = new Map<String,OperationalSetup__c>();
        Set<Id> lOpStptIdSet = new Set<Id>();
        Set<Id> lOpStptRecordIdSet = new Set<Id>();
        Set<Decimal> lOpStptCodeSet = new Set<Decimal>();

        for(OperationalSetup__c lOpStp :aOpStpLstNew){
            if(TriggerCheck.isChanged(lOpStp, OperationalSetup__c.Code__c) && lOpStp.Code__c != null){
                lOpStptValidateIdCodeMap.put(lOpStp.Code__c+''+lOpStp.RecordTypeId,lOpStp);
                lOpStptIdSet.add(lOpStp.Id);
                lOpStptRecordIdSet.add(lOpStp.RecordTypeId);
                lOpStptCodeSet.add(lOpStp.Code__c);
            }
        }
        if(lOpStptValidateIdCodeMap.isEmpty()) return;

        for(OperationalSetup__c lOpStp :[SELECT Code__c, RecordTypeId FROM OperationalSetup__c WHERE Code__c IN :lOpStptCodeSet AND Id NOT IN :lOpStptIdSet AND RecordTypeId IN :lOpStptRecordIdSet]){
            OperationalSetup__c lOpStpToNotify = lOpStptValidateIdCodeMap.get(lOpStp.Code__c+''+lOpStp.RecordTypeId);
            if(lOpStpToNotify != null){
                lOpStpToNotify.addError('Não é possível inserir um registro de Catálogo Logístico com o mesmo Código de outro já existente no Prisma.');
            }
        }
    }    

    public static void synchronizeRescuer(List<OperationalSetup__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lAbilityIdSet = new Set<Id>();
        for(OperationalSetup__c lOperationalSetup :aNewLst){
            if(lOperationalSetup.RecordTypeId == ABILITY_RECTYPE && 
                    TriggerCheck.isChanged(lOperationalSetup, OperationalSetup__c.Status__c) && 
                    !TriggerCheck.isChangedFromTo(lOperationalSetup, OperationalSetup__c.Status__c, IN_DEPLOYMENT, INACTIVE) && 
                    !TriggerCheck.isChangedFromTo(lOperationalSetup, OperationalSetup__c.Status__c,INACTIVE, IN_DEPLOYMENT)){
                lAbilityIdSet.add(lOperationalSetup.Id);
            }
        }
        if(lAbilityIdSet.isEmpty()) return;

        RescuerWebService_cls.setRescuerToSynchronize(lAbilityIdSet);
    }

    public static void providerAbilityUpdate(List<OperationalSetup__c> aNewLst){
        TriggerCheck.assert();

        Set<Id> lAbilityIdSet = new Set<Id>();
        for(OperationalSetup__c lAbility :aNewLst){
            if(lAbility.RecordTypeId == ABILITY_RECTYPE && TriggerCheck.isChanged(lAbility, OperationalSetup__c.Status__c) && !TriggerCheck.isChangedFromTo(lAbility, OperationalSetup__c.Status__c, IN_DEPLOYMENT, INACTIVE) && !TriggerCheck.isChangedFromTo(lAbility, OperationalSetup__c.Status__c,INACTIVE, IN_DEPLOYMENT)){
                lAbilityIdSet.add(lAbility.Id);
            }
        }
        if(lAbilityIdSet.isEmpty()) return;

        //lista com todas as junções ativas entre prestador e as habilidades que estão sendo vinculadas aos novos motivos
        List<EquipmentSupplyPart__c> lAbilityProviderJunctionLst = [SELECT Id, Provider__c FROM EquipmentSupplyPart__c WHERE Abiliity__c IN :lAbilityIdSet AND IsActive__c = true AND Provider__r.RecordTypeId = :PROVIDER_RECTYPE AND (Provider__r.Status__c != 'Inativo' AND Provider__r.Status__c != 'Cancelado')];
        system.debug('lAbilityProviderJunctionLst ' + lAbilityProviderJunctionLst);
        if(lAbilityProviderJunctionLst.isEmpty()) return;
        
        //Chama o método da EquipmentSupplyPartHandler_cls que integra os prestadores quando há mudança nos vínculos de habilidades
        EquipmentSupplyPartHandler_cls.newProviderAbility(lAbilityProviderJunctionLst);
    }

    public static void vehicleEquipmentUpdate(List<OperationalSetup__c> aNewLst){
        TriggerCheck.assert();

        Set<Id> lEquipmentIdSet = new Set<Id>();
        for(OperationalSetup__c lEquipment :aNewLst){
            if(lEquipment.RecordTypeId == EQUIPMENT_RECTYPE && TriggerCheck.isChanged(lEquipment, OperationalSetup__c.Status__c) && !TriggerCheck.isChangedFromTo(lEquipment, OperationalSetup__c.Status__c, IN_DEPLOYMENT, INACTIVE) && !TriggerCheck.isChangedFromTo(lEquipment, OperationalSetup__c.Status__c,INACTIVE, IN_DEPLOYMENT)){
                lEquipmentIdSet.add(lEquipment.Id);
            }
        }
        if(lEquipmentIdSet.isEmpty()) return;
        
        Set<Id> lVehicleToIntegrateSet = new Set<Id>();
        for(EquipamentVehicle__c lVehicle :[SELECT Vehicle__c FROM EquipamentVehicle__c WHERE Equipament__c IN :lEquipmentIdSet AND IsActive__c = true]){
            lVehicleToIntegrateSet.add(lVehicle.Vehicle__c);
        }
        if(lVehicleToIntegrateSet.isEmpty()) return;

        VehicleWebService_cls.setVehicleToSynchronize(lVehicleToIntegrateSet);
    }

    public static void providerEquipmentUpdate(List<OperationalSetup__c> aNewLst){
        TriggerCheck.assert();

        Set<Id> lEquipmentIdSet = new Set<Id>();
        for(OperationalSetup__c lEquipment :aNewLst){
            if(lEquipment.RecordTypeId == EQUIPMENT_RECTYPE && TriggerCheck.isChanged(lEquipment, OperationalSetup__c.Status__c) && 
                (TriggerCheck.isChangedFromTo(lEquipment, OperationalSetup__c.Status__c, ACTIVE, INACTIVE) || 
                TriggerCheck.isChangedFromTo(lEquipment, OperationalSetup__c.Status__c, ACTIVE, IN_DEPLOYMENT) || 
                TriggerCheck.isChangedFromTo(lEquipment, OperationalSetup__c.Status__c, INACTIVE, ACTIVE) || 
                TriggerCheck.isChangedFromTo(lEquipment, OperationalSetup__c.Status__c, IN_DEPLOYMENT, ACTIVE))){
                    
                lEquipmentIdSet.add(lEquipment.Id);
            }
        }
        if(lEquipmentIdSet.isEmpty()) return;
        
        Set<Id> lProviderToIntegrateSet = new Set<Id>();
        for(ProviderEquipment__c lProvider :[SELECT Provider__c FROM ProviderEquipment__c WHERE Equipment__c IN :lEquipmentIdSet AND IsActive__c = true]){
            lProviderToIntegrateSet.add(lProvider.Provider__c);
        }
        if(lProviderToIntegrateSet.isEmpty()) return;

         // System.debug('Set de prestadores para integrar ------------------> ' + lProviderIdSet);
         if(lProviderToIntegrateSet.isEmpty()) return;
         SpecialtyWrapper_cls lSObjectToIntegrateLst = ProviderEquipamentWebService_cls.newProviderEquipament(lProviderToIntegrateSet);
         
         if(lSObjectToIntegrateLst != null){
             System.enqueueJob(new IntegrationHandler_cls(lSObjectToIntegrateLst));
         }
    }

    
}