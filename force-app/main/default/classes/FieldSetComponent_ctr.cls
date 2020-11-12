/*
 * @Created Date:- 21th APRIL 2018
 * @Author : AMIT SINGH
 * @Description : Class used for the lightning component which illustrate how to use Field Set in 
 *              : Salesforce Lightning Component
 * @Company : sfdcpanther
 * @Name : FieldSetComponentController
 */ 
public class FieldSetComponent_ctr {
	/*
     * @Created Date:- 21th APRIL 2018
     * @Author : AMIT SINGH
     * @Name : getFieldSetMember
     * @ReturnType : String
     * @param : String objectName , String fieldSetName
     * @Description : List all the Fields that are added into the FielsSet
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getFieldSetMember(String objectName , String fieldSetName){        
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        
        List<String> lFieldslst = new List<String>();
        for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
            lFieldslst.add(fieldMember.getFieldPath());
        }   
        return lFieldslst;
    }    
    
    /*
     * @Description : Wrapper class contains the information about all the fields of a FieldSet
     */ 
    public class FieldSetMemberWrapperClass{        
        @AuraEnabled public Boolean isDBRequired 					    { get; set; }
        @AuraEnabled public Boolean isRequired 						    { get; set; }
        @AuraEnabled public String fieldType 						    { get; set; }
        @AuraEnabled public String fieldLabel 						    { get; set; }
        @AuraEnabled public String fieldAPIName 					    { get; set; }
        @AuraEnabled public List<Schema.PicklistEntry> pickListValues   { get; set; }        
    }
}