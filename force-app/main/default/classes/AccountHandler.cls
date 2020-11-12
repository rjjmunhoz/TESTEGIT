/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger de Account
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-11-14      Matheus Branco          class created 
**************************************************************************************************************/
public class AccountHandler {

   private static final String SUPPLIER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.SupplierRecordType).getRecordTypeId();
   private static final String PROVIDER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProviderRecordType).getRecordTypeId();
   private static final String PRODUCT_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.ProductRecordType).getRecordTypeId();
   private static final String BASE_EMPLOYEES_RECTYPEID = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.BaseEmployeesRecordType).getRecordTypeId();    

   
   public static void providerGeoCodeChange(List<Account> aProviderLst){
      TriggerCheck.assert();

      
      for(Account lAccount: aProviderLst){
         if(TriggerCheck.isChanged(lAccount, Account.OperationalUfPickList__c) && lAccount.RecordTypeId == PROVIDER_RECTYPE){
            lAccount.OperationalUf__c = lAccount.OperationalUfPickList__c;
         }
         if(TriggerCheck.isChanged(lAccount, Account.DeliveryUf__c) && lAccount.RecordTypeId == PROVIDER_RECTYPE){
            lAccount.DeliveryUfText__c = lAccount.DeliveryUf__c;
         }
         if(TriggerCheck.isChanged(lAccount, Account.TaxUf__c) && lAccount.RecordTypeId == PROVIDER_RECTYPE){
            lAccount.TaxUfText__c = lAccount.TaxUf__c;
         }
      }
   }

   	public static void legacyIntegration(Map<Id,Account> aMapNew) {
        TriggerCheck.assert();

        List<Account> lAccountLst = new List<Account>();
        for(Account lAccount :aMapNew.values()){
            if(lAccount.Synced__c == true && (lAccount.RecordTypeId == PROVIDER_RECTYPE)){
                lAccountLst.add(lAccount);              
            }
		}
        if(lAccountLst.isEmpty()) return;       

        SpecialtyWrapper_cls lSObjectToIntegrateLst = ProviderWebService_cls.getProviderToIntegration(lAccountLst);
        if(lSObjectToIntegrateLst != null) {
            System.enqueueJob(new IntegrationHandler_cls(lSObjectToIntegrateLst));
        }
	}

   public static void contactPFProvider(List<Account> aLstNew) {
      TriggerCheck.assert();

      Map<String,String> lAccountPFMap = new Map<String,String>();
      for(Account lAccount :aLstNew){
          if(lAccount.LegalSituation__c == Label.PhysicalPerson &&  !TriggerCheck.isChangedTo( lAccount, Account.StatusRadar__c, Label.Status_WaitingRadar) && lAccount.Status__c == Label.Status_Deployment && (lAccount.RecordTypeId == PROVIDER_RECTYPE)){
            lAccountPFMap.put(lAccount.CNPJ__c,lAccount.StatusRadar__c);  
            System.debug('Map PF' + lAccountPFMap);           
          }
    }
      if(lAccountPFMap.isEmpty()) return;

      List<Contact> lContactToUpdate = [SELECT Id, CPF__c, StatusRadar__c  FROM Contact WHERE CPF__c = :lAccountPFMap.keySet() AND RecordTypeId = :BASE_EMPLOYEES_RECTYPEID AND StatusRadar__c !='L' AND StatusRadar__c != 'B' AND RisksStatus__c !='Liberado' AND RisksStatus__c != 'Recusado'];
      for(Contact lContact :lContactToUpdate){
         lContact.StatusRadar__c = lAccountPFMap.get(lContact.CPF__c);
         System.debug('Status Radar'+ lContact.StatusRadar__c);
      }
      
      update lContactToUpdate; 

 }

	public static void getSucursal(Map<Id,Account> aMapNew) {
		TriggerCheck.assert();

        Set<Id> lAccountSet = new Set<Id>();
        for(Account lAccount :aMapNew.values()){
            if((!TriggerCheck.isChanged(lAccount,Account.SucursalCode__c) || lAccount.SucursalCode__c == null) && (TriggerCheck.isChanged(lAccount,Account.TaxCity__c) || TriggerCheck.isChanged(lAccount,Account.TaxUf__c)) && lAccount.RecordTypeId == PROVIDER_RECTYPE){
                lAccountSet.add(lAccount.Id);              
            }
		}
		system.debug('lAccountSet ' + lAccountSet);
		if(lAccountSet.isEmpty()) return;    
		
		List<Account> lProviderSucursalLst = [SELECT Id, SucursalCode__c, TaxCity__c, Code__c, TaxUf__c FROM Account WHERE Id IN :lAccountSet];
		for(Account lAcc :lProviderSucursalLst){
			lAcc.SucursalCode__c = null;
		}
		System.enqueueJob(new IntegrationHandler_cls(lProviderSucursalLst));

   }
   
   public static void generateExternalId(List<Account> aAccLstNew) {
      TriggerCheck.assert();
      
      List<Account> lProviderCreateIdLst = new List<Account>();
      for(Account lProvider :aAccLstNew){
         if(lProvider.Code__c == null && lProvider.RecordTypeId == PROVIDER_RECTYPE){
            lProviderCreateIdLst.add(lProvider);
         }               
      }
      if(lProviderCreateIdLst.isEmpty()) return;

      Decimal lLastCode;
      for(AggregateResult lAgr :[SELECT MAX(Code__c) lastValue FROM Account]) {
         lLastCode = (Decimal)lAgr.get('lastValue');
      }

      if(lLastCode == null) lLastCode = 0;
      for(Account lProvider :lProviderCreateIdLst){
         lProvider.Code__c = ++lLastCode;
      }
  }
  
// Retirado a parte do fornecedor por conta de ser necessário subir agr
   /*public static void checkSupplierAccountActivation(Map<Id,Account> aMapNew){
      TriggerCheck.assert();

      List<Account> lSupplierAccountToCheckLst = new List<Account>();
      for(Account lAccount: aMapNew.values()){
         if(TriggerCheck.isChangedTo(lAccount, Account.Status__c, 'Ativo') && lAccount.RecordTypeId == SUPPLIER_RECTYPE) {
            lSupplierAccountToCheckLst.add(lAccount);
         }
      }

      if(lSupplierAccountToCheckLst.isEmpty()) return;

      Set<Id> lEquipmentSet = new Set<Id>();
      for(EquipmentSupplyPart__c lEquipment: [SELECT Id, Account__c FROM EquipmentSupplyPart__c WHERE Account__c IN: lSupplierAccountToCheckLst ORDER BY Account__c]) {
         lEquipmentSet.add(lEquipment.Account__c);
      }

      Set<Id>lPecaSet = new Set<Id>();
      for (EquipmentSupplyPart__c lPeca: [SELECT Id, ProviderPart__c FROM EquipmentSupplyPart__c WHERE ProviderPart__c IN: lSupplierAccountToCheckLst ORDER BY ProviderPart__c]) {
         lPecaSet.add(lPeca.ProviderPart__c);
      }

      Set<Id> lInsumoSet = new Set<Id>();
      for(EquipmentSupplyPart__c lInsumo: [SELECT Id, ProviderInputs__c FROM EquipmentSupplyPart__c WHERE ProviderInputs__c IN: lSupplierAccountToCheckLst ORDER BY ProviderInputs__c]) {
         lInsumoSet.add(lInsumo.ProviderInputs__c);
      }

      for(Account lAccount: lSupplierAccountToCheckLst){
         if(!lEquipmentSet.contains(lAccount.Id) || !lPecaSet.contains(lAccount.Id) || !lInsumoSet.contains(lAccount.Id)){
            aMapNew.get(lAccount.Id).addError('Para ativar esse Fornecedor será necessário cadastrar ou vincular Equipamentos, Peças ou Insumos.');
         }
      }
   }*/
}