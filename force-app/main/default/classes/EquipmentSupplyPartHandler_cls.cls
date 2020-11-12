/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Class to handle the EquipmentSupplyPart_trg logic
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-06-15      Jean Sganzerla          Handle new Ability to a Provider
**************************************************************************************************************/
public class EquipmentSupplyPartHandler_cls {

    private static final String PROVIDER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProviderRecordType).getRecordTypeId();

    public static void newProviderAbility(List<EquipmentSupplyPart__c> aNewLst){
        TriggerCheck.assert();

        Set<Id> lProviderIdSet = new Set<Id>();
        for(EquipmentSupplyPart__c lProvider :aNewLst){
            lProviderIdSet.add(lProvider.Provider__c);
        }
        // System.debug('Set de prestadores para integrar ------------------> ' + lProviderIdSet);
        if(lProviderIdSet.isEmpty()) return;
        SpecialtyWrapper_cls lSObjectToIntegrateLst = ProviderSpecialtyWebService_cls.newProviderAbility(lProviderIdSet);
        
        if(lSObjectToIntegrateLst != null){
            System.enqueueJob(new IntegrationHandler_cls(lSObjectToIntegrateLst));
        }
    }

    public static void duplicityControl(List<EquipmentSupplyPart__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lProviderSet = new Set<Id>();
        Set<Id> lAbilitySet = new Set<Id>();
        for(EquipmentSupplyPart__c lAbility :aNewLst){
            lProviderSet.add(lAbility.Provider__c);
            lAbilitySet.add(lAbility.Abiliity__c);
        }

        Set<String> lRecordsSet = new Set<String>();
        for(EquipmentSupplyPart__c lAbility :[SELECT Provider__c, ProviderPart__c, Account__c, ProviderInputs__c, Abiliity__c, OperationalSetup__c, Input__c, Part__c FROM EquipmentSupplyPart__c WHERE Provider__c IN :lProviderSet AND (Abiliity__c IN :lAbilitySet OR OperationalSetup__c IN :lAbilitySet OR Input__c IN :lAbilitySet OR Part__c IN :lAbilitySet)]){

            system.debug('lAbility: ' + lAbility);
            if(lAbility.Provider__c != null && lAbility.Abiliity__c != null){
                lRecordsSet.add(lAbility.Provider__c +''+lAbility.Abiliity__c);
            }
            else if(lAbility.Account__c != null && lAbility.OperationalSetup__c != null){
                lRecordsSet.add(lAbility.Account__c +''+lAbility.OperationalSetup__c);
            }
            else if(lAbility.ProviderInputs__c != null && lAbility.Input__c != null){
                lRecordsSet.add(lAbility.ProviderInputs__c +''+lAbility.Input__c);
            }
            else if(lAbility.ProviderPart__c != null && lAbility.Part__c != null){
                lRecordsSet.add(lAbility.ProviderPart__c +''+lAbility.Part__c);
            }
        }
        system.debug('lRecordsSet ' + lRecordsSet);
        if(lRecordsSet.isEmpty()) return;
        
        for(EquipmentSupplyPart__c lAbility :aNewLst){
            if(lRecordsSet.contains(lAbility.Provider__c +''+lAbility.Abiliity__c) && lAbility.Account__c == null && lAbility.OperationalSetup__c == null && lAbility.ProviderInputs__c == null && lAbility.Input__c == null && lAbility.ProviderPart__c == null && lAbility.Part__c == null){
                lAbility.addError(Label.ErrorAbilityProviderLinked);
            }
            else if(lRecordsSet.contains(lAbility.Account__c +''+lAbility.OperationalSetup__c) && lAbility.ProviderInputs__c == null && lAbility.Input__c == null && lAbility.ProviderPart__c == null && lAbility.Part__c == null && lAbility.Provider__c == null && lAbility.Abiliity__c == null){
                lAbility.addError(Label.ErrorEquipmentSupplierLinked);
            }
            else if(lRecordsSet.contains(lAbility.ProviderInputs__c +''+lAbility.Input__c) && lAbility.Account__c == null && lAbility.OperationalSetup__c == null && lAbility.ProviderPart__c == null && lAbility.Part__c == null && lAbility.Provider__c == null && lAbility.Abiliity__c == null){
                lAbility.addError(Label.ErrorInputSupplierLinked);
            }
            else if(lRecordsSet.contains(lAbility.ProviderPart__c +''+lAbility.Part__c) && lAbility.Account__c == null && lAbility.OperationalSetup__c == null && lAbility.ProviderInputs__c == null && lAbility.Input__c == null && lAbility.Provider__c == null && lAbility.Abiliity__c == null){
                lAbility.addError(Label.ErrorPartSupplierLinked);
            }
        }
    }
}