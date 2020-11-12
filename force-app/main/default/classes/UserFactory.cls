@isTest
public class UserFactory {
    
    public static User createUser(){
        
        //UserRole lRole = new UserRole(DeveloperName = 'TestPorto', Name = 'My test');
        //insert lRole;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
		system.debug('profileId ' + profileId);
		system.debug('Label.SystemAdministrator ' + Label.SystemAdministrator);
        
        Double randomNumber = Double.valueof((Math.random() * 11 + 8 + Math.random()));
        User lUser = new User(
     		ProfileId = profileId.Id,
     		LastName = 'Test',
     		Email = 'Test@portosocorro.com',
     		Username = 'Test'+randomNumber+'@portosocorro.com',
			CompanyName = 'Test',
     		Title = 'Test',
     		Alias = 'Test',
     		TimeZoneSidKey = 'America/Los_Angeles',
     		EmailEncodingKey = 'UTF-8',
     		LanguageLocaleKey = 'en_US',
     		LocaleSidKey = 'en_US'
            //,
     		//UserRoleId = lRole.Id
		);
        return lUser;
    }
    
    public static User createUserAnalist(){
		
		UserRole lRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'RoleAnalyst' LIMIT 1];

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Relacionamento' LIMIT 1];
		system.debug('profileId ' + profileId);
        
        Double randomNumber = Double.valueof((Math.random() * 11 + 8 + Math.random()));
        User lUser = new User(
     		ProfileId = profileId.Id,
     		LastName = 'Test',
     		Email = 'Test@portosocorro.com',
     		Username = 'Test'+randomNumber+'@portosocorro.com',
			CompanyName = 'Test',
     		Title = 'Test',
     		Alias = 'Test',
     		TimeZoneSidKey = 'America/Los_Angeles',
     		EmailEncodingKey = 'UTF-8',
     		LanguageLocaleKey = 'en_US',
     		LocaleSidKey = 'en_US',
            UserRoleId = lRole.Id
		);
        return lUser;
	}
    
    public static User createUserRecruiter(){
		
		UserRole lRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'RoleAnalyst' LIMIT 1];

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Seleção' LIMIT 1];
		system.debug('profileId ' + profileId);
        
        Double randomNumber = Double.valueof((Math.random() * 11 + 8 + Math.random()));
        User lUser = new User(
     		ProfileId = profileId.Id,
     		LastName = 'Test',
     		Email = 'Test@portosocorro.com',
     		Username = 'Test'+randomNumber+'@portosocorro.com',
			CompanyName = 'Test',
     		Title = 'Test',
     		Alias = 'Test',
     		TimeZoneSidKey = 'America/Los_Angeles',
     		EmailEncodingKey = 'UTF-8',
     		LanguageLocaleKey = 'en_US',
     		LocaleSidKey = 'en_US',
            UserRoleId = lRole.Id
		);
        return lUser;
	}
    
    public static User createUserProviderCommunity(Id aContactId){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Prestador' LIMIT 1];
		system.debug('profileId ' + profileId);
        
        Double randomNumber = Double.valueof((Math.random() * 11 + 8 + Math.random()));
        User lUser = new User(
     		ProfileId = profileId.Id,
     		LastName = 'Test',
     		Email = 'Test@portosocorro.com',
     		Username = 'Test'+randomNumber+'@portosocorro.com',
			CompanyName = 'Test',
     		Title = 'Test',
     		Alias = 'Test',
     		TimeZoneSidKey = 'America/Los_Angeles',
     		EmailEncodingKey = 'UTF-8',
     		LanguageLocaleKey = 'en_US',
     		LocaleSidKey = 'en_US',
            ContactId = aContactId
            //,
     		//UserRoleId = lRole.Id
		);
        return lUser;
	}

    public static Contact createContact(){
        Account lAccount = (Account) new AccountFactory.Provider().createRecord();
    	Contact lCont = new Contact();
		lCont.FirstName = 'Test';
		lCont.LastName = 'Test';
		lCont.Accountid = lAccount.Id;

        return lCont;
    }
    
    public static User createUserFinancialManagement(){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Gestão financeira' LIMIT 1];
        
        Double randomNumber = Double.valueof((Math.random() * 11 + 8 + Math.random()));
        User lUser = new User(
     		ProfileId = profileId.Id,
     		LastName = 'Test',
     		Email = 'Test@portosocorro.com',
     		Username = 'Test'+randomNumber+'@portosocorro.com',
			CompanyName = 'Test',
     		Title = 'Test',
     		Alias = 'Test',
     		TimeZoneSidKey = 'America/Los_Angeles',
     		EmailEncodingKey = 'UTF-8',
     		LanguageLocaleKey = 'en_US',
     		LocaleSidKey = 'en_US'
		);
        return lUser;

    }
}