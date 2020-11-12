@isTest
public class AccessManagementWebService_tst {
	
    @isTest
    static void LdapCreatedUser(){
        
        Mockcreate(200);
        test.startTest();
        	makeData('1');
        	system.runAs(New User(Id = UserInfo.getUserId())) {
       	 		Contact lContact = [SELECT Id, Email FROM Contact LIMIT 1];
        		lContact.Email = 'Test@portosocorro.com'; 
        		update lContact;
            }
    	test.stopTest();
        
        Account lAccount = [SELECT Id, isPartner FROM Account LIMIT 1];
        System.assertEquals(lAccount != null,true);
        
        System.assertEquals(lAccount.IsPartner == true,true);
        User lUser = [SELECT Id, ContactId, Email FROM User LIMIT 1];
        System.assertEquals(lUser != null,true);
        
		deleteData();
    }
    
    @isTest
    static void LdapContactInactive(){
        
        Mockcreate(200);
        test.startTest();
        	makeData('1');
        	system.runAs(New User(Id = UserInfo.getUserId())) {
        		Contact lContact = [SELECT Id, Email, Status__c FROM Contact LIMIT 1];
        		lContact.Email = 'teste789@teste.com';
        		lContact.Status__c = 'Inativo'; 
        		update lContact;
            }
        test.stopTest();
        deleteData();
    }
    
    @isTest
    static void LdapUpdateEmail(){
        
        Mockcreate(200);
        test.startTest();
        	makeData('12');
        	system.runAs(New User(Id = UserInfo.getUserId())) {
        		Contact lContact = [SELECT Id, Email FROM Contact LIMIT 1];
        		lContact.Email = 'Test789@portosocorro.com'; 
        		update lContact;
            }
        test.stopTest();
        Account lAccount = [SELECT Id, isPartner FROM Account LIMIT 1];
        User lUser = [SELECT Id, ContactId, Email FROM User LIMIT 1];
        
		deleteData();
    }
    
    @isTest
    static void LdapError(){
        
        Mockcreate(500);
        test.startTest();
        	makeData('1');
        	system.runAs(New User(Id = UserInfo.getUserId())) {
        		Contact lContact = [SELECT Id, Email, Status__c FROM Contact LIMIT 1];
        		update lContact;
            }
        test.stopTest();
        deleteData();
    }
    
    static void makeData(String aKey){
        UserRole lRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'RoleAnalyst' LIMIT 1];
		User lUserOwnerAccount = UserFactory.createUser();
        lUserOwnerAccount.UserRoleId = lRole.Id;
        insert lUserOwnerAccount;  
        system.runAs(lUserOwnerAccount) {
            Account lAccount = AccountFactory.createAccountProvider();
            lAccount.OwnerId = lUserOwnerAccount.Id;
        	insert lAccount;
        
        	Contact lContact = ContactFactory.createContactBaseEmployee(lAccount.Id);
        	lContact.Role__c = 'Administrativo';
        	insert lContact;
        
        	if(aKey.contains('1')){
        		lContact.Status__c = 'Ativo';
        		update lContact;
        	}
        
        	if(aKey.contains('2')){
            
				User lUser = UserFactory.createUserProviderCommunity(lContact.Id);
				lUser.IsActive = true;
				insert lUser;
			}
		}
    }
    
    static void deleteData(){
        
        List<Contact> lContactLst = [SELECT Id, lgpdStatus__c FROM Contact LIMIT 1];
        if(!lContactLst.isEmpty()){
        	for(Contact lContact: lContactLst){
        	    lContact.lgpdStatus__c = 'P';
        	}
        	LgpdProcessContact_sch_bch lBatch = new LgpdProcessContact_sch_bch();
        	Database.executeBatch(lBatch);
        	
        	List<Vehicle__c> lVehicleLst = [SELECT Id FROM Vehicle__c LIMIT 1];
        	if(!lVehicleLst.isEmpty()) delete lVehicleLst;
        }
    }
    
    static void Mockcreate(Integer aCode){
        
        WebserviceConfiguration__mdt lTokenConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = :Label.TokenAWSEndPoint];
        WebserviceConfiguration__mdt lLdapConf = [SELECT EndPoint__c FROM WebserviceConfiguration__mdt WHERE DeveloperName = 'SocorristasLogin'];
        
        String lLdapEndpoint = lLdapConf.EndPoint__c;
        
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource(lTokenConf.EndPoint__c,Label.String_Token);
        lMultimock.setStaticResource(lLdapEndpoint,'MockSocorristaLogin');
        lMultimock.setStatusCode(aCode);
        lMultimock.setHeader(Label.String_Content_Type, Label.String_Application_JSON);
        Test.setMock(HttpCalloutMock.class, lMultimock);
        
        HTTPResponse res = getInfoFromExternalService(lLdapConf.EndPoint__c);
        
        System.assertEquals(aCode,res.getStatusCode());
        System.assertEquals(res.getHeader('Content-Type').contains('application/json'),true); 
        
    }
    
    static HttpResponse getInfoFromExternalService(String lEndPoint) {
        HttpRequest lRequest = new HttpRequest();
        lRequest.setEndpoint(lEndPoint);
        lRequest.setMethod('GET');
        Http lHttp = new Http();
        HttpResponse lResponse = lHttp.send(lRequest);
        
        return lResponse;
    }
}