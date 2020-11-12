/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService dos usuários do Portal
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-10-15      Mariana Ribeiro         class created 
**************************************************************************************************************/
public class BellNotification_cls {

    // BellNotification_cls.notifyCurrentUser( 'Hello, World!', 'Titulo', 'NomeAPI' );
    @future(callout=true)
    public static void notifyCurrentUser( String aMessage, String aTitle, String aDeveloperName) {
        Http lHttp = new Http();
        HttpRequest lRequest = new HttpRequest();
        lRequest.setEndpoint( Url.getOrgDomainUrl().toExternalForm()
            + Label.EndPointBellNotification );
        lRequest.setMethod( Label.SetMethodPost);
        lRequest.setHeader( Label.String_Authorization, Label.String_Bearer+' ' + UserInfo.getSessionId() );
        lRequest.setHeader( Label.String_Content_Type, Label.String_ApplicationJSON );

        CustomNotificationType lCustonNotification = [SELECT Id, DeveloperName, Description FROM CustomNotificationType WHERE DeveloperName =: aDeveloperName  ORDER BY DeveloperName LIMIT 1];

        CustomNotificationActionInput lInput = new CustomNotificationActionInput();
        lInput.customNotifTypeId = lCustonNotification.Id;
        lInput.recipientIds = new List<String>{UserInfo.getUserId()};
        lInput.title = aTitle;
        lInput.body = aMessage;
        lInput.targetId = lCustonNotification.Id;
        CustomNotificationAction lAction = new CustomNotificationAction();
        lAction.inputs = new List< CustomNotificationActionInput > { lInput };
        lRequest.setBody( JSON.serialize( lAction ) );
        HttpResponse lResp = lHttp.send( lRequest );
        System.debug( lResp.getBody() );
    }

    public class CustomNotificationAction {
        public List<CustomNotificationActionInput> inputs { get; set; }
    }

    public class CustomNotificationActionInput {
        public String customNotifTypeId { get; set; }
        public List< String > recipientIds { get; set; }
        public String title { get; set; }
        public String body { get; set; }
        public String targetId { get; set; }
    }
}