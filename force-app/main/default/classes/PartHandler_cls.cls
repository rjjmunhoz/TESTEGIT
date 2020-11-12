/**************************************************************************************************************
* Globant Brasil
* @author        	Misael RIbas (misael.ribas@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de Part
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-08      Misael RIbas          class created 
**************************************************************************************************************/
public class PartHandler_cls {
public static void ValidateJunctionPart(List<Part__c> aNewLst){
        TriggerCheck.assert();
        
        Set<Id> lPartSet = new Set<Id>();
        Set<Id> lProduct2Set = new Set<Id>();
        for(Part__c lPart :aNewLst){
            lPartSet.add(lPart.OperationalSetup__c);
            lProduct2Set.add(lPart.SpecialtyDetail__c);
        }

        Set<String> lRecordsSet = new Set<String>();
    	//Map<Id,String> lRecordsMap = new Map<Id,String>();
        for(Part__c lPart :[SELECT SpecialtyDetail__c, OperationalSetup__c, Name FROM Part__c WHERE OperationalSetup__c =: lPartSet AND SpecialtyDetail__c =: lProduct2Set]){
           lRecordsSet.add(lPart.SpecialtyDetail__c +''+lPart.OperationalSetup__c);
           //lRecordsMap.put(lPart.SpecialtyDetail__c +''+lPart.OperationalSetup__c, lPart.Name);
        }
        system.debug('lRecordsSet ' + lRecordsSet);
        if(lRecordsSet.isEmpty()) return;

    	String lIdRecords;
        for(Part__c lPartRecord :aNewLst){
          	lIdRecords = lPartRecord.SpecialtyDetail__c +''+lPartRecord.OperationalSetup__c;
            if(lRecordsSet.contains(lIdRecords)/* && lRecordsMap.get(lIdRecords) != lPartRecord.Name*/){
                lPartRecord.addError(Label.ErrorPartDetailLinked);
            }
        }
    }
}