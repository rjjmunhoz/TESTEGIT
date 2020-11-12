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
* @version   1.0    2020-09-01      Mariana Ribeiro         class created 
**************************************************************************************************************/
public without sharing class AccessManagementWebService_cls extends AWS_API{

    private static final String USER = Label.RescuerLogin;

    private static final Map<String,String> statusMap {
        get {
            if(statusMap != null) {
                return statusMap;
            }
            else {
                statusMap = new Map<String,String>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'UserPortalStatus' AND IsActive__c = true]) {
                    statusMap.put(lLegacyDomainTableValue.Key__c, lLegacyDomainTableValue.Value__c);
                }
                return statusMap;
            }            
        }
        set;
    }

	public String Nome;
	public String Cpf;
	public String Email;
	public String Status;

    public AccessManagementWebService_cls(SObject aUser) {
        super(USER);        
        User lUser = (User)aUser;

        this.Nome = String.isNotBlank(lUser.FirstName)?(lUser.FirstName + ' ' + lUser.LastName):lUser.LastName;
        this.Cpf = String.isNotBlank(lUser.Contact.CPF__c)?lUser.Contact.CPF__c:null;
        this.Email = lUser.Email;
        this.Status = statusMap.get(lUser.Contact.Status__c == Label.Status_Active? Label.Status_Active: Label.Status_Inactive);
    }

    public AWS_API.ResponseWrapper setAwsUser(){
		this.fReq.setBody(JSON.serialize(this));
		AWS_API.ResponseWrapper lResult =  this.doRequest();        
        return lResult;
    }

    @InvocableMethod(label='Ativa ou inativa usuários do portal de prestadores' description='Método que cria ou atualiza como ativo ou inativo os usuários da comunidade de prestadores' category='Contact')
    public static void getCreateOrUpdateProviderPortalUser(List<ID> aIds) {
        getCreateOrUpdateProviderPortalUserFuture(aIds);
    }

    @future(callout=true)
    public static void getCreateOrUpdateProviderPortalUserFuture(List<ID> aIds) {
        Profile lProfileCommunity = [SELECT Id FROM Profile WHERE Name = :Label.String_Provider LIMIT 1];
        Map<Id,User> lUserContactMap = new Map<Id,User>();
        for (User lUser : [SELECT Id, Name, FirstName, LastName, ContactId, Contact.CPF__c, Contact.Status__c, IsActive, Email FROM User WHERE ContactId IN :aIds]) {
            lUserContactMap.put(lUser.ContactId, lUser);
        }

        //Lista de usuários que serão enviados via API, porém não terão usuários criados no Salesforce neste momento
        List<User> lUserToCreateFakeLst = new List<User>();


        List<User> lUserToCreateLst = new List<User>();
        List<User> lUserToUpdateLst = new List<User>();
        List<User> lUserToIntegrationLst = new List<User>();
        Set<String> lRoleStringSet = new Set<String>();
        
        for (Contact lContact : [SELECT Id, Email, FirstName, LastName, Status__c, QRA__c, CPF__c, Role__c FROM Contact WHERE Id in :aIds]) {
            if(lUserContactMap.containsKey(lContact.Id)) {
                // instancia o usuário na lista de criação/atualização
                // Ativa ou inativa o usuário com base no status do contato
                // Atualiza o email do usuário se estiver diferente do contato
                User lUser = lUserContactMap.get(lContact.Id);
                if(lContact.Status__c == Label.Status_Active){
                    lUser.IsActive = true;
                    if(lUser.Email != lContact.Email){
                        lUser.Email = lContact.Email;
                    }
                }else{
                    lUser.IsActive = false;
                }
                lUserToUpdateLst.add(lUser);
            }
            else {
                // instancia o usuário na lista de criação/atualização com base nas informações do contato
                User lUser = new User();
                lUser.Alias = String.isNotBlank(lContact.FirstName)? lContact.FirstName.left(1)+lContact.LastName.replace(' ', '').left(4): lContact.LastName.replace(' ', '').left(4);
                lUser.CommunityNickName = String.valueOf(lContact.QRA__c)+ lContact.LastName.replace(' ', '').left(4);
                lUser.ContactId = lContact.Id;
                lUser.Contact = lContact;
                lUser.Email = lContact.Email;
                lUser.EmailEncodingkey = Label.String_UTF8;
                lUser.FirstName = lContact.FirstName;
                lUser.LastName = lContact.LastName;
                lUser.IsActive = true;
                lUser.LanguageLocaleKey = 'pt_BR';
                lUser.ProfileId = lProfileCommunity.Id;
                lUser.UserName = String.valueOf(lContact.QRA__c)+Label.UsernameOrgDomain; 
                lUser.PortalRole = Label.PortalRoleManager; 
                lUser.LocaleSidKey = 'pt_BR'; 
                lUser.TimeZoneSidKey = Label.TimeZoneSP; 

                lRoleStringSet.addAll(Label.RoleRescuerHelperApprentice.split(','));
                if(lRoleStringSet.contains(lContact.Role__c)) {
                    lUserToCreateFakeLst.add(lUser);
                }
                else {
                    lUserToCreateLst.add(lUser);
                }                
            }
        }

        try {
            insert lUserToCreateLst;
            update lUserToUpdateLst;

            lUserToIntegrationLst.addAll(lUserToCreateFakeLst);
            lUserToIntegrationLst.addAll(lUserToCreateLst);
            lUserToIntegrationLst.addAll(lUserToUpdateLst);
        } catch (DmlException e) {
            // envia uma notificação personalizada dizendo que houve um erro na criação/atualização do usuário (e.getDmlMessage(0))  
            System.debug('e.getDmlMessage(0): '+e.getDmlMessage(0));          
            Map<String, Object> inputs = new Map<String, Object>();
            inputs.put(Label.TargetId, String.valueOf(Userinfo.getUserId()));
            inputs.put(Label.RecipientIds, new List<String>{Userinfo.getUserId()});
            inputs.put(Label.Title, Label.TitleMessageCommunityUserCatch);
            inputs.put(Label.Body, +e.getDmlMessage(0).left(750).stripHtmlTags());
            Flow.Interview.NotifySystem myFlow = new Flow.Interview.NotifySystem(inputs);
            myFlow.start();
        }

        // chamar a API para envio das informações do usuário
        // Ajustar a integrationHandler para receber a lista de usuários e iterar sobre a lista
        System.debug('lUserToIntegrationLst: '+ lUserToIntegrationLst);
        if(!lUserToIntegrationLst.isEmpty()) {
            System.enqueueJob(new IntegrationHandler_cls(lUserToIntegrationLst)); 
        }
    }
}