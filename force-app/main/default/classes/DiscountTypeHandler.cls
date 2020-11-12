/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de DiscountType
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-09-03      Eduardo Costa           class created 
**************************************************************************************************************/
public with sharing class DiscountTypeHandler {

    /*
    Método utilizado para bloquear a criação de tipos de descontos do mesmo tipo e prioridade com
    o status igual a Ativo, porém desconsidera se a prioridade dor nula
    */
    public static void duplicateRuleDiscountType(List<DiscountType__c> aDiscountTypeNewLst) {

        TriggerCheck.assert();

        Set<String> lTypeSet = new Set<String>();
        Set<Id> lDiscountTypeIdSet = new Set<Id>();
        Set<String> lPrioritySet = new Set<String>();
        Map<String,DiscountType__c> lDiscountTypeKeyMap = new Map<String,DiscountType__c>();
        for(DiscountType__c lDiscountType :aDiscountTypeNewLst){
            if(TriggerCheck.isChanged(lDiscountType, DiscountType__c.Type__c) || 
                    TriggerCheck.isChanged(lDiscountType, DiscountType__c.Priority__c) || 
                    TriggerCheck.isChanged(lDiscountType, DiscountType__c.Status__c)) {
                if(lDiscountType.Status__c == Label.ActiveDiscountTypeStatus && lDiscountType.Priority__c != null) {
                    String lKey = lDiscountType.Type__c + lDiscountType.Priority__c + lDiscountType.Status__c;
                    if(lDiscountTypeKeyMap.containsKey(lKey)) {
                        lDiscountType.addError(Label.DuplicateDiscountTypeAlert);
                    }
                    else {
                        lDiscountTypeKeyMap.put(lKey,lDiscountType);
                    }    
                    lTypeSet.add(lDiscountType.Type__c);
                    lDiscountTypeIdSet.add(lDiscountType.Id);                
                    lPrioritySet.add(lDiscountType.Priority__c);
                }
            }   
        }  

        for(DiscountType__c lDiscountType :[SELECT Type__c, Priority__c, Status__c 
                FROM DiscountType__c 
                WHERE Type__c IN :lTypeSet
                AND Priority__c IN :lPrioritySet
                AND Status__c = :Label.ActiveDiscountTypeStatus
                AND Id NOT IN :lDiscountTypeIdSet]) {
            String lKey = lDiscountType.Type__c + lDiscountType.Priority__c + lDiscountType.Status__c;
            if(lDiscountType.Priority__c != null && lDiscountTypeKeyMap.containsKey(lKey)) {
                DiscountType__c lDiscountTypeToShowError = lDiscountTypeKeyMap.get(lKey);
                lDiscountTypeToShowError.addError(Label.DuplicateDiscountTypeAlert);
            }
        }
    }
}