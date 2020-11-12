public class EmailForm_ctr{
    @AuraEnabled
    public static void sendEmailFunction(Boolean aSendAttach, String aCaseId, String aBoddy, String aSubject, List<String> aEmailDest){
       
        Messaging.SingleEmailMessage lMail = new Messaging.SingleEmailMessage();
        lMail.setToAddresses(aEmailDest);
        lMail.setSenderDisplayName(Label.String_PortoSocorro);
        lMail.setSubject(aSubject);
        lMail.setHtmlBody(aBoddy);               
        
        if(aSendAttach){
            List<Id> lLinkedIdSet = new List<Id>();
            for(ContentDocumentLink lLink :[SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = :aCaseId]){
                lLinkedIdSet.add(lLink.ContentDocumentId);
            }                
            List<Id> lAttachments = new List<Id>();
            for(ContentVersion lContentVersion :[SELECT Id FROM ContentVersion WHERE ContentDocumentId IN :lLinkedIdSet]){
                lAttachments.add(lContentVersion.Id);
            }
            lMail.setEntityAttachments(lAttachments);
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { lMail });
    }
}