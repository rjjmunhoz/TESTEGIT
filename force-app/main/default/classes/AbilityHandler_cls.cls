/**************************************************************************************************************
* Globant Brasil
* @author        	Misael RIbas (misael.ribas@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de Ability
*
* Changes (Version)-
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-08      Misael RIbas           class created 
* @version   1.1    2020-05-26      Jean Sganzerla         providerReasonUpdate implementation 
* @version   1.2    2020-05-27      Matheus Branco          Update ValidateJunctionAbility method
**************************************************************************************************************/
public class AbilityHandler_cls {

    private static final String PROVIDER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProviderRecordType).getRecordTypeId();
    private static final String ABILITYRESCUER_RECTYPE = SObjectType.Ability__c.getRecordTypeInfosByDeveloperName().get(Label.RescuerAbilityLabel).getRecordTypeId();
    private static final String ABILITYREASON_RECTYPE = SObjectType.Ability__c.getRecordTypeInfosByDeveloperName().get(Label.ReasonAbilityLabel).getRecordTypeId();

    public static void ValidateJunctionAbility(List<Ability__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lAbilitySet = new Set<Id>();
        Set<Id> lProduct2Set = new Set<Id>();
        Set<Id> lAbilityRescuerSet = new Set<Id>();
        Set<Id> lRescuerSet = new Set<Id>();
        for(Ability__c lAbility :aNewLst){
            lAbilitySet.add(lAbility.OperationalSetup__c);
            lProduct2Set.add(lAbility.Product2__c);
            lAbilityRescuerSet.add(lAbility.Ability__c);
            lRescuerSet.add(lAbility.RescuerId__c);
        }

        Set<String> lRecordsAbilityReasonSet = new Set<String>();
        Set<String> lRecordsAbilityRescuerSet = new Set<String>();
        for(Ability__c lAbility :[SELECT Product2__c, OperationalSetup__c, Ability__c, RescuerId__c FROM Ability__c WHERE (OperationalSetup__c =: lAbilitySet AND Product2__c =: lProduct2Set) OR (Ability__c =: lAbilityRescuerSet AND RescuerId__c =: lRescuerSet)]){
            if(lAbility.OperationalSetup__c != null){
                lRecordsAbilityReasonSet.add(lAbility.Product2__c +''+lAbility.OperationalSetup__c);
            }
            if(lAbility.Ability__c != null){
                lRecordsAbilityRescuerSet.add(lAbility.RescuerId__c+''+lAbility.Ability__c);
            }
        }
        if(!lRecordsAbilityReasonSet.isEmpty()){
            for(Ability__c lAbility :aNewLst){
                if(lRecordsAbilityReasonSet.contains(lAbility.Product2__c +''+lAbility.OperationalSetup__c)){
                    lAbility.addError(Label.ErrorSpecialtyAbility);
                }
            }
        }

        if(!lRecordsAbilityRescuerSet.isEmpty()){
            for(Ability__c lAbility :aNewLst){
                if(lRecordsAbilityRescuerSet.contains(lAbility.RescuerId__c+''+lAbility.Ability__c)){
                    lAbility.addError(Label.ErrorContactAbility);
                }
            }
        }
    }

    public static void synchronizeRescuer(List<Ability__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lAbilityToSearchIdSet = new Set<Id>();
        for(Ability__c lAbility :aNewLst){
            if(TriggerCheck.isChanged(lAbility, Ability__c.OperationalSetup__c) || 
                    TriggerCheck.isChanged(lAbility, Ability__c.Product2__c) || 
                    TriggerCheck.isChanged(lAbility, Ability__c.RescuerId__c) || 
                    TriggerCheck.isChanged(lAbility, Ability__c.Ability__c)  || 
                    TriggerCheck.isChanged(lAbility, Ability__c.IsActive__c) ) {
                if(lAbility.OperationalSetup__c != null) {
                    lAbilityToSearchIdSet.add(lAbility.OperationalSetup__c);
                }
                if(lAbility.Ability__c != null) {
                    lAbilityToSearchIdSet.add(lAbility.Ability__c);
                }
                
            }            
        }
        if(lAbilityToSearchIdSet.isEmpty()) return;

        RescuerWebService_cls.setRescuerToSynchronize(lAbilityToSearchIdSet);
    }

    public static void providerReasonUpdate(List<Ability__c> aNewLst){
        TriggerCheck.assert();

        Set<Id> lAbilityIdSet = new Set<Id>();
        for(Ability__c lAbility :aNewLst){
            if(TriggerCheck.isChanged(lAbility, Ability__c.IsActive__c) && lAbility.OperationalSetup__c != null){ // OperationalSetup__c Campo utilizado somente para relacionar habilidade com motivo, ou seja se esse campo não estiver nulo, esse registro é junção motivoXhabilidade
                lAbilityIdSet.add(lAbility.OperationalSetup__c);
            }
        }   

        //lista com todas as junções ativas entre prestador e as habilidades que estão sendo vinculadas aos novos motivos
        List<EquipmentSupplyPart__c> lAbilityProviderJunctionLst = [SELECT Id, Provider__c FROM EquipmentSupplyPart__c WHERE Abiliity__c IN :lAbilityIdSet AND IsActive__c = true AND Provider__r.RecordTypeId = :PROVIDER_RECTYPE AND (Provider__r.Status__c != :Label.Status_Inactive AND Provider__r.Status__c != :Label.StatusCanceled)];
        if(lAbilityProviderJunctionLst.isEmpty()) return;
        
        //Chama o método da EquipmentSupplyPartHandler_cls que integra os prestadores quando há mudança nos vínculos de habilidades
        EquipmentSupplyPartHandler_cls.newProviderAbility(lAbilityProviderJunctionLst);
    }
}