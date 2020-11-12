/**************************************************************************************************************
 * Globant Brasil
 * @author        	 Eduardo Borges (eduardo.borges@globant.com)
 * Project:          Porto Socorro
 * Description:      Controlador do componente de uso genérico Picklist
 *
 * Changes (Version)
 * -------------------------------------
 *           No.     Date            Author                  Description     
 *           -----   ----------      --------------------    ---------------   
 * @version   1.0    2019-12-19      Eduardo Borges          class created 
 **************************************************************************************************************/
public with sharing class PickList_ctr {
    @AuraEnabled        
    public static List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> getPickListValuesIntoList(String objectType, String selectedField){
        List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> pickListValuesList = new List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(new GenericWrapperClass_cls.PopulateSelectOptionsWrapper(pickListVal.getLabel(),pickListVal.getValue()));
        }     
        return pickListValuesList;
    }
}