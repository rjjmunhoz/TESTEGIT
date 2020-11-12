/**************************************************************************************************************
* Globant Brasil
* @author        	Eduardo Costa (eduardo.borges@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de seguro de vida do colaborador
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-03-19      Eduardo Costa           class created 
**************************************************************************************************************/
public with sharing class ContactLifeInsuranceWebService extends AWS_API {
	
    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();
    private static final String SOCORRISTAS_VIDA = Label.RescuerLifeEndPoint;

    public class ContactLifeInsurance implements Comparable {
		public String NumeroEstipulante;
        public Integer NumeroItem;
        public String SeguradoNomeCompleto;
        public String NumeroCgcCpf;
        public String DigitoCgcCpf;
        public String DataNascimento;
        public String SexoSegurado;
        public Integer CodigoEstadoCivil;
        public String DataInicioVigenciaSegurado;
        public String FlagAumentoAutomatico;
        public String DataInicioVigenciaResseguro;
        public String StatusSegurado;
        public Integer CodigoFaixaIdade;
        public String DataAtualizacao;
        public String CodigoEmpresaAtualizacao;
        public String MatriculaFuncionarioAtualizacao;
        public String FlagImportanciaSeguradaDiferenciada;
        public Integer NroDigitoCartaoProposta;
        public Integer CodigoProfissao;
        public Decimal ValorRendaMensal;
        public Integer TipoPessoaExpostaPoliticamente;
        public String NomePessoaExpostaPoliticamente;
        public String FlagEstadoPassagemRsd;
        public String CpfPessoaExpostaPoliticamente;
        public String DigitoCpfPessoaExpostaPoliticamente;
        public Integer GrauRelacionamentoParentescoPessoaExpostaPoliticamente;
        public Integer OrdemCgc;
        public String CodigoNacionalidadeSegurado;
        public String NomePaiResponsavel;
        public String DescricaoProduto;
        public String DescricaoSubproduto;
        
        public Integer compareTo(Object compareTo) {
            ContactLifeInsurance compareToEmp = (ContactLifeInsurance)compareTo;            
            if(StatusSegurado == compareToEmp.StatusSegurado) {
                Date lDataInicioVigenciaSegurado = Date.newInstance(1950, 1, 1); // valor padrão para caso vir nulo
                Date lDataInicioVigenciaSeguradoCompare = Date.newInstance(1950, 1, 1); // valor padrão para caso vir nulo
                if(String.isNotBlank(DataInicioVigenciaSegurado)) {
                    lDataInicioVigenciaSegurado = Date.valueOf(DataInicioVigenciaSegurado.split('T')[0]);
                }                
                if(String.isNotBlank(compareToEmp.DataInicioVigenciaSegurado)) {
                    lDataInicioVigenciaSeguradoCompare = Date.valueOf(compareToEmp.DataInicioVigenciaSegurado.split('T')[0]);
                }
                if(lDataInicioVigenciaSegurado == lDataInicioVigenciaSeguradoCompare) return 0;
                else if(lDataInicioVigenciaSegurado < lDataInicioVigenciaSeguradoCompare) return 1;
            }
            else if(StatusSegurado > compareToEmp.StatusSegurado) return 1;
            return -1;        
        }
	}    

    public ContactLifeInsuranceWebService() {
        super(SOCORRISTAS_VIDA);
    }

    public List<ContactLifeInsuranceWebService.ContactLifeInsurance> getContactLifeInsurance(String aCPF, String aAssigmentRuleId){
		String lEndpoint = this.fReq.getEndpoint();
        List<Object> lParameters = new List<Object> {aCPF};
        this.fReq.setEndpoint(String.format(lEndpoint, lParameters));
		AWS_API.ResponseWrapper lResult =  this.doRequest();   
		//system.debug('SocorristasVida Body: ' + JSON.serialize(lResult.response.getBody()));                  
        if(!lResult.success) {
            Database.DMLOptions lDMLOptions = new Database.DMLOptions();
            lDMLOptions.EmailHeader.triggerUserEmail = true;
            lDMLOptions.assignmentRuleHeader.assignmentRuleId = aAssigmentRuleId;
            Case lCase = new Case(Subject = Label.String_StatusCode + ' ' + String.Valueof(lResult.response.getStatusCode()), Status = Label.String_OnHold , RecordCode__c = aCPF, Description = lResult.message, ObjectType__c = Label.ObjectLifeRescuer, RecordTypeId = SUPPORT_API, Origin = Label.FieldValueIntegrationFailure);
            lCase.setOptions(lDMLOptions);
            insert lCase;
            return null;
        }
        else {
            return (List<ContactLifeInsuranceWebService.ContactLifeInsurance>) System.JSON.deserialize(lResult.response.getBody(), List<ContactLifeInsuranceWebService.ContactLifeInsurance>.class);
        }  
	}
}