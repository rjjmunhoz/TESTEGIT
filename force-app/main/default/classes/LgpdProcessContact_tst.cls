@isTest
public class LgpdProcessContact_tst {
	
    @isTest
    static void deleteBaseEmployeeWithoutDependent (){
        // Valida a exclusão do contato sem dependentes
        makeData('1','teste1');
        
        Test.startTest();            
            LgpdProcessContact_sch_bch lBatch = new LgpdProcessContact_sch_bch();
            Database.executeBatch(lBatch);
        Test.stopTest();
        
        List<Contact> lContactList = [SELECT Id, CPF__c FROM Contact];
        system.debug('teste Lista de Contatos, deve estar vazio: ' + lContactList);
        System.assert(lContactList.isEmpty(),true);
        
        deleteData();
    }
    
    @isTest
    static void deleteBaseEmployeeWithDependent (){
        // Valida a exclusão do contato com dependentes
        makeData('12','teste2');
        system.debug('teste AccountId ' + [SELECT AccountId FROM Contact]);
        
        Test.startTest();            
            LgpdProcessContact_sch_bch lBatch = new LgpdProcessContact_sch_bch();
            Database.executeBatch(lBatch);
        Test.stopTest();
        
        List<Contact> lContactList = [SELECT Id, CPF__c, AccountId FROM Contact];
        system.debug('teste Lista de Contatos, deve estar vazio: ' + lContactList);
        System.assert(lContactList.isEmpty(),true);
        
        List<Dependent__c> lDependentList = [SELECT Id, CPF__c FROM Dependent__c];
        system.debug('teste Lista de Dependentes, deve estar vazio: ' + lDependentList);
        System.assert(lDependentList.isEmpty(),true);
        
        deleteData();
    }
    
    @isTest
    static void deleteBaseEmployeeWithCase (){
        // Valida a exclusão do contato com caso
        Test.startTest();
        	makeData('16','teste3');      
            LgpdProcessContact_sch_bch lBatch = new LgpdProcessContact_sch_bch();
            Database.executeBatch(lBatch);
        Test.stopTest();
        
        List<Contact> lContactList = [SELECT Id, CPF__c FROM Contact];
        system.debug('teste Lista de Contatos, deve estar vazio: ' + lContactList);
        System.assert(lContactList.isEmpty(),true);
        
        deleteData();
    }
    
    @isTest
    static void anonymizationUser (){
        // Valida a anonimização do Contato que possui Usuário da comunidade
        String aCode = 'teste4';
        
        makeData('15',aCode);
        
        User lUser = [SELECT id, Contact.LastName FROM User WHERE Contact.LastName LIKE :aCode LIMIT 1];

        if (System.IsBatch () == false && System.isFuture () == false) { 
        	Test.startTest();            
            	LgpdProcessContact_sch_bch lBatch = new LgpdProcessContact_sch_bch();
            	Database.executeBatch(lBatch);
        	Test.stopTest();
		}
        
        Map < String, List < LgpdFields >> lObjectFieldsMap = new Map < String, List < LgpdFields >> ();
        for (LgpdFields__mdt lLgpdFields: [SELECT Id, FieldName__c, Object__c, FieldValue__c FROM LgpdFields__mdt]) {
        	List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get(lLgpdFields.Object__c);
        	if (lLgpdFieldsLst == null) {
        		lLgpdFieldsLst = new List < LgpdFields > ();
        		lObjectFieldsMap.put(lLgpdFields.Object__c, lLgpdFieldsLst);
        	}
        	lLgpdFieldsLst.add(new LgpdFields(lLgpdFields.FieldName__c, lLgpdFields.FieldValue__c));
        }
        List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get('User');        

        String lQueryFields;
        for(LgpdFields lField :lLgpdFieldsLst) {
            if(String.isBlank(lQueryFields)) {
                lQueryFields = lField.fieldName;
            }
            else {
                lQueryFields += ', ' + lField.fieldName;
            }
        }
        
        String lIdUser = lUser.Id;
        User lUserLgpd = Database.query('SELECT Id,' + lQueryFields + ', Username FROM User WHERE id =:lIdUser LIMIT 1');
        System.debug('teste username: ' + lUserLgpd);
        System.assert(lUserLgpd.Username.Contains('@esquecimentolgpd.com'), true);
        
        for (LgpdFields lField: lLgpdFieldsLst) {
            system.debug('teste :' + lField.fieldName);
            
            if(((Object)lUserLgpd.get(lField.fieldName)) == false){
                System.assert( 'false' == ((Object)lField.fieldValue), 'Diferença ao comparar o campo\"' + 'false' + '\" != \"' +lField.fieldValue + '\")');
            }
            else{
                System.assert( ((Object)lUserLgpd.get(lField.fieldName)) == ((Object)lField.fieldValue), 'Diferença ao comparar o campo\"' + lUserLgpd.get(lField.fieldName) + '\" != \"' +lField.fieldValue + '\")');
            }
        }
        
    }
    
    @isTest
    static void anonymizationContactUser (){
        // Valida a anonimização do Contato que possui Usuário da comunidade
        makeData('15','teste5');
        if (System.IsBatch () == false && System.isFuture () == false) { 
        	Test.startTest();            
            	LgpdProcessContact_sch_bch lBatch = new LgpdProcessContact_sch_bch();
            	Database.executeBatch(lBatch);
        	Test.stopTest();
		}

        Map < String, List < LgpdFields >> lObjectFieldsMap = new Map < String, List < LgpdFields >> ();
        for (LgpdFields__mdt lLgpdFields: [SELECT Id, FieldName__c, Object__c, FieldValue__c FROM LgpdFields__mdt]) {
        	List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get(lLgpdFields.Object__c);
        	if (lLgpdFieldsLst == null) {
        		lLgpdFieldsLst = new List < LgpdFields > ();
        		lObjectFieldsMap.put(lLgpdFields.Object__c, lLgpdFieldsLst);
        	}
        	lLgpdFieldsLst.add(new LgpdFields(lLgpdFields.FieldName__c, lLgpdFields.FieldValue__c));
        }
        List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get('Contact');        

        String lQueryFields;
        for(LgpdFields lField :lLgpdFieldsLst) {
            if(String.isBlank(lQueryFields)) {
                lQueryFields = lField.fieldName;
            }
            else {
                lQueryFields += ', ' + lField.fieldName;
            }
        }
        system.debug('SELECT ' + lQueryFields + ' FROM Contact LIMIT 1');

        Contact lContact = Database.query('SELECT ' + lQueryFields + ' FROM Contact LIMIT 1');
        
        system.debug('teste valores lContact ' + lContact);
        

        for (LgpdFields lField: lLgpdFieldsLst) {
            system.debug('teste :' + lField.fieldName);
            
            if(((Object)lContact.get(lField.fieldName)) == false){
                System.assert( 'false' == ((Object)lField.fieldValue), 'Diferença ao comparar o campo\"' + 'false' + '\" != \"' +lField.fieldValue + '\")');
            }
            else{
                System.assert( ((Object)lContact.get(lField.fieldName)) == ((Object)lField.fieldValue), 'Diferença ao comparar o campo\"' + lContact.get(lField.fieldName) + '\" != \"' +lField.fieldValue + '\")');
            }
        }
    }
    
    @isTest
    static void anonymizationRelation (){
        // Valida a anonimização do relacionamento entre Conta e Contato
        makeData('15','teste6');
        if (System.IsBatch () == false && System.isFuture () == false) { 
        	Test.startTest();            
            	LgpdProcessContact_sch_bch lBatch = new LgpdProcessContact_sch_bch();
            	Database.executeBatch(lBatch);
        	Test.stopTest();
		}

        Map < String, List < LgpdFields >> lObjectFieldsMap = new Map < String, List < LgpdFields >> ();
        for (LgpdFields__mdt lLgpdFields: [SELECT Id, FieldName__c, Object__c, FieldValue__c FROM LgpdFields__mdt]) {
        	List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get(lLgpdFields.Object__c);
        	if (lLgpdFieldsLst == null) {
        		lLgpdFieldsLst = new List < LgpdFields > ();
        		lObjectFieldsMap.put(lLgpdFields.Object__c, lLgpdFieldsLst);
        	}
        	lLgpdFieldsLst.add(new LgpdFields(lLgpdFields.FieldName__c, lLgpdFields.FieldValue__c));
        }
        List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get('AccountContactRelation');        

        String lQueryFields;
        for(LgpdFields lField :lLgpdFieldsLst) {
            if(String.isBlank(lQueryFields)) {
                lQueryFields = lField.fieldName;
            }
            else {
                lQueryFields += ', ' + lField.fieldName;
            }
        }
        AccountContactRelation lRelation = Database.query('SELECT ' + lQueryFields + ' FROM AccountContactRelation LIMIT 1');
        for (LgpdFields lField: lLgpdFieldsLst) {
            system.debug('teste :' + lField.fieldName);
            
            if(((Object)lRelation.get(lField.fieldName)) == false){
                System.assert( 'false' == ((Object)lField.fieldValue), 'Diferença ao comparar o campo\"' + 'false' + '\" != \"' +lField.fieldValue + '\")');
            }
            else if(((Object)lRelation.get(lField.fieldName)) == 0.00){
                System.assert( '0.00' == ((Object)lField.fieldValue), 'Diferença ao comparar o campo\"' + 'false' + '\" != \"' +lField.fieldValue + '\")');
            }
            else{
                System.assert( ((Object)lRelation.get(lField.fieldName)) == ((Object)lField.fieldValue), 'Diferença ao comparar o campo\"' + lRelation.get(lField.fieldName) + '\" != \"' +lField.fieldValue + '\")');
            }
        }
    }
    /*
    @isTest
    static void lgpdError (){
        // cenário de erro
        // NÃO ESTÁ GERANDO ERRO
        
        try{
            makeData('123456','teste7');
            
            Test.startTest();            
            	LgpdProcessContact_sch_bch lBatch = new LgpdProcessContact_sch_bch();
            	Database.executeBatch(lBatch);
        	Test.stopTest();
        }
        catch(DmlException e){
            system.debug('Msg Erro: ' + e);
        }
        
    }
    */
    
    // Colocar aqui metodo para validar a exclusão do contato com dependentes quando dependente é um colaborador
    //aKey = 134
    
    /*
    @isTest
    static void notDeleteDependentWithActiveEmployee (){
        // Valida se excluí dependentes quando existe um colaborador ativo vinculado a ele.
        makeData('12');
        
        Dependent__c lDependent = [SELECT Id, CPF__c FROM Dependent__c LIMIT 1];
        
        Test.startTest();            
            //LgpdProcessContact_sch_bch lBatch = new LgpdProcessContact_sch_bch(new Set<Id>{lDependent.Id});
            //Database.executeBatch(lBatch);
        Test.stopTest();
        
        List<Dependent__c> lDependentList = [SELECT Id, CPF__c FROM Dependent__c];
        System.assert(lDependentList.isEmpty(),false);
        
        deleteData();
    }
    */
    
    static void makeData(String aKey, string aCode) {        

        User lUserOwnerAccount = UserFactory.createUserAnalist();
        insert lUserOwnerAccount;
        User lUserRecruiter = UserFactory.createUserRecruiter();
        insert lUserRecruiter;

        system.runAs(lUserOwnerAccount) {
            Account lAccount1 = AccountFactory.createAccountProvider();
            lAccount1.Description__c = aCode; 
            lAccount1.OwnerId = lUserOwnerAccount.Id;
            Insert lAccount1;
        }
        
        system.runAs(lUserRecruiter){
            if(aKey.contains('1')){
                Account lAccount = [SELECT Id FROM Account LIMIT 1];
                Contact lContact1 = ContactFactory.createContactBaseEmployee(lAccount.Id);
                lContact1.LastName =+ aCode;
                lContact1.RG__c = '943761258';
                lContact1.CPF__c = '76194385200';
                lContact1.PHONE= '1149996532';
                lContact1.Zip__c = '05544656';
                lContact1.Email = 'teste@testeporto.com';
                insert lContact1;
                lContact1.Status__c = 'Ativo';
                lContact1.LgpdStatus__c = 'P';
                //lContact1.Role__c = 'Socorrista';
                lContact1.Role__c = 'Administrativo';
                update lContact1;
            }
            
            if(aKey.contains('2')){
                Contact lContact2 = [SELECT Id FROM Contact LIMIT 1];
                Dependent__c lDependent2 = DependentFactory.createDependent(lContact2.Id);
                lDependent2.Name = aCode;
                insert lDependent2;
            }
            
            if(aKey.contains('3')){
                Contact lContact3 = [SELECT Id FROM Contact LIMIT 1];
                Dependent__c lDependent3 = DependentFactory.createDependent(lContact3.Id);
                lDependent3.Name = aCode;
                lDependent3.CPF__c = '56234596512';
                insert lDependent3;
            }
            
            if(aKey.contains('4')){
                Id BaseEmployeesRectypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('BaseEmployees').getRecordTypeId();
                Contact lContactDependent4 = new Contact(
                    RecordTypeId = BaseEmployeesRectypeId,
                    FirstName = 'Colaborador',
                    LastName = 'Dependente' + aCode,
                    CPF__c = '56234596512',
                    City__c = 'Rio de Janeiro'
                );
                insert lContactDependent4;
            }
        }
        if(aKey.contains('5')){
                
            Contact lContact5 = [SELECT Id FROM Contact LIMIT 1];
            User lUser = UserFactory.createUserProviderCommunity(lContact5.Id);
            luser.Username = aCode + luser.Username;
            lUser.IsActive = true;
            lUser.Phone = '44448888';
            insert lUser;
            system.debug('teste User id' + lUser); 
        }
        	
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        	if(aKey.contains('6')){
            	Contact lContact6 = [SELECT Id FROM Contact LIMIT 1];
            
            	Case lCase = CaseFactory.createCasePrototyping();
            	lCase.ContactId = lContact6.Id;
            	insert lCase;
            }  
        }
    }
    
    static void deleteData(){
        
        User lUser = [SELECT Id, Email, ContactId FROM User WHERE Email = 'Test@portosocorro.com' LIMIT 1];
        lUser.IsActive = false;
        lUser.ContactId = null;
        update lUser;
        
        List<Contact> lContactListDel = [SELECT Id FROM Contact];
        if(!lContactListDel.isEmpty()) delete lContactListDel;
        
        List<Dependent__c> lDependentListDel = [SELECT Id FROM Dependent__c];
        if(!lDependentListDel.isEmpty()) delete lDependentListDel;        
    }

    public class LgpdFields {
        String fieldName;
        String fieldValue;
        public LgpdFields(String aFieldName, String aFieldValue) {
            this.fieldName = aFieldName;
            this.fieldValue = aFieldValue;
        }
    }
    
    static String QueryFields(String lObject){
        Map < String, List < LgpdFields >> lObjectFieldsMap = new Map < String, List < LgpdFields >> ();
        for (LgpdFields__mdt lLgpdFields: [SELECT Id, FieldName__c, Object__c, FieldValue__c FROM LgpdFields__mdt]) {
        	List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get(lLgpdFields.Object__c);
        	if (lLgpdFieldsLst == null) {
        		lLgpdFieldsLst = new List < LgpdFields > ();
        		lObjectFieldsMap.put(lLgpdFields.Object__c, lLgpdFieldsLst);
        	}
        	lLgpdFieldsLst.add(new LgpdFields(lLgpdFields.FieldName__c, lLgpdFields.FieldValue__c));
        }
        List < LgpdFields > lLgpdFieldsLst = lObjectFieldsMap.get(lObject);        

        String lQueryFields;
        for(LgpdFields lField :lLgpdFieldsLst) {
            if(String.isBlank(lQueryFields)) {
                lQueryFields = lField.fieldName;
            }
            else {
                lQueryFields += ', ' + lField.fieldName;
            }
        }
        return lQueryFields;
    }
}