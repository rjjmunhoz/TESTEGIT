/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Handler da Trigger do Modal
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-11-07      Matheus Branco          class created 
* @version   1.1    2019-11-13      Matheus Branco          class update
* @version   1.2    2020-01-24      Matheus Branco          class update
**************************************************************************************************************/
public class ModalHandler {

    private static final String ACTIVE = Label.Status_Active;
    private static final String IN_DEPLOYMENT = Label.Status_Deployment;
    
    public static void checksModalActivation(Map<Id, Modal__c> aMapNew){
        TriggerCheck.assert();
        //Comentario de teste de DevOps.
        
        List<Modal__c> lModalToCheckLst = new List<Modal__c>();
        for(Modal__c lModal: aMapNew.values()){
            if(TriggerCheck.isChangedTo(lModal, Modal__c.Status__c, ACTIVE) && lModal.ModalType__c != NULL){
                lModalToCheckLst.add(lModal);
            }
        }
        
        if(lModalToCheckLst.isEmpty()) return;

        Set<Id> lSupplySet = new Set<Id>();
        for(Supply__c lSupply: [SELECT Id, Modal__c FROM Supply__c WHERE Modal__c IN: lModalToCheckLst ORDER BY Modal__c]){
            lSupplySet.add(lSupply.Modal__c);
        }

        Set<Id> lEquipmentSet = new Set<Id>();
        for(Equipment__c lEquipment: [SELECT Id, Modal__c FROM Equipment__c WHERE Modal__c IN: lModalToCheckLst ORDER BY Modal__c]){
            lEquipmentSet.add(lEquipment.Modal__c);
        }

        for(Modal__c lModal: lModalToCheckLst){
            if(((!lSupplySet.contains(lModal.Id) || !lEquipmentSet.contains(lModal.Id)) &&
                (lModal.ModalType__c == Label.ModalTypeAutomotive || lModal.ModalType__c == Label.ModalTypeMotorcycle || lModal.ModalType__c == Label.ModalTypeBike || lModal.ModalType__c == Label.ModalTypeResidential))){
                aMapNew.get(lModal.Id).addError(Label.MessageToActiveModal);

            }else if((!lSupplySet.contains(lModal.Id)) && (lModal.ModalType__c == Label.ModalTypeSustainable)){
                aMapNew.get(lModal.Id).addError(Label.MessageToActiveModal2);
            }
        }
    }

    public static void legacyIntegration(Map<Id,Modal__c> aMapNew) {
        TriggerCheck.assert();

        List<Modal__c> lModalLst = new List<Modal__c>();
        for(Modal__c lModal: aMapNew.values()){
            if(lModal.Status__c != IN_DEPLOYMENT){
                lModalLst.add(lModal);
            }
        }
        system.debug('lModalLst ' + lModalLst);
        if(lModalLst.isEmpty()) return;               
        
        List<Modal__c> lModalToIntegrationLst = ModalWebService.getModalToIntegration(lModalLst);
        if(!lModalToIntegrationLst.isEmpty()) {
            System.enqueueJob(new IntegrationHandler_cls(lModalToIntegrationLst));
        }   
    }
}