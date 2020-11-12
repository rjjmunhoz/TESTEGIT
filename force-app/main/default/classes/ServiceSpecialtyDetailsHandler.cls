/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Classe manipuladora da trigger do objeto Item de Serviço/Especialidade/Motivo
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-02-11      Eduardo Costa           class created 
**************************************************************************************************************/
public with sharing class ServiceSpecialtyDetailsHandler {

    private static final String ACTIVE = 'Ativo';

    public static void legacyIntegration(List<ServiceSpecialtyDetails__c> aServiceSpecialtyDetailsLst) {

        Set<Id> lServiceSpecialtyDetailsToIntegrateSet = new Set<Id>();
        for(ServiceSpecialtyDetails__c ServSpecDet: aServiceSpecialtyDetailsLst){
            system.debug('ServSpecDet :' + JSON.serialize(ServSpecDet));
            if(String.isNotBlank(ServSpecDet.SpecialtyStatus__c) && 
                    ServSpecDet.SpecialtyStatus__c.equals(ACTIVE) && 
                    String.isNotBlank(ServSpecDet.ReasonStatus__c) && 
                    ServSpecDet.ReasonStatus__c.equals(ACTIVE)){
                lServiceSpecialtyDetailsToIntegrateSet.add(ServSpecDet.SpecialtyDetail__c);              
            }
        }

        if(lServiceSpecialtyDetailsToIntegrateSet.isEmpty()) return;

        List<Product2> lServiceSpecialtyDetailsToIntegrateLst = SpecialtyWebService.getSpecialtyWithFieldsToIntegrate(lServiceSpecialtyDetailsToIntegrateSet);
        system.debug('ServSpecDet :' + JSON.serialize(lServiceSpecialtyDetailsToIntegrateLst));      
        if(lServiceSpecialtyDetailsToIntegrateLst.isEmpty()) return;

        System.enqueueJob(new IntegrationHandler_cls(lServiceSpecialtyDetailsToIntegrateLst));
    }
}