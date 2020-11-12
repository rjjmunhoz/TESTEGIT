trigger Contact_trg on Contact (before update, after update, before insert) {

    if (!TriggerCheck.isActive('Contact')) return;

    if (trigger.isBefore) {
      if (trigger.isUpdate) {
         ContactHandler.generateQRA(trigger.new);
         ContactHandler.providerActivation(trigger.new);         
      }

      if(trigger.isInsert){
         ContactHandler.generateExternalId(trigger.new);
     }
   }

   if (trigger.isAfter) {
      if (trigger.isUpdate) {
         ContactHandler.validateQRA(trigger.new);
         ContactHandler.removeJunctionContactToContact(trigger.new);
      }
      if(trigger.isInsert || trigger.isUpdate){
         ContactHandler.legacyIntegration(trigger.new);
         ContactHandler.rollUpContactProvider(trigger.new);
      }
   }
}