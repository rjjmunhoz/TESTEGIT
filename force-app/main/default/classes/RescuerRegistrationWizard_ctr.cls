/**************************************************************************************************************
 * Globant Brasil
 * @author        	 Eduardo Costa (eduardo.borges@globant.com)
 * Project:          Porto Socorro
 * Description:      Controlador do component wizard do cadastro do socorrista
 *
 * Changes (Version)
 * -------------------------------------
 *           No.     Date            Author                  Description     
 *           -----   ----------      --------------------    ---------------   
 * @version   1.0    2020-02-21      Eduardo Costa           class created 
 **************************************************************************************************************/
public with sharing class RescuerRegistrationWizard_ctr {

    private static final String WAITING_RESCUER_RISKS = Label.Status_WaitingRescuerRisks;
    private static final String WAITING_RADAR = Label.Status_WaitingRadar;
    private static final String PROVIDER_TYPE_DEFAULT = Label.ProviderTypeDefault;    
    private static final String ROLE_ADMINISTRATIVO = Label.RoleAdministrative;    
    private static final String ROLE_GESTOR = Label.RoleGestor;   
    private static final String STATUS_IN_DEPLOYMENT = Label.Status_Deployment; 
    private static final String STATUS_ACTIVE = Label.Status_Active; 
    
   
    @AuraEnabled
    public static RegistrationWzdWrapper searchEmployeeByCPF(String aCPF){
        String lCPF = aCPF.replaceAll('[^0-9]','');

        Contact lRescuer = getContact(lCPF);
        if(lRescuer == null || lRescuer.UpdateDate__c == null || lRescuer.UpdateDate__c.monthsBetween(system.today()) > 3){
            Contact lRescuerToUpsert = new RegistrationDataSerasaPFWebService().getRegistrationDataSerasaPF(lCPF);  
            if(lRescuerToUpsert == null) {
                return null;//new RegistrationWzdWrapper(lRescuer);//
            }
            try {                
                upsert lRescuerToUpsert CPF__c;
                return new RegistrationWzdWrapper(getContact(lCPF));
            }
            catch(DmlException e) {
                throw new AuraHandledException(e.getDmlMessage(0));
            }            
        }
        return new RegistrationWzdWrapper(lRescuer);               
    } 

    @AuraEnabled
    public static void saveContact(String aContact) {                                           
        try {
            Contact lContact = (Contact)JSON.deserialize(aContact, Contact.Class);
            if(lContact.StepWizard__c == 3) {
                if(lContact.Role__c == ROLE_ADMINISTRATIVO) {
                    lContact.Status__c = STATUS_ACTIVE;
                }
                else {
                    //system.debug('name ' + lContact.FirstName);
                    lContact.Status__c = STATUS_IN_DEPLOYMENT;
                    lContact.StatusRadar__c = WAITING_RADAR;
                    lContact.RisksStatus__c = null;
                    //System.debug('Teste pesado lContact.ProviderType__c' + lContact.ProviderType__c);
                    //System.debug('Teste pesado lContact.Role__c' + lContact.Role__c);
                    if(lContact.ProviderType__c == PROVIDER_TYPE_DEFAULT && lContact.Role__c != ROLE_GESTOR) {
                        //System.debug('Teste Entrou');
                        // Já busca o seguro de vida do socorrista vinculado ao um prestador padrão

                        //é pego o id da regra de atribuição de caso para se a integração quebrar, será criado um registro de caso e definido a regra de atribuição a ele. 
                        //(Regra de atribuição não roda sozinha quando o registro é criado via APEX) 
                        //https://help.salesforce.com/articleView?id=000338182&type=1&mode=1
                        List<AssignmentRule>  lAssigmentRuleIdLst = [SELECT Id FROM AssignmentRule WHERE SobjectType = :Label.SObjectNameCase and Active = true];
                        List<ContactLifeInsuranceWebService.ContactLifeInsurance> lContactLifeInsuranceLst = new ContactLifeInsuranceWebService().getContactLifeInsurance(lContact.CPF__c,lAssigmentRuleIdLst[0].Id);    
                        System.debug('Teste lContactLifeInsuranceLst' + lContactLifeInsuranceLst);
                        if(lContactLifeInsuranceLst != null && !lContactLifeInsuranceLst.isEmpty()) {
                            // Orderna pelos planos ativos mais recentes
                            lContactLifeInsuranceLst.sort();
                            if(String.isNotBlank(lContactLifeInsuranceLst[0].DataInicioVigenciaSegurado)) {
                                lContact.StartTerm__c = Date.valueOf(lContactLifeInsuranceLst[0].DataInicioVigenciaSegurado.split('T')[0]);
                            }
                            else {
                                lContact.StartTerm__c = null;
                            }   
                            lContact.LifeInsurance__c = lContactLifeInsuranceLst[0].StatusSegurado;
                            lContact.StipulantNumber__c = lContactLifeInsuranceLst[0].NumeroEstipulante;
                        }  
                    }
                                      
                }
            }
            upsert lContact CPF__c;
        }
        catch(DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }  
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }         
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

    public class RegistrationWzdWrapper {
        @AuraEnabled public Boolean isSalesforcePlatformUser {get{return UserInfo.getUserType() == Label.String_Standard;}set;}
        @AuraEnabled public Contact contact {get;set;}
        public RegistrationWzdWrapper(Contact aContact) {
            this.contact = aContact;
        }
    }
}