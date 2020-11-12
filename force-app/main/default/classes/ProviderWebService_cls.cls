/**************************************************************************************************************
* Globant Brasil
* @author           Jean Sganzerla (jean.francomme@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Prestador
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-04-27      Jean Sganzerla          class created 
* @version   2.0    2020-05-08      Jean Sganzerla          new version, with new requirements 
* @version   2.1    2020-07-21      Misael Ribas            schedule value adjustment
**************************************************************************************************************/
public with sharing class ProviderWebService_cls extends AWS_API{
    private static final String PROVIDER = Label.String_Provider;
    private static final String ACTIVE = Label.Status_Active;

    private static final Id SUPPORT_API = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.SupportAPIsRecordType).getRecordTypeId();
    private static String fAssigmentRuleId;
    private static Id fRecordCode;
    
    private static final Map<String,String> STATUS_MAP {
        get {
            if(STATUS_MAP != null) {
                return STATUS_MAP;
            }
            else {
                STATUS_MAP = new Map<String,String>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'ProviderStatus' AND IsActive__c = true]) {
                    STATUS_MAP.put(lLegacyDomainTableValue.Key__c, lLegacyDomainTableValue.Value__c);
                }
                return STATUS_MAP;
            }            
        }
        set;
    }

    private static final Map<String,String> BOOLEAN_MAP {
        get {
            if(BOOLEAN_MAP != null) {
                return BOOLEAN_MAP;
            }
            else {
                BOOLEAN_MAP = new Map<String,String>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'ProviderBoolean' AND IsActive__c = true]) {
                    BOOLEAN_MAP.put(lLegacyDomainTableValue.Key__c, lLegacyDomainTableValue.Value__c);
                }
                return BOOLEAN_MAP;
            }            
        }
        set;
    }
    //Map que identifica se o telefone é fixo ou celular pelo número de caracteres; Se contém 10 char = fixo, se contém 11 char = celular.
    //Map não está sendo utilizado atualmente, pois, o informix não tem a capacidade de gravar dois telefones do mesmo tipo.
    private static final Map<Integer,Integer> PHONETYPE_MAP = new Map<Integer,Integer>{
        10 => 1,
        11 => 3
    };
    
    public Integer CodigoPrestador;
    // public String CodigoPrestadorPrincipal; // não enviar
    public Integer PesCod;
    public String NumeroDocumento;
    public String StatusDocumento;
    public String NomePrestador;
    public String StatusPrestador;
    public String ObservacoesGerais;
    public String FormaPagamento;
    public DadosPessoais DadosPessoais;
    public DadosOperacionais DadosOperacionais;
    public DadosPagamento DadosPagamento;
    public DadosBancarios DadosBancarios;
    public DadosContrato DadosContrato;
    public DadosFiscais DadosFiscais;
    public List<Enderecos> Enderecos;
    public List<SociosControladores> SociosControladores;
    public List<Telefones> Telefones;
    public List<Especialidades> Especialidades;
    public List<Habilidades> Habilidades;
    public List<Equipamentos> Equipamentos;
    public DadosSistema DadosSistema;


    public class DadosPessoais {
        public Integer CodigoTipoPrestador;
        public String NomeProprietario; 
        public String NomeResponsavel;
        public String RazaoSocial;
        public string TipoPessoa;
    }    

    public class DadosOperacionais{
        List<Integer> AtividadesPrincipais;
        List<Integer> Empresas;
        //Integer CodigoCadeiaGestao; // não enviar
        // Integer CodigoTipoCooperativa; // não enviar
        String Email;
        String FlagAtende24h;
        String FlagPossuiPatio;
        // String FlagPreencheLaudoRIS; // não enviar
        // String FlagResponsavelFrota; //não enviar
        String FlagTipoAcionamento;
        public Integer QuantidadeServico;
        public Integer QuantidadeRecurso;
    }
    
    public class DadosPagamento{
        Integer CodigoCronogramaPagamento;
        Decimal CodigoSucursal;
        Integer CodigoTabelaPagamento;
        String FlagUsaTabela;
    }

    public class DadosBancarios{
        // Integer CodigoPessoa; //Não temos essa info ainda
        // String NomeFavorecido; //não enviar
        // String TipoPessoa; //não enviar
        // Integer NumeroCPF; //não enviar
        // Date DataNascimento; //não enviar
        // String Sexo; //não enviar
        Integer CodigoBanco;
        Integer TipoConta;
        Integer NumeroAgencia;
        String DigitoAgencia;
        String NumeroConta;
        String DigitoConta;
        Integer CodigoOpcaoPagamento;
    }

    public class DadosContrato{
        Date DataInicioVigenciaContrato;
        Date DataFinalVigenciaContrato;
    }

    public class DadosFiscais{
        
        // Integer CodigoEmpresaFaixaPatrimonioLiquido; //não enviar
        // Integer CodigoEmpresaFaixaRenda; //não enviar
        Integer CodigoFaixaPatrimonioLiquido;
        // Integer CodigoFaixaRenda; // não enviar
        Integer CodigoVlrReceitaBrutaAnual;
        String FlagOptantePeloSimples;
        String NumeroInscricaoMunicipal;
        // String NumeroNIT; //não enviar
        String NumeroPIS;
    }

    public class Enderecos{
        Integer CodigoTipoEndereco;
        String TipoLogradouro;
        String Logradouro;
        String NumeroLogradouro;
        String ComplementoLogradouro;
        String Bairro;
        String Cidade;
        String UF;
        String CEP;
        Decimal Latitude;
        Decimal Longitude;
        // String CodigoCidadeGuiaPostal; // não enviar
        // String CodigoPadronizacaoLocalCt24h; // não enviar

        public Enderecos(Integer aCodigoTipoEndereco, String aTipoLogradouro, String aLogradouro, String aNumeroLogradouro, String aComplementoLogradouro, String aBairro, String aCidade, String aUF, String aCEP, Decimal aLatitude, Decimal aLongitude){
            this.CodigoTipoEndereco = aCodigoTipoEndereco;
            this.TipoLogradouro = aTipoLogradouro;
            this.Logradouro = aLogradouro;
            this.NumeroLogradouro = aNumeroLogradouro;
            this.ComplementoLogradouro = aComplementoLogradouro;
            this.Bairro = aBairro;
            this.Cidade = aCidade;
            this.UF = aUF;
            this.CEP = aCEP;
            this.Latitude = aLatitude;
            this.Longitude = aLongitude;
        }        
    }

    public class SociosControladores{
        Integer CodigoControlador;
        // Integer CodigoPessoa; //Não temos essa info ainda
        String FlagPessoaExpostaPoliticamente;
        String NomeControlador;
        String NumeroCPF;
        // String TipoControlador; //não enviar
    }

    public class Telefones{
        Integer CodigoTipoTelefone;
        String NumeroTelefone;
        public Telefones(Integer aCodigoTipoTelefone, String aNumeroTelefone){
            this.CodigoTipoTelefone = aCodigoTipoTelefone;
            this.NumeroTelefone = aNumeroTelefone;
        }
        // String NomeContato; //não enviar
    }
    
    public class Especialidades{
        Integer CodigoEspecialidade;
        String Segmento;
    }

    public class Habilidades{
        Integer CodigoHabilidade;
    }

    public class Equipamentos{
        Integer CodigoEquipamento;
    }

    public class DadosSistema{
       String UsuarioCriacao;
       DateTime DataCriacao;
       String UsuarioAtualizacao;
       DateTime DataAtualizacao;
    }

    
    public ProviderWebService_cls(SObject aAccount, List<SpecialtyWrapper_cls.Especialidades> aSpecialtyLst, List<SpecialtyWrapper_cls.AccountContactRelation> aPartnerInformationLst, List<SpecialtyWrapper_cls.Habilidades> aAbilityLst, List<SpecialtyWrapper_cls.Equipamentos> aEquipmentLst) {
        super(PROVIDER);
        Account lAccount = (Account)aAccount;
        
        this.CodigoPrestador = lAccount.Code__c != null?Integer.valueOf(lAccount.Code__c):null;
        this.PesCod = lAccount.PesCod__c != null?Integer.valueOf(lAccount.PesCod__c):null;
        
        this.NumeroDocumento = lAccount.CNPJ__c;
        this.StatusDocumento = lAccount.CardSituation__c;
        
        this.NomePrestador = lAccount.Name;
        this.StatusPrestador = String.isNotBlank(STATUS_MAP.get(lAccount.Status__c))?String.valueOf(STATUS_MAP.get(lAccount.Status__c)):null;
        this.ObservacoesGerais = lAccount.Note__c;
        this.FormaPagamento = lAccount.PaymentMethod__c;

        this.DadosPessoais = new DadosPessoais();        
        this.DadosPessoais.CodigoTipoPrestador = String.isNotBlank(lAccount.ProviderType__c)?Integer.ValueOf(lAccount.ProviderType__c):null;
        if(aPartnerInformationLst != null && !aPartnerInformationLst.isEmpty()) {
            this.DadosPessoais.NomeProprietario = aPartnerInformationLst[0].name;
            this.DadosPessoais.NomeResponsavel = aPartnerInformationLst[0].name;
        }  
        this.DadosPessoais.RazaoSocial = lAccount.CompanyName__c;
        this.DadosPessoais.TipoPessoa = lAccount.LegalSituation__c;
        

        this.DadosOperacionais = new DadosOperacionais();
        this.DadosOperacionais.AtividadesPrincipais = new List<Integer>();  
        this.DadosOperacionais.Empresas = new List<Integer>();
        if(String.isNotBlank(lAccount.ContractType__c)) {
            for(String lContractTypeCodes :lAccount.ContractType__c.split(';')){
                this.DadosOperacionais.AtividadesPrincipais.add(Integer.ValueOf(lContractTypeCodes));
            }
        }        
        if(String.isNotBlank(lAccount.GroupCompanies__c)) {
            for(String lCompaniesCode :lAccount.GroupCompanies__c.split(';')){
                this.DadosOperacionais.Empresas.add(Integer.ValueOf(lCompaniesCode)); 
            }  
        }      
        this.DadosOperacionais.Email = lAccount.Email__c;
        this.DadosOperacionais.FlagAtende24h = lAccount.Attend24h__c != null?String.ValueOf(BOOLEAN_MAP.get(lAccount.Attend24h__c)):null;
        this.DadosOperacionais.FlagPossuiPatio = lAccount.HaveParking__c;
        this.DadosOperacionais.FlagTipoAcionamento = lAccount.ActuationType__c; 
        this.DadosOperacionais.QuantidadeServico = lAccount.QuantityService__c != null?Integer.ValueOf(lAccount.QuantityService__c):0;
        this.DadosOperacionais.QuantidadeRecurso = lAccount.QuantityResources__c != null?Integer.ValueOf(lAccount.QuantityResources__c):0;

        this.DadosPagamento = new  DadosPagamento();
        this.DadosPagamento.CodigoCronogramaPagamento = lAccount.ScheduleCode__c != null? Integer.valueOf(lAccount.ScheduleCode__c):0;
        this.DadosPagamento.CodigoSucursal = lAccount.SucursalCode__c;
        this.DadosPagamento.CodigoTabelaPagamento = lAccount.PayTable__c != null? Integer.ValueOf(lAccount.PayTable__c) : null;
        this.DadosPagamento.FlagUsaTabela = lAccount.UseChart__c;

        this.DadosBancarios = new DadosBancarios();
        this.DadosBancarios.CodigoBanco = lAccount.BankName__c != null?Integer.valueOf(lAccount.BankName__c):null;
        this.DadosBancarios.TipoConta = lAccount.BankAccountType__c != null?Integer.valueOf(lAccount.BankAccountType__c):null;
        this.DadosBancarios.NumeroAgencia = lAccount.Branch__c != null?Integer.valueOf(lAccount.Branch__c):null;
        this.DadosBancarios.DigitoAgencia = lAccount.DigitAgency__c;
        this.DadosBancarios.NumeroConta =  lAccount.CheckingAccount__c;
        this.DadosBancarios.DigitoConta = lAccount.CurrentAccountDigit__c;
        this.DadosBancarios.CodigoOpcaoPagamento = 1; //Integer.ValueOf(lAccount.PaymentOption__c); // NECESSITA LEVANTAR CÓDIGOS

        this.DadosContrato = new DadosContrato();
        this.DadosContrato.DataInicioVigenciaContrato = lAccount.EffectiveDate__c;
        this.DadosContrato.DataFinalVigenciaContrato = lAccount.EffectiveEndDate__c;
       
        this.DadosFiscais = new DadosFiscais();
        this.DadosFiscais.CodigoFaixaPatrimonioLiquido = lAccount.PatrimonyLiquid__c != null?Integer.valueOf(lAccount.PatrimonyLiquid__c):null;
        this.DadosFiscais.CodigoVlrReceitaBrutaAnual = lAccount.AnnualGrossRevenue__c != null?Integer.valueOf(lAccount.AnnualGrossRevenue__c):null;
        //this.DadosFiscais.FlagOptantePeloSimples != null?lAccount.OptingForSimple__c:'N';
        this.DadosFiscais.FlagOptantePeloSimples = ( lAccount.OptingForSimple__c == null ) ? 'N' :  lAccount.OptingForSimple__c;
        this.DadosFiscais.NumeroInscricaoMunicipal = lAccount.MunicipalRegistration__c;
        this.DadosFiscais.NumeroPIS = lAccount.PIS_NIT__c;

        this.Enderecos = new List<Enderecos>();
        //Adicionando Endereço Operacional
        this.Enderecos.add( 
            new Enderecos(
                1,
                lAccount.OperationalPublicPlace__c,
                lAccount.OperationalStreet__c,
                lAccount.OperationalNumber__c,
                lAccount.OperationalComplement__c,
                lAccount.OperationalNeighborhood__c,
                lAccount.OperationalCity__c,
                lAccount.OperationalUfPickList__c,
                lAccount.OperationalZip__c,
                lAccount.BillingLatitude != null?lAccount.BillingLatitude.setScale(6):null,
                lAccount.BillingLongitude != null?lAccount.BillingLongitude.setScale(6):null
            )
        );  
        // Adicionando Endereço Fiscal      
        this.Enderecos.add( 
            new Enderecos(
                2,
                lAccount.TaxPublicPlace__c,
                lAccount.TaxStreet__c,
                lAccount.TaxNumber__c != null?String.valueOf(lAccount.TaxNumber__c):null,
                lAccount.TaxComplement__c,
                lAccount.TaxNeighbourhood__c,
                lAccount.TaxCity__c,
                lAccount.TaxUf__c,
                lAccount.TaxZIP__c,
                null,
                null 
            )
        );
        // Adicionando Endereço de Entrega
        this.Enderecos.add( 
            new Enderecos(
                3,
                lAccount.DeliveryPublicPlace__c,
                lAccount.DeliveryStreet__c,
                lAccount.DeliveryNumber__c,
                lAccount.DeliveryComplement__c,
                lAccount.DeliveryNeighborhood__c,
                lAccount.DeliveryCity__c,
                lAccount.DeliveryUf__c,
                lAccount.DeliveryZip__c,
                lAccount.ShippingLatitude != null?lAccount.ShippingLatitude.setScale(6):null,
                lAccount.ShippingLongitude != null?lAccount.ShippingLongitude.setScale(6):null
            )
        );

        //Envio dos sócios
        this.SociosControladores = new List<SociosControladores>();
        if(aPartnerInformationLst != null) {
            for(SpecialtyWrapper_cls.AccountContactRelation lPartners :aPartnerInformationLst){
                SociosControladores lPartnersToAdd = new SociosControladores();
                lPartnersToAdd.FlagPessoaExpostaPoliticamente = lPartners.PEP;
                lPartnersToAdd.CodigoControlador = lPartners.code != null ? Integer.valueOf(lPartners.code) : null;
                lPartnersToAdd.NomeControlador = lPartners.name;
                lPartnersToAdd.NumeroCPF = lPartners.CPF;
                this.SociosControladores.add(lPartnersToAdd); 
            }
        }
        
        this.Telefones = new List<Telefones>();
        this.Telefones.add(
            new Telefones(
                // PHONETYPE_MAP.get(lAccount.OperationalPhone__c.length()), // Lógica do telefone não está sendo usada para o informix, porque o informix não tem a capacidade de gravar dois telefones do mesmo tipo
                1,
                lAccount.OperationalPhone__c
            )
        );
        if(lAccount.Phone != null){
            this.Telefones.add(
                new Telefones(
                    // PHONETYPE_MAP.get(lAccount.Phone.length()), // Lógica do telefone não está sendo usada para o informix, porque o informix não tem a capacidade de gravar dois telefones do mesmo tipo
                    3,
                    lAccount.Phone
                )
            );
        }

        this.Especialidades = new List<Especialidades>();
        if(aSpecialtyLst != null){
            for(SpecialtyWrapper_cls.Especialidades lSpec :aSpecialtyLst){
                Especialidades EspecialidadesToAdd = new Especialidades();
                EspecialidadesToAdd.CodigoEspecialidade = lSpec.CodigoEspecialidade;
                EspecialidadesToAdd.Segmento = lSpec.Segmento;
    
                this.Especialidades.add(EspecialidadesToAdd);
            }
        }

        this.Habilidades = new List<Habilidades>();
        if(aAbilityLst != null){
            for(SpecialtyWrapper_cls.Habilidades lAbility :aAbilityLst){
                Habilidades HabilidadesToAdd = new Habilidades();
                HabilidadesToAdd.CodigoHabilidade = lAbility.CodigoHabilidade;
    
                this.Habilidades.add(HabilidadesToAdd);
            }
        }

        this.Equipamentos = new List<Equipamentos>();
        if(aEquipmentLst != null){
            for(SpecialtyWrapper_cls.Equipamentos lEquipment :aEquipmentLst){
                Equipamentos EquipamentosToAdd = new Equipamentos();
                EquipamentosToAdd.CodigoEquipamento = lEquipment.CodigoEquipamento;
    
                this.Equipamentos.add(EquipamentosToAdd);
            }
        }

        this.DadosSistema = new DadosSistema();
        this.DadosSistema.UsuarioCriacao = lAccount.CreatorFederationIdentifier__c;
        this.DadosSistema.DataCriacao = lAccount.CreatedDate;
        this.DadosSistema.UsuarioAtualizacao = lAccount.ModifierFederationIdentifier__c;
        this.DadosSistema.DataAtualizacao = lAccount.LastModifiedDate;
    }

    public AWS_API.ResponseWrapper setAwsProvider(){
        this.fReq.setBody(JSON.serialize(this));
        system.debug('setAwsProvider: ' + this.fReq.getBody());
        AWS_API.ResponseWrapper lResult =  this.doRequest();        
        system.debug('Result.success ' + lResult.success);
        return lResult;
    }


    public static SpecialtyWrapper_cls getProviderToIntegration(List<Account> aAccountLst) {
        
        TriggerCheck.assert();        
        
        Map<Id,Account> lAccountToIntegrateMap = new Map<Id,Account>();
        for(Account lAccount :aAccountLst) {
            // Adicionados em primeiro os campos com maior chances de alteração
            if(lAccount.Synced__c && (
                   TriggerCheck.isChanged(lAccount,Account.Name) || 
                    TriggerCheck.isChanged(lAccount,Account.CNPJ__c) ||
                	TriggerCheck.isChanged(lAccount,Account.CardSituation__c) ||
                    TriggerCheck.isChanged(lAccount,Account.CompanyName__c) ||
                    TriggerCheck.isChanged(lAccount,Account.ProviderType__c) ||
                    TriggerCheck.isChanged(lAccount,Account.Note__c) ||
                    TriggerCheck.isChanged(lAccount,Account.BankName__c) ||
                    TriggerCheck.isChanged(lAccount,Account.ScheduleLink__c) ||
                    TriggerCheck.isChanged(lAccount,Account.PaymentOption__c) ||
                    TriggerCheck.isChanged(lAccount,Account.PayTable__c) ||
                    TriggerCheck.isChanged(lAccount,Account.ScheduleType__c) ||
                    TriggerCheck.isChanged(lAccount,Account.Branch__c) ||
                    TriggerCheck.isChanged(lAccount,Account.CheckingAccount__c) ||
                    TriggerCheck.isChanged(lAccount,Account.BankAccountType__c) ||
                    TriggerCheck.isChanged(lAccount,Account.OptingForSimple__c) ||
                    TriggerCheck.isChanged(lAccount,Account.MunicipalRegistration__c) ||
                    TriggerCheck.isChanged(lAccount,Account.PIS_NIT__c) ||
                    TriggerCheck.isChanged(lAccount,Account.AnnualGrossRevenue__c) ||
                    TriggerCheck.isChanged(lAccount,Account.OperationalPhone__c) ||
                    TriggerCheck.isChanged(lAccount,Account.Email__c) ||
                    TriggerCheck.isChanged(lAccount,Account.UseChart__c) ||
                    TriggerCheck.isChanged(lAccount,Account.DigitAgency__c) ||
                    TriggerCheck.isChanged(lAccount,Account.EffectiveDate__c) ||
                    TriggerCheck.isChanged(lAccount,Account.PatrimonyLiquid__c) ||
                    TriggerCheck.isChanged(lAccount,Account.DeliveryPublicPlace__c) ||
                    TriggerCheck.isChanged(lAccount,Account.DeliveryStreet__c) ||
                    TriggerCheck.isChanged(lAccount,Account.DeliveryNumber__c) ||
                    TriggerCheck.isChanged(lAccount,Account.DeliveryComplement__c) ||
                    TriggerCheck.isChanged(lAccount,Account.DeliveryNeighborhood__c) ||
                    TriggerCheck.isChanged(lAccount,Account.DeliveryCity__c) ||
                    TriggerCheck.isChanged(lAccount,Account.DeliveryUf__c) ||
                    TriggerCheck.isChanged(lAccount,Account.DeliveryZip__c) ||
                    TriggerCheck.isChanged(lAccount,Account.Phone) ||
                    TriggerCheck.isChanged(lAccount,Account.Analyst__c) ||
                    TriggerCheck.isChanged(lAccount,Account.ContractType__c) ||
                    TriggerCheck.isChanged(lAccount,Account.GroupCompanies__c) ||
                    TriggerCheck.isChanged(lAccount,Account.Attend24h__c) ||
                    TriggerCheck.isChanged(lAccount,Account.HaveParking__c) ||
                    TriggerCheck.isChanged(lAccount,Account.ActuationType__c) ||
                    TriggerCheck.isChanged(lAccount,Account.QuantityService__c) ||
                    TriggerCheck.isChanged(lAccount,Account.QuantityResources__c) ||
                    TriggerCheck.isChanged(lAccount,Account.OperationalZip__c) ||
                    TriggerCheck.isChanged(lAccount,Account.OperationalComplement__c) ||
                    TriggerCheck.isChanged(lAccount,Account.OperationalCity__c) ||
                    TriggerCheck.isChanged(lAccount,Account.OperationalUf__c) ||
                    TriggerCheck.isChanged(lAccount,Account.OperationalNeighborhood__c) ||                    
                    TriggerCheck.isChanged(lAccount,Account.OperationalStreet__c) ||
                    TriggerCheck.isChanged(lAccount,Account.BillingLatitude) ||
                    TriggerCheck.isChanged(lAccount,Account.BillingLongitude) || 
                    TriggerCheck.isChanged(lAccount,Account.SucursalCode__c) ||     
                    TriggerCheck.isChanged(lAccount,Account.OperationalNumber__c) ||
                    TriggerCheck.isChanged(lAccount,Account.PaymentMethod__c) ||
                    TriggerCheck.isChanged(lAccount,Account.Status__c) ||
                    
                    
                    //Trecho abaixo verifica se mudou qualquer info de endereço fiscal, com exceção da cidade e estado. Porque se mudar cidade e estado, há uma trigger que chama a integração da Sucursal, evitando duas chamadas. 
                    (TriggerCheck.isChanged(lAccount,Account.TaxPublicPlace__c) ||
                    TriggerCheck.isChanged(lAccount,Account.TaxStreet__c) ||
                    TriggerCheck.isChanged(lAccount,Account.TaxNumber__c) ||
                    TriggerCheck.isChanged(lAccount,Account.TaxComplement__c) ||
                    TriggerCheck.isChanged(lAccount,Account.TaxNeighbourhood__c) ||
                    TriggerCheck.isChanged(lAccount,Account.TaxZIP__c) && 
                    (!TriggerCheck.isChanged(lAccount,Account.TaxCity__c) &&
                    !TriggerCheck.isChanged(lAccount,Account.TaxUf__c))))){ 
                    
                lAccountToIntegrateMap.put(lAccount.Id,lAccount);
            }
        }
        if(lAccountToIntegrateMap.isEmpty()) return null;

        SpecialtyWrapper_cls lAccountSpecialtyWr = new SpecialtyWrapper_cls(lAccountToIntegrateMap.values());

        // Monta um map de Id de Prestador com lista de Sócios
        lAccountSpecialtyWr.fPartnersMap = new Map<Id,List<SpecialtyWrapper_cls.AccountContactRelation>>();
        for(AccountContactRelation lAccCtRelation :[SELECT AccountId, ContactId, Contact.Code__c, Contact.Name, Contact.CPF__c, Contact.PEP__c FROM AccountContactRelation 
                WHERE AccountId IN :lAccountToIntegrateMap.keySet() AND Contact.RecordType.DeveloperName = :Label.PartnerRecordType ORDER BY PercentageParticipation__c DESC]) {
                    system.debug('lAccCtRelation ------------------------------------------------> ' + lAccCtRelation);
            
            List<SpecialtyWrapper_cls.AccountContactRelation> lPartnerLst = lAccountSpecialtyWr.fPartnersMap.get(lAccCtRelation.AccountId);
            if(lPartnerLst == null){
                lPartnerLst = new List<SpecialtyWrapper_cls.AccountContactRelation>();
                lAccountSpecialtyWr.fPartnersMap.put(lAccCtRelation.AccountId,lPartnerLst);
            }

            lPartnerLst.add(new SpecialtyWrapper_cls.AccountContactRelation(
                lAccCtRelation.Contact.Code__c != null?String.valueOf(lAccCtRelation.Contact.Code__c):null, 
                lAccCtRelation.Contact.Name, 
                lAccCtRelation.Contact.CPF__c,
                lAccCtRelation.Contact.PEP__c
            ));
        }
        
        // Busca todas as Habilidades dos Prestadores 
        
        Map<Id,Map<Id,Account>> lAbilityAccountMap = new Map<Id,Map<Id,Account>>();
        for(EquipmentSupplyPart__c lAbility :[SELECT Abiliity__c, Provider__c, Abiliity__r.Code__c FROM EquipmentSupplyPart__c WHERE Provider__c IN :lAccountToIntegrateMap.keySet() AND Abiliity__r.Status__c = :ACTIVE AND IsActive__c = true]){

            Map<Id,Account> lAccountMap = lAbilityAccountMap.get(lAbility.Abiliity__c);
            if(lAccountMap == null) {
                lAccountMap = new Map<Id,Account>();     
                lAbilityAccountMap.put(lAbility.Abiliity__c, lAccountMap);               
            }
            if(!lAccountMap.containsKey(lAbility.Provider__c)) {
                lAccountMap.put(lAbility.Provider__c, lAccountToIntegrateMap.get(lAbility.Provider__c));
            }

            List<SpecialtyWrapper_cls.Habilidades> lAbilityLst = lAccountSpecialtyWr.fAbillityLstMap.get(lAbility.Provider__c);
            if (lAbilityLst == null) {
                lAbilityLst = new List<SpecialtyWrapper_cls.Habilidades>();
                lAccountSpecialtyWr.fAbillityLstMap.put(lAbility.Provider__c, lAbilityLst);
            }
            SpecialtyWrapper_cls.Habilidades lHabilidade = new SpecialtyWrapper_cls.Habilidades();
            lHabilidade.CodigoHabilidade = lAbility.Abiliity__r.Code__c!=null?Integer.valueOf(lAbility.Abiliity__r.Code__c):null;
            lAbilityLst.add(lHabilidade);
        } 

        if(lAbilityAccountMap.isEmpty()) return lAccountSpecialtyWr;


        // Monta um map de Id de Habilidade com suas Especialidades
        Map<Id,List<SpecialtyWrapper_cls.Especialidades>> lAbilitySpecialtyLstMap = new Map<Id,List<SpecialtyWrapper_cls.Especialidades>>();
        Set<Decimal> lSpecialtyDuplicated = new Set<Decimal>();
        for(Ability__c lAbility :[SELECT Product2__r.Code__c, Product2__r.SpecialtyType__c, OperationalSetup__c FROM Ability__c 
        WHERE Product2__r.Status__c = :ACTIVE AND IsActive__c = true AND OperationalSetup__c IN :lAbilityAccountMap.keySet()]){
            
            List<SpecialtyWrapper_cls.Especialidades> lSpecialtyLst = lAbilitySpecialtyLstMap.get(lAbility.OperationalSetup__c);
            if(lSpecialtyLst == null) {
                lSpecialtyLst = new List<SpecialtyWrapper_cls.Especialidades>();
                lAbilitySpecialtyLstMap.put(lAbility.OperationalSetup__c, lSpecialtyLst);
            }
            if(!lSpecialtyDuplicated.contains(lAbility.Product2__r.Code__c)){
                SpecialtyWrapper_cls.Especialidades lEspecialidade = new SpecialtyWrapper_cls.Especialidades();
                lEspecialidade.Segmento = lAbility.Product2__r.SpecialtyType__c;
                lEspecialidade.CodigoEspecialidade = lAbility.Product2__r.Code__c!=null?Integer.valueOf(lAbility.Product2__r.Code__c):null;
                lSpecialtyLst.add(lEspecialidade);
                lSpecialtyDuplicated.add(lAbility.Product2__r.Code__c);
            }                         
        }
        if(lAbilitySpecialtyLstMap.isEmpty()) return lAccountSpecialtyWr;        

        
        
        // Monta um map de Id de Prestador com suas Especialidades
        for(Id lAbilityId :lAbilityAccountMap.keySet()) {
            List<SpecialtyWrapper_cls.Especialidades> lSpecialtyLst = lAbilitySpecialtyLstMap.get(lAbilityId);
            if(lSpecialtyLst != null) {
                Map<Id,Account> lAccountMap = lAbilityAccountMap.get(lAbilityId);
                if(lAccountMap != null) {
                    for(Account lAccount :lAccountMap.values()) {
                        List<SpecialtyWrapper_cls.Especialidades> lSpecialtyAccountLst = lAccountSpecialtyWr.fSpecialtyLstMap.get(lAccount.Id);
                        if(lSpecialtyAccountLst == null) {
                            lSpecialtyAccountLst = new List<SpecialtyWrapper_cls.Especialidades>();
                            lAccountSpecialtyWr.fSpecialtyLstMap.put(lAccount.Id, lSpecialtyAccountLst);
                        }
                        lSpecialtyAccountLst.addAll(lSpecialtyLst);
                    }
                }
            }
        }

        // Busca todos os Equipamentos dos Prestadores
        Map<Id,Map<Id,Account>> lEquipamentAccountMap = new Map<Id,Map<Id,Account>>();
        system.debug('############################################################################################################### teste map equipamento: '+ lAccountToIntegrateMap);
        for(ProviderEquipment__c lEquipament :[SELECT Equipment__c, Provider__c, Equipment__r.Code__c FROM ProviderEquipment__c WHERE Provider__c IN :lAccountToIntegrateMap.keySet() AND Equipment__r.Status__c = :ACTIVE AND IsActive__c = true]){
            Map<Id,Account> lAccountMap = lEquipamentAccountMap.get(lEquipament.Equipment__c);
            if(lAccountMap == null) {
                lAccountMap = new Map<Id,Account>();     
                lEquipamentAccountMap.put(lEquipament.Equipment__c, lAccountMap);               
            }
            if(!lAccountMap.containsKey(lEquipament.Provider__c)) {
                lAccountMap.put(lEquipament.Provider__c, lAccountToIntegrateMap.get(lEquipament.Provider__c));
            }
            List<SpecialtyWrapper_cls.Equipamentos> lEquipamentLst = lAccountSpecialtyWr.fEquipmentLstMap.get(lEquipament.Provider__c);
            if (lEquipamentLst == null) {
                lEquipamentLst = new List<SpecialtyWrapper_cls.Equipamentos>();
                lAccountSpecialtyWr.fEquipmentLstMap.put(lEquipament.Provider__c, lEquipamentLst);
            }
            SpecialtyWrapper_cls.Equipamentos lEquipamento = new SpecialtyWrapper_cls.Equipamentos();
            lEquipamento.CodigoEquipamento = lEquipament.Equipment__r.Code__c!=null?Integer.valueOf(lEquipament.Equipment__r.Code__c):null;
            lEquipamentLst.add(lEquipamento);
        } 

        // Busca todos os Equipamentos dos veículos dos Prestadores
        Map<Id,Map<Id,Account>> lVehicleAccountMap = new Map<Id,Map<Id,Account>>();
        for(EquipamentVehicle__c lEquipament :[SELECT Vehicle__c, Equipament__c, Equipament__r.Code__c, Provider__c FROM EquipamentVehicle__c WHERE Provider__c IN :lAccountToIntegrateMap.keySet() AND VehicleStatus__c = :ACTIVE AND IsActive__c = true AND Equipament__c NOT IN :lEquipamentAccountMap.keySet()]){
            Map<Id,Account> lAccountMap = lVehicleAccountMap.get(lEquipament.Equipament__c);
            if(lAccountMap == null) {
                lAccountMap = new Map<Id,Account>();     
                lVehicleAccountMap.put(lEquipament.Equipament__c, lAccountMap);               
            }
            if(!lAccountMap.containsKey(lEquipament.Provider__c)) {
                lAccountMap.put(lEquipament.Provider__c, lAccountToIntegrateMap.get(lEquipament.Provider__c));
            }
            List<SpecialtyWrapper_cls.Equipamentos> lEquipamentLst = lAccountSpecialtyWr.fEquipmentLstMap.get(lEquipament.Provider__c);
            if (lEquipamentLst == null) {
                lEquipamentLst = new List<SpecialtyWrapper_cls.Equipamentos>();
                lAccountSpecialtyWr.fEquipmentLstMap.put(lEquipament.Provider__c, lEquipamentLst);
            }
            SpecialtyWrapper_cls.Equipamentos lEquipamento = new SpecialtyWrapper_cls.Equipamentos();
            lEquipamento.CodigoEquipamento = lEquipament.Equipament__r.Code__c!=null?Integer.valueOf(lEquipament.Equipament__r.Code__c):null;
            lEquipamentLst.add(lEquipamento);
        }
        
        return lAccountSpecialtyWr;
    }
}