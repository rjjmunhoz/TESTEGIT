/**************************************************************************************************************
* Globant Brasil
* @author        	Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Controlador do Flow
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-06-20      Jean Sganzerla          class created 
**************************************************************************************************************/

public with sharing class ReasonFlow_ctr {
    
    @InvocableMethod
    public static List<List<Product2>> getSpecialties(List<List<String>> aSpecialtyIdLst){
        
         List<Product2> lSpecialtyToReturn = new List<Product2>();
        if(aSpecialtyIdLst[0] != null){
            List<AggregateResult> lAggLst = [SELECT SpecialtyDetail__c espc, SpecialtyDetail__r.Name nome, COUNT(Detail__c) motivoNum FROM ServiceSpecialtyDetails__c WHERE IsActive__c = true AND ReasonStatus__c = 'Ativo' AND SpecialtyStatus__c = 'Ativo' AND SpecialtyDetail__c IN :aSpecialtyIdLst[0] GROUP BY SpecialtyDetail__c, SpecialtyDetail__r.Name];
            for(AggregateResult lAgg :lAggLst){
                //Se o motivoNum for igual a 1, significa que essa especialidade está associada apenas com o motivo que disparou o flow, devendo retorná-la para que ela seja desativada pelo flow
                if(lAgg.get('motivoNum') == 1){
                    Product2 lSpec = new Product2();
                    lSpec.Id = String.valueOf(lAgg.get('espc'));
                    lSpec.Name = String.valueOf(lAgg.get('nome'));
                    lSpec.Status__c = 'Inativo'; //valor inativo já colocado na lista, pois se o usuário escolher inativar essas especialidades, não é necessário rodar um loop no flow para mudar os status
                    lSpecialtyToReturn.add(lSpec);
                }
            }          
        }
        List<List<Product2>> lSpecialtyLst = new List<List<Product2>>();
        lSpecialtyLst.add(lSpecialtyToReturn);
        system.debug('lSpecialtyLst ' + lSpecialtyLst);
        return lSpecialtyLst;
    }
}