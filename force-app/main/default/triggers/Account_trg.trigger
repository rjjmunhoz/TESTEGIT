trigger Account_trg on Account(before update, before insert,after insert, after update) {
   if (!TriggerCheck.isActive('Account')) return;

   if (trigger.isBefore) {
      if (trigger.isUpdate) {
         //AccountHandler.checkSupplierAccountActivation(trigger.newMap);
         AccountHandler.providerGeoCodeChange(trigger.new);
      }

      if(trigger.isInsert){
         AccountHandler.generateExternalId(trigger.new);
      }
   }

   if(trigger.isAfter){
      if (trigger.isInsert) {
         AccountHandler.getSucursal(trigger.newMap);
      }
      if (trigger.isUpdate) {
         AccountHandler.getSucursal(trigger.newMap);
         AccountHandler.legacyIntegration(trigger.newMap);
         AccountHandler.contactPFProvider(trigger.new);
      }
   }
}