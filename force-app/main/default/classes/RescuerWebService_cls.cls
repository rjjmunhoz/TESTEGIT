/**************************************************************************************************************
* Globant Brasil
* @author        	Mariana Ribeiro (mariana.ribeiro@globant.com)
* Project:          Porto Socorro
* Description:      Classe para consumo do WebService de Socorrista
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-05-08      Mariana Ribeiro          class created 
**************************************************************************************************************/
public without sharing class RescuerWebService_cls extends AWS_API{
	private static final String RESCUER = Label.RoleRescuer;
	private static final String ACTIVE = Label.Status_Active;
    // NECESSÁRIO LEVANTAR COM NEGÓCIO QUAL VALOR ENVIAR QUANDO O REGISTRO FOR INATIVO, POIS NÃO EXISTE INATIVO NO LEGADO. ESTAMOS ENVIANDO 3 QUE É IGUAL AO CANCELADO APENAS PARA TESTES
    /*private static final Map<String,Integer> statusMap = new Map<String,Integer>{
        'Ativo' => 1,
        'Inativo' => 2, // não existe no legado
        'Em implantação' => 4, // Canditato
        'Bloqueado' => 2,
        'Cancelado' => 3
    };*/

    private static final Map<String,Integer> statusMap {
        get {
            if(statusMap != null) {
                return statusMap;
            }
            else {
                statusMap = new Map<String,Integer>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'RescuerStatus' AND IsActive__c = true]) {
                    statusMap.put(lLegacyDomainTableValue.Key__c, Integer.valueOf(lLegacyDomainTableValue.Value__c));
                }
                return statusMap;
            }            
        }
        set;
    }
    
    /*private static final Map<String,Integer> statusRadarMap = new Map<String,Integer>{
        'Aguardando Radar' => 4,
        'B' => 3, //BLOQUEADO
        'L' => 1, //LIBERADO
        null => 2 
    };*/

    private static final Map<String,Integer> statusRadarMap {
        get {
            if(statusRadarMap != null) {
                return statusRadarMap;
            }
            else {
                statusRadarMap = new Map<String,Integer>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'RescuerRadarStatus' AND IsActive__c = true]) {
                        statusRadarMap.put(lLegacyDomainTableValue.Key__c, Integer.valueOf(lLegacyDomainTableValue.Value__c));
                }
                return statusRadarMap;
            }            
        }
        set;
    }
    
    /*private static final Map<String,Integer> statusCargoMap = new Map<String,Integer>{
        'Administrativo' => 6,
        'Ajudante' => 4,
        'Aprendiz' => 3,
        'Gestor' => 5,
        'Gestor Operacional' => 1,
        'Socorrista' => 2
    };*/

    private static final Map<String,Integer> statusCargoMap {
        get {
            if(statusCargoMap != null) {
                return statusCargoMap;
            }
            else {
                statusCargoMap = new Map<String,Integer>();
                for(LegacyDomainTableValue__mdt lLegacyDomainTableValue :[SELECT Key__c, Value__c FROM LegacyDomainTableValue__mdt 
                        WHERE Domain__c = 'RescuerPosition' AND IsActive__c = true]) {
                        statusCargoMap.put(lLegacyDomainTableValue.Key__c, Integer.valueOf(lLegacyDomainTableValue.Value__c));
                }
                return statusCargoMap;
            }            
        }
        set;
    }

    public Integer CodigoTipoRegistroSF;
    public Integer CoditoTipoSocorristaCia;
    public Integer CodigoSocorrista;
    public Integer PesCod;
    public String NomeSocorrista;
    public Integer Status;
    public DadosPessoais DadosPessoais; 
    public DadosInsumo DadosInsumo;
    public DadosOperacionais DadosOperacionais;
    public DadosAnalise DadosAnalise;
    public DadosSistema DadosSistema; 
    public Endereco Endereco;
    public Prestador Prestador;
    public List<SpecialtyWrapper_cls.Especialidades> Especialidades;
    public List<SpecialtyWrapper_cls.Habilidades> Habilidades;

    public class DadosPessoais {
        String NumeroCpf;
        String NumeroRG;
        String CodigoUnidadeFederacaoRG;
        Date DataNascimento;
        String NomePai;
        String NomeMae;
        String NomeConjuge;
        String Nacionalidade;
        String Naturalidade;
        String Genero;
        Integer EstadoCivil;
        String Email;
        String NumeroTelefoneCelular;
    }  

    public class DadosInsumo {
        Decimal AlturaPessoa;
        Integer PesoPessoa;
        String NumeroCamisa;
        Integer NumeroCalca;
        Integer NumeroCalcado;
    }  

    public class DadosOperacionais{
        String NumeroCNH;
        List<String> CategoriaCNH;
        Date DataPrimeiraCNH;
        Date DataVencimentoExameMedico;
        String NomeParenteNaCia;
        Integer NumeroCarteiraProfissional;
        Integer NumeroSerieCarteiraProfissional;
        String CodigoUnidadeFedaracaoCarteiraProfissional;
    }

    public class DadosAnalise{
        Decimal CodigoSituacaoAnaliseRadar;
        Datetime DataUltimaAnaliseRadar;
        //Datetime DataUltimaAnaliseRadar;
        Decimal CodigoSituacaoAnalisePortoSocorro;
    }

    public class DadosSistema{
        Datetime DataCadastro;
        String UsuarioCadastro;
        Datetime DataAtualizacao;
        String UsuarioAtualizacao;
    }

    public class Endereco{
        Integer CodigoSocorrista;
        String TipoLogradouro;
        String Logradouro;
        String ComplementoLogradouro;
        String Numero;
        String PontoReferencia;
        String Observacao;
        String Bairro;
        String Cidade;
        String UF;
        String CEP;
        String NumeroTelefone;
    }

    public class Prestador{
        Integer CodigoSocorrista;
        Integer CodigoPrestador;
        List<String> TipoContrato;
        Date DataInicioVigencia;
        Date DataFimVigencia;
        Integer CodigoTipoVinculo;
    }

    public RescuerWebService_cls(Integer aTest) {
        super('Teste');
        system.debug('Teste ' + JSON.serialize(statusMap));
    }
    
    public RescuerWebService_cls(SObject aRescuer, List<SpecialtyWrapper_cls.Especialidades> aContactSpecialtyLst,List<SpecialtyWrapper_cls.Habilidades> aContactAbilityLst, SpecialtyWrapper_cls.AccountContactRelation aAccountContactRelation) {
        super(RESCUER);        
        Contact lContact = (Contact)aRescuer;
        Integer lQRA = lContact.QRA__c!=null?Integer.valueOF(lContact.QRA__c):null;
        this.CodigoTipoRegistroSF = 1;
        this.CoditoTipoSocorristaCia = 1;
        this.CodigoSocorrista = lQRA;
        this.PesCod = lContact.PesCod__c!=null?Integer.valueOF(lContact.PesCod__c):null;
        this.NomeSocorrista = (String.isBlank(lContact.FirstName)?'': (lContact.FirstName + ' ')) + lContact.LastName ;
        this.Status = statusMap.get(lContact.Status__c);

        this.DadosPessoais = new DadosPessoais();
        this.DadosPessoais.NumeroCpf = lContact.CPF__c;
        this.DadosPessoais.NumeroRG = lContact.RG__c;
        this.DadosPessoais.CodigoUnidadeFederacaoRG = 'SP'; // veriificar depois se é esse campo IssuingAgency__c
        this.DadosPessoais.DataNascimento = lContact.Birthdate;
        this.DadosPessoais.NomePai = lContact.FatherName__c;
        this.DadosPessoais.NomeMae = lContact.MotherName__c;
        this.DadosPessoais.NomeConjuge = null;
        this.DadosPessoais.Nacionalidade = lContact.Nationality__c;
        this.DadosPessoais.Naturalidade = lContact.UF__c;
        this.DadosPessoais.Genero = lContact.Gender__c;
        this.DadosPessoais.EstadoCivil = lContact.MaritalStatus__c!=null?Integer.valueOf(lContact.MaritalStatus__c):null;
        this.DadosPessoais.Email = lContact.Email;
        this.DadosPessoais.NumeroTelefoneCelular = lContact.MobilePhone;

        this.DadosInsumo = new DadosInsumo();
        this.DadosInsumo.AlturaPessoa = lContact.Height__c!=null?lContact.Height__c:0; 
        this.DadosInsumo.PesoPessoa = lContact.Weight__c!=null?Integer.valueOf(lContact.Weight__c):0; 
        this.DadosInsumo.NumeroCamisa = String.isNotBlank(lContact.Shirt__c)?lContact.Shirt__c:Label.String_G;
        this.DadosInsumo.NumeroCalca = lContact.Pants__c!=null?Integer.valueOf(lContact.Pants__c):0;
        this.DadosInsumo.NumeroCalcado = lContact.Boot__c!=null?Integer.valueOf(lContact.Boot__c):0;        

        this.DadosAnalise = new DadosAnalise();
        this.DadosAnalise.CodigoSituacaoAnaliseRadar = statusRadarMap.get(lContact.StatusRadar__c);
        this.DadosAnalise.DataUltimaAnaliseRadar = lContact.RadarReturnDate__c;
        //this.DadosAnalise.DataUltimaAnaliseRadar = lContact.RadarShippingDate__c;
        this.DadosAnalise.CodigoSituacaoAnalisePortoSocorro = 2; // Dependendo do processo de analise de seleção, este campo recebe o valor de aprovação da seleção

        this.DadosSistema = new DadosSistema();
        this.DadosSistema.DataCadastro = lContact.CreatedDate;
        this.DadosSistema.UsuarioCadastro = lContact.CreatorFederationIdentifier__c;
        this.DadosSistema.DataAtualizacao = system.now();
        this.DadosSistema.UsuarioAtualizacao = lContact.ModifierFederationIdentifier__c;

        this.Endereco = new Endereco();
        this.Endereco.CodigoSocorrista = lQRA;
        this.Endereco.TipoLogradouro = lContact.PublicPlace__c;
        this.Endereco.Logradouro = lContact.Street__c;
        this.Endereco.ComplementoLogradouro = lContact.Complement__c;
        this.Endereco.Numero = lContact.Number__c;
        this.Endereco.PontoReferencia = null;
        this.Endereco.Observacao = null;
        this.Endereco.Bairro = lContact.Neighborhood__c;
        this.Endereco.Cidade = lContact.City__c.toUpperCase();
        this.Endereco.UF = lContact.Uf__c;
        this.Endereco.CEP = lContact.Zip__c;
        this.Endereco.NumeroTelefone = lContact.HomePhone;

        String lContractType;
        this.Prestador = new Prestador();
        this.Prestador.CodigoSocorrista = lQRA;
        this.Prestador.CodigoPrestador = lContact.CompanyCode__c!=null?Integer.valueOf(lContact.CompanyCode__c):null; 
        this.Prestador.CodigoTipoVinculo = statusCargoMap.get(lContact.Role__c);  
        if(aAccountContactRelation != null) {
            this.Prestador.DataInicioVigencia = aAccountContactRelation.startDate;
            this.Prestador.DataFimVigencia = aAccountContactRelation.endDate;        
            this.Prestador.TipoContrato = (String.isNotBlank(aAccountContactRelation.contractType)?aAccountContactRelation.contractType.split(';'):null); 
        }        
        
        this.DadosOperacionais = new DadosOperacionais();
        this.DadosOperacionais.NumeroCNH = lContact.CNHNumber__c;
        this.DadosOperacionais.CategoriaCNH = new List<String>();
        if(String.isNotBlank(lContact.CNHCategory__c)) {
            for(Integer i = 0; i < lContact.CNHCategory__c.length(); i++) {
                this.DadosOperacionais.CategoriaCNH.add(lContact.CNHCategory__c.substring(i, i+1));   
            }
        }        
        this.DadosOperacionais.DataPrimeiraCNH = lContact.DateOfFirstCNH__c; 
        this.DadosOperacionais.DataVencimentoExameMedico = lContact.CNHExpirationDate__c;
        this.DadosOperacionais.NomeParenteNaCia = null;
        this.DadosOperacionais.NumeroCarteiraProfissional = lContact.WorkRegisterBookletNumber__c!=null?Integer.valueOf(lContact.WorkRegisterBookletNumber__c):null;
        this.DadosOperacionais.NumeroSerieCarteiraProfissional = lContact.WorkRegisterBookletSeries__c!=null?Integer.valueOf(lContact.WorkRegisterBookletSeries__c):null;
        this.DadosOperacionais.CodigoUnidadeFedaracaoCarteiraProfissional = null;

        if(aContactSpecialtyLst != null) {
            for(SpecialtyWrapper_cls.Especialidades lSpecialty :aContactSpecialtyLst) {
               lSpecialty.CodigoSocorrista = lQRA;
            }
            this.Especialidades = aContactSpecialtyLst;
        }
        else {
            this.Especialidades = new List<SpecialtyWrapper_cls.Especialidades>();
        }

        if(aContactAbilityLst != null) {
            this.Habilidades = aContactAbilityLst;
        }
        else {
            this.Habilidades = new List<SpecialtyWrapper_cls.Habilidades>();
        }
    }
    public AWS_API.ResponseWrapper setAwsRescuer(){
        this.fReq.setBody(JSON.serialize(this));
		AWS_API.ResponseWrapper lResult =  this.doRequest();
		system.debug('Result.success ' + lResult);       
        return lResult;
    }

    /*
    Método que retorna um wrapper com somente socorristas que tenham ao menos um campo integravel com o legado, 
    um map de id do socorrista e suas especialidades(Ativas) e um map de id do socorrista com dados da vigência com o Prestador
    */
    public static SpecialtyWrapper_cls getContactToIntegration(List<Contact> aContactLst) {
        
        TriggerCheck.assert();        
        
        Map<Id,Contact> lContactToIntegrateMap = new Map<Id,Contact>();
        for(Contact lContact :aContactLst) {
            // Adicionados em primeiro os campos com maior chances de alteração
            if(lContact.SyncAPI__c ||
                    TriggerCheck.isChanged(lContact,Contact.Status__c) ||
                    TriggerCheck.isChanged(lContact,Contact.MobilePhone) ||
                    TriggerCheck.isChanged(lContact,Contact.HomePhone) ||
                    TriggerCheck.isChanged(lContact, Contact.Email) ||
                    TriggerCheck.isChanged(lContact, Contact.Height__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Weight__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Shirt__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Pants__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Boot__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Street__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Complement__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Number__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Neighborhood__c) ||
                    TriggerCheck.isChanged(lContact, Contact.City__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Uf__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Zip__c) ||
                    TriggerCheck.isChanged(lContact, Contact.MaritalStatus__c) ||
                    TriggerCheck.isChanged(lContact, Contact.CNHCategory__c) ||
                    TriggerCheck.isChanged(lContact, Contact.DateOfFirstCNH__c) ||
                    TriggerCheck.isChanged(lContact, Contact.CNHExpirationDate__c) ||
                    TriggerCheck.isChanged(lContact, Contact.StatusRadar__c) ||
                    TriggerCheck.isChanged(lContact, Contact.RadarReturnDate__c) ||
               		//TriggerCheck.isChanged(lContact, Contact.RadarShippingDate__c) ||
                    TriggerCheck.isChanged(lContact, Contact.RisksStatus__c) ||
                    TriggerCheck.isChanged(lContact, Contact.CompanyCode__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Role__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Gender__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Name) ||
                   // TriggerCheck.isChanged(lContact, Contact.QRA__c) || // este não é para mudar, foi colocado só por proteção
                    TriggerCheck.isChanged(lContact, Contact.Birthdate) ||
                    TriggerCheck.isChanged(lContact, Contact.CPF__c) ||
                    TriggerCheck.isChanged(lContact, Contact.RG__c) ||
                    TriggerCheck.isChanged(lContact, Contact.CNHNumber__c) ||
                    TriggerCheck.isChanged(lContact, Contact.Nationality__c) ||
                    TriggerCheck.isChanged(lContact, Contact.WorkRegisterBookletNumber__c) ||
                    TriggerCheck.isChanged(lContact, Contact.WorkRegisterBookletSeries__c)){ 
                    // Adicionar a verificação de todos os campos utilizados na integração
                    lContactToIntegrateMap.put(lContact.Id, lContact);
            }            
        }

        if(lContactToIntegrateMap.isEmpty()) return null;        

        SpecialtyWrapper_cls lContactSpecialtyWr = new SpecialtyWrapper_cls(lContactToIntegrateMap.values());
        // Monta um map de Id de Socorristas com dados da vigência com o Prestador
        for(AccountContactRelation lAccCtRelation :[SELECT StartDate, EndDate, Account.ContractType__c, ContactId FROM AccountContactRelation 
                WHERE ContactId IN :lContactToIntegrateMap.keySet() AND IsDirect = true]) {
            lContactSpecialtyWr.fAccountContactRelationMap.put(lAccCtRelation.ContactId,
                new SpecialtyWrapper_cls.AccountContactRelation(
                    lAccCtRelation.Account.ContractType__c, 
                    lAccCtRelation.StartDate, 
                    lAccCtRelation.EndDate
                )
            );
        }
        
        // Busca todas as Habilidades dos Socorristas
        Map<Id,Map<Id,Contact>> lAbilityContactMap = new Map<Id,Map<Id,Contact>>();
        for(Ability__c lAbility :[SELECT Ability__c,Ability__r.Code__c , RescuerId__c, CreatedBy.FederationIdentifier, createdDate FROM Ability__c WHERE RescuerId__c IN :lContactToIntegrateMap.keySet() AND Ability__r.Status__c = :ACTIVE AND IsActive__c = true]){
            Map<Id,Contact> lContactMap = lAbilityContactMap.get(lAbility.Ability__c);
            if(lContactMap == null) {
                lContactMap = new Map<Id,Contact>();     
                lAbilityContactMap.put(lAbility.Ability__c, lContactMap);               
            }
            if(!lContactMap.containsKey(lAbility.RescuerId__c)) {
                lContactMap.put(lAbility.RescuerId__c, lContactToIntegrateMap.get(lAbility.RescuerId__c));
            }

            List<SpecialtyWrapper_cls.Habilidades> lAbilityLst = lContactSpecialtyWr.fAbillityLstMap.get(lAbility.RescuerId__c);
            if (lAbilityLst == null) {
                lAbilityLst = new List<SpecialtyWrapper_cls.Habilidades>();
                lContactSpecialtyWr.fAbillityLstMap.put(lAbility.RescuerId__c, lAbilityLst);
            }
            SpecialtyWrapper_cls.Habilidades lHabilidade = new SpecialtyWrapper_cls.Habilidades();
            lHabilidade.CodigoHabilidade = lAbility.Ability__r.Code__c!=null?Integer.valueOf(lAbility.Ability__r.Code__c):null;
            lAbilityLst.add(lHabilidade);            
        }       

        if(lAbilityContactMap.isEmpty()) return lContactSpecialtyWr;

        // Monta um map de Id de Habilidade com suas Especialidades
        Map<Id,List<SpecialtyWrapper_cls.Especialidades>> lAbilitySpecialtyLstMap = new Map<Id,List<SpecialtyWrapper_cls.Especialidades>>();
        for(Ability__c lAbility :[SELECT Product2__r.SpecialtyType__c, Product2__r.Code__c, Product2__r.CreatedBy.FederationIdentifier, 
                Product2__r.CreatedDate, OperationalSetup__c, CreatorFederationIdentifier__c, CreatedDate 
                FROM Ability__c WHERE OperationalSetup__c = :lAbilityContactMap.keySet() 
                AND Product2__c != null AND Product2__r.Status__c = :ACTIVE AND IsActive__c = true]){
            
            List<SpecialtyWrapper_cls.Especialidades> lSpecialtyLst = lAbilitySpecialtyLstMap.get(lAbility.OperationalSetup__c);
            if(lSpecialtyLst == null) {
                lSpecialtyLst = new List<SpecialtyWrapper_cls.Especialidades>();
                lAbilitySpecialtyLstMap.put(lAbility.OperationalSetup__c, lSpecialtyLst);
            }
            SpecialtyWrapper_cls.Especialidades lEspecialidade = new SpecialtyWrapper_cls.Especialidades();
            lEspecialidade.Segmento = lAbility.Product2__r.SpecialtyType__c;
            lEspecialidade.CodigoEspecialidade = lAbility.Product2__r.Code__c!=null?Integer.valueOf(lAbility.Product2__r.Code__c):null;
            lEspecialidade.DataCadastro = lAbility.CreatedDate;
            lEspecialidade.UsuarioCadastro = lAbility.CreatorFederationIdentifier__c;
            lSpecialtyLst.add(lEspecialidade);                             
        }

        if(lAbilitySpecialtyLstMap.isEmpty()) return lContactSpecialtyWr;

        // Monta um map de Id de Socorristas com suas Especialidades
        for(Id lAbilityId :lAbilityContactMap.keySet()) {
            List<SpecialtyWrapper_cls.Especialidades> lSpecialtyLst = lAbilitySpecialtyLstMap.get(lAbilityId);
            if(lSpecialtyLst != null) {
                Map<Id,Contact> lContactMap = lAbilityContactMap.get(lAbilityId);
                if(lContactMap != null) {
                    for(Contact lContact :lContactMap.values()) {
                        List<SpecialtyWrapper_cls.Especialidades> lSpecialtyContactLst = lContactSpecialtyWr.fSpecialtyLstMap.get(lContact.Id);
                        if(lSpecialtyContactLst == null) {
                            lSpecialtyContactLst = new List<SpecialtyWrapper_cls.Especialidades>();
                            lContactSpecialtyWr.fSpecialtyLstMap.put(lContact.Id, lSpecialtyContactLst);
                        }
                        lSpecialtyContactLst.addAll(lSpecialtyLst);
                    }
                }
            }
        }
        return lContactSpecialtyWr;
    }    

    public class ContactSpecialtyWrapper {
        public List<Contact> contactLst;
        public Map<Id,List<SpecialtyWrapper_cls.Especialidades>> contactSpecialtyLstMap;
        public ContactSpecialtyWrapper(List<Contact> aContactLst) {
            this.contactLst = aContactLst;
            this.contactSpecialtyLstMap = new Map<Id,List<SpecialtyWrapper_cls.Especialidades>>();
        }
    }
    public class ContactAbilityWrapper{
        public List<Contact> contactLst;
        public Map<Id,List<SpecialtyWrapper_cls.Habilidades>> contactAbilityLstMap;
        public ContactAbilityWrapper(List<Contact> aContactLst) {
            this.contactLst = aContactLst;
            this.contactAbilityLstMap = new Map<Id,List<SpecialtyWrapper_cls.Habilidades>>();
        }
    }
    
    public static void setRescuerToSynchronize(Set<Id> aAbilityIdSet) {
        List<Contact> lContactLst = new List<Contact>();
        for(Aggregateresult lAr :[SELECT RescuerId__c socorrista FROM Ability__c WHERE Ability__c IN :aAbilityIdSet AND RescuerId__c != null GROUP BY RescuerId__c]){
            lContactLst.add(new Contact(Id = (Id)lAr.get('socorrista'), SyncAPI__c = true));
        } 
        if(!lContactLst.isEmpty()) update lContactLst;
    }
}