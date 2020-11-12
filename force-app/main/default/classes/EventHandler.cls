/**************************************************************************************************************
* Globant Brasil
* @author        	Misael Ribas (Misael.ribas@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de Atividade
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-12-27      Misael Ribas            Class created 
**************************************************************************************************************/
public class EventHandler {
	
    public static void countQRAsQuantity(Map<Id,Event> aNewMap){
        TriggerCheck.assert();
        
        List<Event> lEventlst = new List<Event>(); 
        for(Event lEvent :aNewMap.values()){
            if(lEvent.WhatId != null){
                String WhatIdValue = lEvent.WhatId;
                if(TriggerCheck.isChanged(lEvent, Event.WhoCount) && lEvent.Subject == Label.Status_LineUpExecution && WhatIdValue.startsWith('500')){
                    lEventlst.add(lEvent);
                }
            }
        }
        //system.debug('lEventlst '+lEventlst.size());
        if(lEventlst.isEmpty()) return; 
        
        Set<Id> lCaseIdSet = new Set<Id>();
        Map<Id,Integer> lQuantityMap = new Map<Id,Integer>();
        for(Event lEvent :lEventlst){
        	lCaseIdSet.add(lEvent.WhatId);
            lQuantityMap.put(lEvent.WhatId,lEvent.WhoCount);
        }
        
        RecordType lRecordType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = :Label.PrototypingRecordType LIMIT 1];
        List<Case> lCaselst = [SELECT Id,QRAsQuantity__c FROM Case WHERE Id IN :lCaseIdSet AND RecordTypeId = :lRecordType.Id];
        
        Map<Id,Integer> lOtherTasks = new Map<Id,Integer>();        
        for(Event lEvent :[SELECT WhatId, WhoCount FROM Event WHERE WhatId IN :lCaseIdSet]){
            Integer lSum;
            if(lOtherTasks.containsKey(lEvent.WhatId)){
            	lSum = lOtherTasks.get(lEvent.WhatId) + lEvent.WhoCount;
            }
            else{
                lSum = lEvent.WhoCount;
            }            
            lOtherTasks.put(lEvent.WhatId,lSum);            
        }        
        for(Case lCaseEvent :lCaselst){
            if(trigger.isUpdate){
                lCaseEvent.QRAsQuantity__c = lOtherTasks.get(lCaseEvent.Id);
            }
            else{ 
                lCaseEvent.QRAsQuantity__c = lQuantityMap.get(lCaseEvent.Id) + lOtherTasks.get(lCaseEvent.Id);                
            }
        }        
        update lCaselst; 
    }
}