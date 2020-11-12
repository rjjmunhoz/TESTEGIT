/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Classe wrapper para empacotamento dos dados de especialidade do prestador e socorrista
*                   utilizada no processo de integração
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-06-11      Eduardo Costa           class created 
**************************************************************************************************************/
public with sharing class SpecialtyWrapper_cls {
    public List<SObject> fSObjectLst;
    public Map<Id,List<Integer>> fEquipmentMap;
    public Map<Id,List<Equipamentos>> fEquipmentLstMap;
    public Map<Id,List<Especialidades>> fSpecialtyLstMap;
    public Map<Id,List<Habilidades>> fAbillityLstMap;
    public Map<Id,AccountContactRelation> fAccountContactRelationMap;
    public Map<Id,List<AccountContactRelation>> fPartnersMap; //usado somente em prestador

    public SpecialtyWrapper_cls(List<SObject> aSObjectLst) {
        this.fSObjectLst = aSObjectLst;
        this.fEquipmentMap = new Map<Id,List<Integer>>();
        this.fAbillityLstMap = new Map<Id,List<Habilidades>>();
        this.fEquipmentLstMap = new Map<Id,List<Equipamentos>>();
        this.fSpecialtyLstMap = new Map<Id,List<Especialidades>>();
        this.fAccountContactRelationMap = new Map<Id,AccountContactRelation>();
    }

    public class Especialidades{
        public Integer CodigoSocorrista;
        public String Segmento;
        public Integer CodigoEspecialidade;
        public Datetime DataCadastro;
        public String UsuarioCadastro;
    }
    
    public class Habilidades{
        public Integer CodigoHabilidade;
    }

    public class Equipamentos{
        public Integer CodigoEquipamento;
    }

    public class AccountContactRelation{
        public String contractType;
        public Date startDate;
        public Date endDate;
        public String code; //usado somente nos sócios do prestador
        public String name; //usado somente nos sócios do prestador
        public String CPF; //usado somente nos sócios do prestador
        public String PEP; //usado somente nos sócios do prestador
        
        public AccountContactRelation(String aContractType, Date aStartDate, Date aEndDate) {
            this.contractType = aContractType;
            this.startDate = aStartDate;
            this.endDate = aEndDate;
        }

        public AccountContactRelation(String aCode, String aName, String aCPF, String aPEP){
            this.code = aCode;
            this.name = aName;
            this.CPF = aCPF;
            this.PEP = aPEP;
        }
    }    
}