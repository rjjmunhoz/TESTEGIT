/**************************************************************************************************************
* Globant Brasil
* @author        	Misael Ribas (misael.ribas@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para gerar a cobertura das classes CaseHandler
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0     2019-12-16      Misael Ribas            class created 
            1.1     2020-02-18      Matheus Branco          class update to coverage
**************************************************************************************************************/

@isTest
public class GenericItem_tst {
   
    @isTest
    static void PickListTest(){
        PickList_ctr.getPickListValuesIntoList('Case', 'CloseOrder__c');
    }
     
    @isTest
    static void EmailFormTest(){
        
        Case lCase = CaseFactory.createCasePrototyping();
        insert lCase;
        
        ContentVersion lContentDoc = new ContentVersion();
        lContentDoc.Title = 'My Doc';
        lContentDoc.ContentUrl= 'test.com';
        insert lContentDoc;
        
        ContentDocument lDoc = [SELECT Id FROM ContentDocument LIMIT 1];
            
		ContentDocumentLink lContentlink=new ContentDocumentLink();
		lContentlink.LinkedEntityId=lCase.id;
		lContentlink.ShareType= 'v';
		lContentlink.LinkedEntityId = lCase.Id; 
		lContentlink.ContentDocumentId = lDoc.Id;
		lContentlink.Visibility = 'AllUsers'; 
		insert lContentlink;
        
        String lString;
        List<String> lStringlst = new List<String>();
        for(Integer i = 0; i<5; i++){
            lString = 'teste'+i+'@portosocorro.com';
            lStringlst.add(lString);
        }
        EmailForm_ctr.sendEmailFunction(Boolean.valueOf('true') , String.valueOf(lCase.Id), 'aBoddy', 'aSubject', lStringlst);
    }

}