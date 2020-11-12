/**************************************************************************************************************
 * Globant Brasil
 * @author        	Jean Sganzerla (jean.francommes@globant.com)
 * Project:          Porto Socorro
 * Description:      Controlador do component wizard do cadastro do prestador
 *
 * Changes (Version)
 * -------------------------------------
 *           No.     Date            Author                  Description     
 *           -----   ----------      --------------------    ---------------   
 * @version   1.0    2020-02-06      Jean Sganzerla          class created 
 **************************************************************************************************************/
public with sharing class ProviderRegistrationWizard_ctr {
    
    private static final Id PARTNER = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.PartnerRecordType).getRecordTypeId();
    private static final Id PROVIDER = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProviderRecordType).getRecordTypeId();
    private static final Id BASE_EMPLOYEE = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.BaseEmployeesRecordType).getRecordTypeId();

    @AuraEnabled
    public static RegistrationDataSerasaPJWebService.AccountContactWrapper searchCnpj(String aCnpj){
        
        String lCnpj = aCnpj.replaceAll('[^0-9]','');
        
        List<Account> lAccountLst= [SELECT Id,Name,CompanyName__c,CardSituation__c,ProviderType__c,UpdateDate__c,StatusRadar__c,RadarReturnDate__c,RadarShippingDate__c,ReanalisysReason__c,
                                ContractType__c,GroupCompanies__c,ActuationType__c,HaveParking__c,Attend24h__c,Analyst__c,ScheduleType__c,ShippingStreet,ShippingPostalCode,
                                ShippingCity,ShippingState,ScheduleLink__c,ScheduleLink__r.Name,RecordTypeId,RisksStatus__c,Status__c,StepWizard__c,GreaterEqual90Days__c,ReturnDateRisks__c,
                                ReanalysisAvailable__c, PayTable__c, QuantityResources__c, QuantityService__c,DeliveryNeighborhood__c,OperationalNeighborhood__c,DeliveryComplement__c,
                                OperationalComplement__c,DeliveryNumber__c,OperationalNumber__c,DeliveryZip__c,OperationalZip__c,DeliveryCity__c,OperationalCity__c,DeliveryUf__c,
                                OperationalUfPickList__c,DeliveryStreet__c,OperationalStreet__c,BankName__c,Branch__c,CheckingAccount__c,CurrentAccountDigit__c,UseChart__c,OperationalPhone__c,
                                MunicipalRegistration__c,StateRegistration__c,FederalItem__c,PIS_NIT__c,OptingForSimple__c,PatrimonyLiquid__c,AnnualGrossRevenue__c,CNAEDescription__c,
                                CNAE__c, Email__c,Phone,Synced__c,DigitAgency__c,DeliveryPublicPlace__c,OperationalPublicPlace__c,PaymentMethod__c,RadarDescription__c,LegalSituation__c
                            FROM Account
                            WHERE CNPJ__c = :lCnpj AND RecordType.DeveloperName = :Label.ProviderRecordType AND LegalSituation__c = :Label.LegalPerson];              
                                           
        if(lAccountLst.isEmpty() || (lAccountLst[0].UpdateDate__c != null && lAccountLst[0].UpdateDate__c.monthsBetween(system.today()) > 3)){
            RegistrationDataSerasaPJWebService.AccountContactWrapper lProviderToInsert =  new RegistrationDataSerasaPJWebService().getRegistrationDataSerasaPJ(lCnpj);
            if(lProviderToInsert == null){
                system.debug('CNPJ não existe');
                return null;
            }
            
            try {
                lProviderToInsert.lAcc.RecordTypeId = PROVIDER;
                lProviderToInsert.lAcc.LegalSituation__c = Label.LegalPerson;
                upsert lProviderToInsert.lAcc CNPJ__c;
            }
            catch(DmlException e) {
                throw new AuraHandledException(e.getDmlMessage(0));
            }            

            //Relaciona todos os contatos com a conta e depois dá upsert para criar os registros de junção;
            for(Contact lContact :lProviderToInsert.lContactLst){
                lContact.AccountId = lProviderToInsert.lAcc.Id;
            }
            
            try{
                upsert lProviderToInsert.lContactLst CPF__c;
            }
            catch(DmlException e){
                throw new AuraHandledException(e.getDmlMessage(0));
            }    
            
            //Mapeia a porcentagem de cada sócio com o CPF dele para atualizar a junção com a informação de porcentagem de participação;
            Map<String,Decimal> lParticipationMap = new Map<String,Decimal>();
            system.debug('lProviderToInsert.lContactLst.size() ' + lProviderToInsert.lContactLst.size());
            for(Integer i = 0; i < lProviderToInsert.lContactLst.size(); i++){
                lParticipationMap.put(lProviderToInsert.lContactLst[i].CPF__c,lProviderToInsert.lParticipation[i]);
            }

            List<AccountContactRelation> lJunctionToUpsert = [SELECT Id, PercentageParticipation__c, Contact.CPF__c FROM AccountContactRelation WHERE AccountId = :lProviderToInsert.lAcc.Id];
            
            Map<Id,AccountContactRelation> lJunctionToUpsertMap = new Map<Id,AccountContactRelation>();
            for(AccountContactRelation lJunction :lJunctionToUpsert){
                lJunction.PercentageParticipation__c = lParticipationMap.get(lJunction.Contact.CPF__c);   
                //Transfere a lista para um Map, porque se será testado se alguma junção será removida, e se for, ela também tem que ser removida dessa lista (no caso os values do map) porque ocorrerá um update na base usando essa lista (values do map);
                lJunctionToUpsertMap.put(lJunction.ContactId,lJunction);               
            }

            //Verifica se existem mais sócios relacionados a essa Conta, na base do que o que a integração trouxe. Caso haja, significa que a empresa tinha outros sócios que hoje não tem mais. Sendo assim, o trecho abaixo deleta o relacionamento entre esses Contatos e essa Conta;
            if(lJunctionToUpsert.size() > lProviderToInsert.lContactLst.size()){

                List<Contact> lContactToChangeAccIdLst = new List<Contact>();
                Map<Id,AccountContactRelation> lJunctionToDeleteMap = new Map<Id,AccountContactRelation>();
                //Itera todas as junções que serão deletadas.
                for(AccountContactRelation lContact : [SELECT ContactId, Contact.AccountId FROM AccountContactRelation WHERE AccountId = :lProviderToInsert.lAcc.Id AND ContactId NOT IN :lProviderToInsert.lContactLst AND Contact.RecordTypeId = :PARTNER]){
                                       
                    //Lista de Contatos com os Sócios que terão o AccountId alterados, para poder deletar o registro de junção
                    Contact lContactToList = new Contact();
                    lContactToList.Id = lContact.ContactId;
                    lContactToList.AccountId = lContact.Contact.AccountId;

                    lContactToChangeAccIdLst.add(lContactToList);
                    lJunctionToDeleteMap.put(lContact.ContactId,lContact);
                }

                //Pega outra conta que o Contato tenha relacionamento, para trocar o campo AccountId, para que possa excluir a junção entre esse Contato e a Conta;
                Map<Id,Id> lNewAccIdMap = new Map<Id,Id>();
                for(AccountContactRelation lChangeAccountId :[SELECT ContactId, AccountId FROM AccountContactRelation WHERE AccountId != :lProviderToInsert.lAcc.Id AND ContactId IN :lContactToChangeAccIdLst]){
                    lNewAccIdMap.put(lChangeAccountId.ContactId,lChangeAccountId.AccountId);
                }

                //Itera todos os contatos que perderão o relacionamento para atualizar o campo AccountId;
                for(Contact lContact : lContactToChangeAccIdLst){
                    if(lContact.AccountId == lProviderToInsert.lAcc.Id){
                        if(lNewAccIdMap.containsKey(lContact.Id)){
                            lContact.AccountId = lNewAccIdMap.get(lContact.Id);                           
                        }
                        else{
                            lContact.AccountId = null;
                            lJunctionToDeleteMap.remove(lContact.Id);
                        }
                    }
                    lJunctionToUpsertMap.remove(lContact.Id);
                }
                update lContactToChangeAccIdLst;
                delete lJunctionToDeleteMap.values();
            }
            
            
            try{
                upsert lJunctionToUpsertMap.values();
            }
            catch(DmlException e){
                throw new AuraHandledException(e.getDmlMessage(0));
            }   
            system.debug(lProviderToInsert);

            /*Necessário refazer a Query pois quando a Conta existe na Base mas a data de atualização é maior que 3 meses, não podemos retornar somente o lProviderToInsert, já que ele não tem os demais 
            campos que preenchem as outras telas. Então as demais telas estarão com valor preenchido pelo RecordEditForm, mas o attribute do component estará vazio, exibindo o erro para preencher os campos
            já preenchidos.*/
            List<Account> lAccountLstUpdated= [SELECT Id,Name,CompanyName__c,CardSituation__c,ProviderType__c,UpdateDate__c,StatusRadar__c,RadarReturnDate__c,RadarShippingDate__c,ReanalisysReason__c,
                                ContractType__c,GroupCompanies__c,ActuationType__c,HaveParking__c,Attend24h__c,Analyst__c,ScheduleType__c,ShippingStreet,ShippingPostalCode,
                                ShippingCity,ShippingState,ScheduleLink__c,ScheduleLink__r.Name,RecordTypeId,RisksStatus__c,Status__c,StepWizard__c,GreaterEqual90Days__c,ReturnDateRisks__c,
                                ReanalysisAvailable__c, PayTable__c, QuantityResources__c, QuantityService__c,DeliveryNeighborhood__c,OperationalNeighborhood__c,DeliveryComplement__c,
                                OperationalComplement__c,DeliveryNumber__c,OperationalNumber__c,DeliveryZip__c,OperationalZip__c,DeliveryCity__c,OperationalCity__c,DeliveryUf__c,
                                OperationalUfPickList__c,DeliveryStreet__c,OperationalStreet__c,BankName__c,Branch__c,CheckingAccount__c,CurrentAccountDigit__c,UseChart__c,OperationalPhone__c,
                                MunicipalRegistration__c,StateRegistration__c,FederalItem__c,PIS_NIT__c,OptingForSimple__c,PatrimonyLiquid__c,AnnualGrossRevenue__c,CNAEDescription__c,
                                CNAE__c, Email__c,Phone,Synced__c,DigitAgency__c,DeliveryPublicPlace__c,OperationalPublicPlace__c,PaymentMethod__c,RadarDescription__c,LegalSituation__c
                            FROM Account
                            WHERE CNPJ__c = :lCnpj AND RecordType.DeveloperName = :Label.ProviderRecordType];
            lProviderToInsert.lAcc = lAccountLstUpdated[0];
            return lProviderToInsert;
        }
        else{
            Set<Id> lRelationSet = new Set<Id>();
            RegistrationDataSerasaPJWebService.AccountContactWrapper lAccountContact = new RegistrationDataSerasaPJWebService.AccountContactWrapper();
            lAccountContact.lAcc = lAccountLst[0];

            for(AccountContactRelation lRelation :[SELECT ContactId FROM AccountContactRelation WHERE AccountId = :lAccountContact.lAcc.Id]){
                lRelationSet.add(lRelation.ContactId);
            }
            lAccountContact.lContactLst = [SELECT Id, FirstName, LastName, CPF__c, PEP__c, Email FROM Contact WHERE Id IN :lRelationSet];                
            return lAccountContact;
        }
    }

    @AuraEnabled
    public static List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> getPicklistValues(){       

        List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> lPickListValuesLst= new List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper>();
		Schema.DescribeFieldResult lFieldResult = Account.ProviderType__c.getDescribe();
        List<Schema.PicklistEntry> lPicklistEntry = lFieldResult.getPicklistValues();
		for( Schema.PicklistEntry lPickListVal : lPicklistEntry){            
			lPickListValuesLst.add(
                new GenericWrapperClass_cls.PopulateSelectOptionsWrapper(
                    lPickListVal.getLabel(),
                    lPickListVal.getValue()
                )
            );
		}     
        system.debug('pickListValuesList ' + lPickListValuesLst);
		return lPickListValuesLst;
    }

    @AuraEnabled
    public static List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> getBankValues(){       

        List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper> lPickListValuesLst= new List<GenericWrapperClass_cls.PopulateSelectOptionsWrapper>();
		Schema.DescribeFieldResult lFieldResult = Account.BankName__c.getDescribe();
		List<Schema.PicklistEntry> lPicklistEntry = lFieldResult.getPicklistValues();
		for( Schema.PicklistEntry lPickListVal : lPicklistEntry){            
			lPickListValuesLst.add(
                new GenericWrapperClass_cls.PopulateSelectOptionsWrapper(
                    lPickListVal.getLabel(),
                    lPickListVal.getValue()
                )
            );
		}     
        system.debug('pickListValuesList ' + lPickListValuesLst);
		return lPickListValuesLst;
    }

    @AuraEnabled
    public static void updateAccount(String aProviderJson){
        Account lAccount = (Account)System.JSON.deserializeStrict(aProviderJson, Account.Class);
        if(lAccount.OperationalZip__c != null){
            lAccount.OperationalZip__c = lAccount.OperationalZip__c.replaceAll('[^0-9]','');
        }
        if(lAccount.DeliveryZip__c != null){
            lAccount.DeliveryZip__c = lAccount.DeliveryZip__c.replaceAll('[^0-9]','');
        }
        if(lAccount.TaxZip__c != null){
            lAccount.TaxZip__c = lAccount.TaxZip__c.replaceAll('[^0-9]','');
        }
        if(lAccount.OperationalPhone__c != null && !lAccount.OperationalPhone__c.isNumeric()){
            lAccount.OperationalPhone__c =lAccount.OperationalPhone__c.replaceAll('[^0-9]','');
        }
        if(lAccount.Phone != null && !lAccount.Phone.isNumeric()){
            lAccount.Phone =lAccount.Phone.replaceAll('[^0-9]','');
        }

        System.debug('aProviderJson ' + aProviderJson);
        System.debug('lAccount ' + lAccount);

        try {
            update lAccount;
        }
        catch(DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }            

        
    }

    @AuraEnabled
    public static void submitApprovalRequest(String aAccountId, String aCommentaries, String aProviderJson) {
        
        updateAccount(aProviderJson);
        Id llUserId = UserInfo.getUserId();           
        // Create an approval request for the account
        Approval.ProcessSubmitRequest lRequest =  new Approval.ProcessSubmitRequest();
        lRequest.setComments(aCommentaries);
        lRequest.setObjectId(Id.valueOf(aAccountId));
        
        // Submit on behalf of a specific submitter
        lRequest.setSubmitterId(llUserId); 
        
        // Submit the record to specific process and skip the criteria evaluation
        lRequest.setProcessDefinitionNameOrId(Label.ProcessRiskApproval);
        lRequest.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(lRequest);
    }

    @AuraEnabled
    public static void savePartners(String aPartners){
        system.debug('aPartners ' + aPartners); 

        List<Contact> lPartnersLst = (List<Contact>)System.JSON.deserializeStrict(aPartners, List<Contact>.Class);
        for(Contact lContact :lPartnersLst){
            lContact.Phone = lContact.Phone != null? lContact.Phone.replaceAll('[^0-9]','') : null;
            lContact.MobilePhone = lContact.MobilePhone != null ? lContact.Phone.replaceAll('[^0-9]','') : null;
        }
        system.debug(lPartnersLst);
        upsert lPartnersLst CPF__c;
    }

    @AuraEnabled
    public static void getPartnerRestrictiveAndRegistrationInfo(String aProviderId){
        
        Set<Id> lPartnersIdSet = new Set<Id>();
        for(AccountContactRelation lJunction :[SELECT ContactId, Contact.Status__c, Contact.CPF__c FROM AccountContactRelation WHERE AccountId = :aProviderId]){
            lPartnersIdSet.add(lJunction.ContactId);
        }
        List<Contact> lContactLst = [SELECT Id, Status__c, CPF__c FROM Contact WHERE CPF__c IN :lPartnersIdSet];
        
        if(!lContactLst.isEmpty()) {
            System.enqueueJob(new IntegrationHandler_cls(lContactLst));
        }
    }
    @AuraEnabled
    public static RegistrationWzdWrapper searchEmployeeByCPF(String aCPF){
        String lCPF = aCPF.replaceAll('[^0-9]','');

        Contact lRescuer = getContact(lCPF);
        Account lAccount = getAccount(lCPF);
        if(lRescuer == null || lRescuer.UpdateDate__c == null || lRescuer.UpdateDate__c.monthsBetween(system.today()) > 3 || (lAccount == null && lAccount.UpdateDate__c != null && lAccount.UpdateDate__c.monthsBetween(system.today()) > 3)){
            Contact lRescuerToUpsert = new RegistrationDataSerasaPFWebService().getRegistrationDataSerasaPF(lCPF); 
            system.debug('lRescuerToUpsert ' + lRescuerToUpsert);
            if(lRescuerToUpsert == null) {
                return null;//new RegistrationWzdWrapper(lRescuer);//
            }

            Account lAccountToUpsert = new Account();
            if(!String.isBlank(lRescuerToUpsert.FirstName)){
                    lAccountToUpsert.Name = lRescuerToUpsert.FirstName+' '+lRescuerToUpsert.LastName;
                }
                else {
                    lAccountToUpsert.Name = lRescuerToUpsert.LastName;
                }
             
            lAccountToUpsert.OperationalPublicPlace__c = lRescuerToUpsert.PublicPlace__c;
            lAccountToUpsert.OperationalZip__c = lRescuerToUpsert.PublicPlace__c;
            lAccountToUpsert.OperationalUfPickList__c = lRescuerToUpsert.Uf__c;
            lAccountToUpsert.OperationalStreet__c = lRescuerToUpsert.Street__c;
            lAccountToUpsert.OperationalNumber__c = lRescuerToUpsert.Number__c;
            lAccountToUpsert.OperationalComplement__c = lRescuerToUpsert.Complement__c;
            lAccountToUpsert.OperationalCity__c = lRescuerToUpsert.City__c;
            lAccountToUpsert.CNPJ__c = lRescuerToUpsert.CPF__c;
            lAccountToUpsert.CardSituation__c = lRescuerToUpsert.CPFStatus__c;
            lAccountToUpsert.UpdateDate__c = lRescuerToUpsert.UpdateDate__c;
            lAccountToUpsert.LegalSituation__c = Label.PhysicalPerson;
            lAccountToUpsert.RecordTypeId = PROVIDER;

            try {
                lRescuerToUpsert.Role__c = Label.OperationalManager;
                lRescuerToUpsert.StepWizard__c = 3;
                lRescuerToUpsert.RecordTypeId = BASE_EMPLOYEE;
                upsert lRescuerToUpsert CPF__c;
                
                lAccountToUpsert.BaseEmployeePF__c = lRescuerToUpsert.Id;
                upsert lAccountToUpsert CNPJ__c;
                
                lRescuerToUpsert.AccountId = lAccountToUpsert.Id;
                upsert lRescuerToUpsert CPF__c;
                return new RegistrationWzdWrapper(getContact(lCPF), getAccount(lCPF));
            }
            catch(DmlException e) {
                throw new AuraHandledException(e.getDmlMessage(0));
            }            
        }
        return new RegistrationWzdWrapper(lRescuer, lAccount);               
    }
    private static Contact getContact(String aCPF) {
        List<Contact> lRescuerLst = [SELECT Id, Name, UpdateDate__c, AccountId,
                Nationality__c, LastName, CPFStatus__c, FatherName__c,
                MotherName__c, RG__c, IssuingAgency__c, Birthdate,
                FirstName, CPF__c, Role__c, StepWizard__c, StatusRadar__c,
                RadarShippingDate__c,RadarReturnDate__c, RisksStatus__c, ReturnDateRisks__c,
                ReanalisysReason__c, ContractType__c, MobilePhone, Phone, 
                City__c, Uf__c, Zip__c, Complement__c, Number__c, Street__c, Neighborhood__c,
                Height__c, Weight__c, Shirt__c, Pants__c, Boot__c, Jacket__c, Knitted__c, 
                QRA__c, DegreeKinshipPortoEmployee__c, PEP__c, WorkRegisterBookletNumber__c, 
                WorkRegisterBookletSeries__c, PISNumber__c, HealthInsurance__c, Dental__c, 
                LifeInsurance__c, StartTerm__c, StipulantNumber__c, CNHNumber__c, CNHCategory__c, 
                CNHExpirationDate__c, DateOfFirstCNH__c, MaritalStatus__c, EducationLevel__c, Gender__c,
                Status__c, GreaterEqual90Days__c, ReanalysisAvailable__c 
                FROM Contact
                WHERE CPF__c = :aCPF];
        return lRescuerLst.isEmpty()?null:lRescuerLst[0];              
    }
    private static Account getAccount(String aCPF) {
        List<Account> lAccountLst= [SELECT Id,Name,CompanyName__c,CardSituation__c,ProviderType__c,UpdateDate__c,StatusRadar__c,RadarReturnDate__c,RadarShippingDate__c,ReanalisysReason__c,
                                ContractType__c,GroupCompanies__c,ActuationType__c,HaveParking__c,Attend24h__c,Analyst__c,ScheduleType__c,ShippingStreet,ShippingPostalCode,
                                ShippingCity,ShippingState,ScheduleLink__c,ScheduleLink__r.Name,RecordTypeId,RisksStatus__c,Status__c,StepWizard__c,GreaterEqual90Days__c,ReturnDateRisks__c,
                                ReanalysisAvailable__c, PayTable__c, QuantityResources__c, QuantityService__c,DeliveryNeighborhood__c,OperationalNeighborhood__c,DeliveryComplement__c,
                                OperationalComplement__c,DeliveryNumber__c,OperationalNumber__c,DeliveryZip__c,OperationalZip__c,DeliveryCity__c,OperationalCity__c,DeliveryUf__c,
                                OperationalUfPickList__c,DeliveryStreet__c,OperationalStreet__c,BankName__c,Branch__c,CheckingAccount__c,CurrentAccountDigit__c,UseChart__c,OperationalPhone__c,
                                MunicipalRegistration__c,StateRegistration__c,FederalItem__c,PIS_NIT__c,OptingForSimple__c,PatrimonyLiquid__c,AnnualGrossRevenue__c,CNAEDescription__c,
                                CNAE__c, Email__c,Phone,Synced__c,DigitAgency__c,DeliveryPublicPlace__c,OperationalPublicPlace__c,PaymentMethod__c,RadarDescription__c,LegalSituation__c,BankAccountType__c,
                                TaxNeighbourhood__c,TaxZIP__c,TaxCity__c,TaxComplement__c,TaxStreet__c,TaxNumber__c,TaxPublicPlace__c,TaxUf__c
                            FROM Account
                            WHERE CNPJ__c = :aCPF AND RecordType.DeveloperName = :Label.ProviderRecordType AND LegalSituation__c = :Label.PhysicalPerson]; //Colocar recordtype ProviderPF
        return lAccountLst.isEmpty()?null:lAccountLst[0];              
    }

    public class RegistrationWzdWrapper {
        @AuraEnabled public Boolean isSalesforcePlatformUser {get{return UserInfo.getUserType() == Label.String_Standard;}set;}
        @AuraEnabled public Account account {get;set;}
        @AuraEnabled public Contact contact {get;set;}
        public RegistrationWzdWrapper(Contact aContact, Account aAccount) {
            this.contact = aContact;
            this.account = aAccount;
        }
    }
}