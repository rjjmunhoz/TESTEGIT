/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger do Serviço/Especialidade/Detalhe
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version  1.0     2019-11-13      Matheus Branco          class created 
            1.1     2020-03-31      Jean Sganzerla          created generateExternalId and validateExternalId methods
            1.2     2020-07-21      Matheus Branco          remove method duplicateControl
**************************************************************************************************************/
public class Product2Handler {

    private static final String SERVICE_RECTYPE = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.ServiceRecordType).getRecordTypeId();
    private static final String SPECIALTY_RECTYPE = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.SpecialtyRecordType).getRecordTypeId();
    private static final String DETAIL_RECTYPE = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(Label.DetailRecordType).getRecordTypeId();
    private static final String PROVIDER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProviderRecordType).getRecordTypeId();


    private static final String IN_DEPLOYMENT = Label.Status_Deployment;
    private static final String ACTIVE = Label.Status_Active;
    private static final String INACTIVE = Label.Status_Inactive;
    
    public static Map<Id,Decimal> fProdIdMap;
   /*
    public static void duplicateControl(List<Product2> aNewList){
        TriggerCheck.assert();

        Set<String> lProductNameSet = new Set<String>();
        for(Product2 lProduct2 : aNewList){
            lProductNameSet.add(lProduct2.Name);
        }

        Set<String> lExistingName = new Set<String>();
        for(Product2 lProduct2 :[SELECT Name FROM Product2 
                WHERE Name IN :lProductNameSet AND 
                Id NOT IN :aNewList]) {
            lExistingName.add(lProduct2.Name);
        }

        if(lExistingName.isEmpty()) return;

        for(Product2 lProduct2 : aNewList){
            if(lExistingName.contains(lProduct2.Name)){
                lProduct2.Id.addError(Label.ErrorNameProduct2part1 + '"'  + lProduct2.Name + '"' + Label.ErrorNameProduct2part2);
            }
        }
    }
    */
    public static void legacyIntegration(Map<Id,Product2> aMapNew) {
        TriggerCheck.assert();

        List<Product2> lSObjectToIntegrateLst = new List<Product2>();
        for(Product2 lProduct2: aMapNew.values()){
            if(lProduct2.Status__c != IN_DEPLOYMENT){
                if(lProduct2.RecordTypeId == SPECIALTY_RECTYPE && SpecialtyWebService.needIntegration(lProduct2)){
                    lSObjectToIntegrateLst.add(lProduct2);
                }
                else if(lProduct2.RecordTypeId == DETAIL_RECTYPE && ReasonWebService.needIntegration(lProduct2)){
                    lSObjectToIntegrateLst.add(lProduct2);
                }                
            }
        }

        if(lSObjectToIntegrateLst.isEmpty()) return;
                    
        System.enqueueJob(new IntegrationHandler_cls(lSObjectToIntegrateLst));
    }

    public static void generateExternalId(List<Product2> aProdLstNew) {
        TriggerCheck.assert();
        
        Set<Id> lRectTypeIdSet = new Set<Id>();
        List<Product2> lProdCreateIdLst = new List<Product2>();
        for(Product2 lProd :aProdLstNew){
            if(lProd.Code__c == null){
                lProdCreateIdLst.add(lProd);
                lRectTypeIdSet.add(lProd.RecordTypeId);   
            }               
        }
        if(lProdCreateIdLst.isEmpty()) return;

        if(fProdIdMap == null || !fProdIdMap.keySet().containsAll(lRectTypeIdSet)){
            fProdIdMap = new Map<Id,Decimal>();
            for(AggregateResult lAgr :[SELECT MAX(Code__c) lastValue, RecordTypeId typeId FROM Product2 WHERE RecordTypeId IN :lRectTypeIdSet AND RecordTypeId NOT IN :fProdIdMap.keySet() GROUP BY RecordTypeId]) {
                fProdIdMap.put((Id)lAgr.get('typeId'), (Decimal)lAgr.get('lastValue'));
            }
        }

        for(Product2 lProd :lProdCreateIdLst){
            Decimal lLastCode = fProdIdMap.get(lProd.RecordTypeId);
            if(lLastCode == null) lLastCode = 0;
            lProd.Code__c = ++lLastCode;
            fProdIdMap.put(lProd.RecordTypeId,lLastCode);
        }
    } 
    
    public static void validateExternalId(List<Product2> aOpStpLstNew) {

        Map<String,Product2> lProdValidateIdCodeMap = new Map<String,Product2>();
        Set<Id> lProdIdSet = new Set<Id>();
        Set<Id> lProdRecordIdSet = new Set<Id>();
        Set<Decimal> lProdCodeSet = new Set<Decimal>();

        for(Product2 lProd :aOpStpLstNew){
            if(TriggerCheck.isChanged(lProd, Product2.Code__c) && lProd.Code__c != null){
                lProdValidateIdCodeMap.put(lProd.Code__c+''+lProd.RecordTypeId,lProd);
                lProdIdSet.add(lProd.Id);
                lProdRecordIdSet.add(lProd.RecordTypeId);
                lProdCodeSet.add(lProd.Code__c);
            }
        }
        if(lProdValidateIdCodeMap.isEmpty()) return;

        for(Product2 lProd :[SELECT Code__c, RecordTypeId FROM Product2 WHERE Code__c IN :lProdCodeSet AND Id NOT IN :lProdIdSet AND RecordTypeId IN :lProdRecordIdSet]){
            Product2 lProdToNotify = lProdValidateIdCodeMap.get(lProd.Code__c+''+lProd.RecordTypeId);
            if(lProdToNotify != null){
                lProdToNotify.addError(Label.Product2validateExternalIdErro);
            }
        }
    }
    
    public static void synchronizeRescuerVehicle(List<Product2> aNewLst){
        TriggerCheck.assert();       
        
        Set<Id> lSpecialtyIdSet = new Set<Id>();
        for(Product2 lProduct :aNewLst){            
            if(lProduct.RecordtypeId == SPECIALTY_RECTYPE) {
                if(TriggerCheck.isChanged(lProduct, Product2.Status__c)) {
                    lSpecialtyIdSet.add(lProduct.Id);
                }
            }            
        } 
        if(lSpecialtyIdSet.isEmpty()) return;

        // Sincroniza as especialidades dos socorristas
        synchronizeRescuer(lSpecialtyIdSet);
        // Sincroniza as especialidades dos veiculos
        synchronizeVehicle(lSpecialtyIdSet);
    }   
    
    public static void synchronizeRescuer(Set<Id> aSpecialtyIdSet){

        Set<Id> lAbilityIdSet = new Set<Id>();
        for(Ability__c lAbility :[SELECT OperationalSetup__c FROM Ability__c WHERE Product2__c IN :aSpecialtyIdSet]){
            lAbilityIdSet.add(lAbility.OperationalSetup__c);         
        }        
        if(lAbilityIdSet.isEmpty()) return;

        RescuerWebService_cls.setRescuerToSynchronize(lAbilityIdSet);
    }    

    /*
    Método que verifica se houve mudança no status das especialidades do modal relacionado aos veiculos,
    aciona a integração para atualização das especialidades dos veiculos no legado
     */
    public static void synchronizeVehicle(Set<Id> aSpecialtyIdSet){
        
        Set<Id> lModalIdSet = new Set<Id>();
        for(SpecialtyModal__c lSpecialtyModal :[SELECT Modal__c FROM SpecialtyModal__c where Product2__c IN :aSpecialtyIdSet]) {
            lModalIdSet.add(lSpecialtyModal.Modal__c);
        }
        if(lModalIdSet.isEmpty()) return;       
        
        Map<Id,Vehicle__c> lVehicleMap = new Map<Id,Vehicle__c>([SELECT Id FROM Vehicle__c WHERE TypeModal__c IN :lModalIdSet]);

        VehicleWebService_cls.setVehicleToSynchronize(lVehicleMap.keySet());
    }

    public static void providerAbilityUpdate(List<Product2> aNewLst){
        TriggerCheck.assert();       

        Set<Id> lDetailIdSet = new Set<Id>();
        Set<Id> lSpecialtyIdSet = new Set<Id>();
        for(Product2 lDetailAndSpecialty :aNewLst){
            if( TriggerCheck.isChanged(lDetailAndSpecialty, Product2.Status__c) && !TriggerCheck.isChangedFromTo(lDetailAndSpecialty, Product2.Status__c, IN_DEPLOYMENT, INACTIVE) && !TriggerCheck.isChangedFromTo(lDetailAndSpecialty, Product2.Status__c,INACTIVE, IN_DEPLOYMENT)){
                if(lDetailAndSpecialty.RecordTypeId == SPECIALTY_RECTYPE){
                    lSpecialtyIdSet.add(lDetailAndSpecialty.Id);
                }
            }
        }

        if(lSpecialtyIdSet.isEmpty()) return;
		
        Set<Id> lAbilityIdSet = new Set<Id>();
        for(Ability__c lAbilities :[SELECT OperationalSetup__c FROM Ability__c WHERE Product2__c IN :lSpecialtyIdSet AND IsActive__c = true]){
            System.debug('Teste habilidade ' + lAbilities.OperationalSetup__c);
            lAbilityIdSet.add(lAbilities.OperationalSetup__c);
        }
        if(lAbilityIdSet.isEmpty()) return;

        //lista com todas as junções ativas entre prestador e as habilidades que são vinculadas aos motivos
        List<EquipmentSupplyPart__c> lAbilityProviderJunctionLst = [SELECT Id, Provider__c FROM EquipmentSupplyPart__c WHERE Abiliity__c IN :lAbilityIdSet AND IsActive__c = true AND Provider__r.RecordTypeId = :PROVIDER_RECTYPE AND (Provider__r.Status__c != 'Inativo' AND Provider__r.Status__c != 'Cancelado')];
        system.debug('lAbilityProviderJunctionLst ' + lAbilityProviderJunctionLst);
        if(lAbilityProviderJunctionLst.isEmpty()) return;
        
        //Chama o método da EquipmentSupplyPartHandler_cls que integra os prestadores quando há mudança nos vínculos de habilidades
        EquipmentSupplyPartHandler_cls.newProviderAbility(lAbilityProviderJunctionLst);
    }
}