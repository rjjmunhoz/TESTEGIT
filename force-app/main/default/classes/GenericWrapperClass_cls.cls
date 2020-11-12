/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Classe genérica para armazenar todas as classes wrapper utilizadas na ORG
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-01-17      Jean Sganzerla          class created 
**************************************************************************************************************/
public class GenericWrapperClass_cls {
    
    public class PopulateSelectOptionsWrapper {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        public PopulateSelectOptionsWrapper(String aLabel, String aValue) {
            this.label = aLabel;
            this.value = aValue;
        }
    }

    public class PopulateSizingComponent{
        @AuraEnabled public List<PopulateSelectOptionsWrapper> lSegmentLst = new List<PopulateSelectOptionsWrapper>();
        @AuraEnabled public List<PopulateSelectOptionsWrapper> lStatuLst = new List<PopulateSelectOptionsWrapper>();
        @AuraEnabled public List<PopulateSelectOptionsWrapper> lUF = new List<PopulateSelectOptionsWrapper>();
        @AuraEnabled public List<PopulateSelectOptionsWrapper> lType = new List<PopulateSelectOptionsWrapper>();
        @AuraEnabled public List<PopulateSelectOptionsWrapper> lBusiness = new List<PopulateSelectOptionsWrapper>();
    }
    public class PopulateSizingWrapper{
        @AuraEnabled public String value;
        @AuraEnabled public Date dateValue;
    }

    public class PopulateGridComponent{
        @AuraEnabled public List<String> lCodSizing = new List<String>();
        @AuraEnabled public List<String> lNameSizing = new List<String>();
        @AuraEnabled public List<String> lBusinessSizing = new List<String>();
        @AuraEnabled public List<String> lSegmentSizing = new List<String>();
        @AuraEnabled public List<String> lStatusSizing = new List<String>();
        @AuraEnabled public List<String> lTypeSizing = new List<String>();
        @AuraEnabled public List<String> lModalSizing = new List<String>();
        @AuraEnabled public List<String> lUFSizing = new List<String>();
        @AuraEnabled public List<Date> lTreeMounths = new List<Date>();
        @AuraEnabled public List<Date> lToday = new List<Date>();
    }
   
}