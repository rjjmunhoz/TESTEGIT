/**************************************************************************************************************
* Globant Brasil
* @author        	Matheus Branco (matheus.branco@globant.com)
* Project:          Porto Socorro
* Description:      Classe de teste para cobrir os cenários da classe CaseHandler e CreateChildrenCaseHandler
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2019-11-07      Matheus Branco          class created 
**************************************************************************************************************/
@isTest
public class CaseFactory {
    
    private static Map<String, Case> fStaticRecord = new Map<String, Case>();

//----------------------------------------------Prototipação-----------------------------------------
    
    public static Case createCasePrototyping(){ 
        if(!fStaticRecord.containsKey(Label.PrototypingRecordType)){
            Id PrototypingRecType = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.PrototypingRecordType).getRecordTypeId();
			
            User lUser = UserFactory.createUser();
            
            fStaticRecord.put(Label.PrototypingRecordType, new Case(
                RecordTypeId = PrototypingRecType,
                Requester__c = lUser.Id,
                RequesterText__c = 'Prototipar uma especialidade',
                ItemToBePrototyped__c = 'Especialidade',
                ItemName__c = 'teste',
                EquipamentList__c = 'Não Aplicado',
                SpecialtyList__c = 'Novo',
                SpecialtyDescription__c = 'Preciso de uma nova especialidade',
                InsumoList__c = 'Não Aplicado',
                ModalList__c = 'Não Aplicado',
                ReasonList__c = 'Não Aplicado',
                PartList__c = 'Não Aplicado',
                GMVList__c = 'Não Aplicado',
                CloseOrderItemList__c = 'Não Aplicado',
                AbilityList__c = 'Não Aplicado',
                ServiceList__c = 'Não Aplicado',
                OperationalServiceList__c = 'Não Aplicado',
                CloseOrderList__c = 'Não Aplicado',
                ProviderList__c = 'Não Aplicado',
                Description = 'teste',
                PriceExpectation__c = 1,
                POCStartDate__c = System.today(),
                POCEndDate__c = System.today() + 1
                //Service__c = aService.Id
            ));
        }
        return fStaticRecord.get(Label.PrototypingRecordType);
    }
//----------------------------------------------ANÁLISE DE PORTFÓLIO-----------------------------------------
    
    public static Case createCasePortfolioAnalysis(Product2 aService){ 
        if(!fStaticRecord.containsKey(Label.PortfolioAnalysisRecordType)){
            Id PortfolioAnalysisRecType = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.PortfolioAnalysisRecordType).getRecordTypeId();

            fStaticRecord.put(Label.PortfolioAnalysisRecordType, new Case(
                RecordTypeId = PortfolioAnalysisRecType,
                NewEquipmentRequired__c = true,
                Equipment__c = 'Equipamento',
                ObjectiveEquipmentEvaluation__c = 'Redução de custo',
                Ability__c = 'Não será avaliado(a)',
                Parts__c = 'Não será avaliado(a)',
                Problem__c = 'Não será avaliado(a)',
                Modal__c = 'Não será avaliado(a)',
                VehicleTypeGroup__c = 'Não será avaliado(a)',
                CloseOrder__c = 'Não será avaliado(a)',
                CloseOrderItem__c = 'Não será avaliado(a)',
                OperationalService__c = 'Não será avaliado(a)',
                Specialty__c = 'Não será avaliado(a)',
                POCStartDate__c = System.today(),
                POCEndDate__c = System.today() + 1,
                AmountServiceAnalyzed__c = 123,
                Seem__c = 'Cool',
                Service__c = aService.Id
            ));
        }
        return fStaticRecord.get(Label.PortfolioAnalysisRecordType);
    }

    public class PortfolioAnalysis extends SObjectFactory {

    	public PortfolioAnalysis() {
			this(
				(Product2) new Product2Factory.Service().createRecord()
			);
		}

        public PortfolioAnalysis(Product2 aService){
            super(createCasePortfolioAnalysis(aService));
        }
    }

//----------------------------------------------REQUISITOS DA POC-----------------------------------------

    public static Case createCasePocRequirements(Case aCase){
        if(!fStaticRecord.containsKey(Label.POCRequirementsRecordType)){
            Id PocRequirementsRecType = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.POCRequirementsRecordType).getRecordTypeId();

            fStaticRecord.put(Label.POCRequirementsRecordType, new Case(
                RecordTypeId = PocRequirementsRecType,
                POCRequirements__c = 'Objetivo da POC',
                ExpectedOutcome__c = 'Resultado esperado',
                //POCOutcome__c = 'Resultado final',
                ParentId = aCase.Id
            ));
        }
        return fStaticRecord.get(Label.POCRequirementsRecordType);
    }

    public class PocRequirements extends SObjectFactory {

        public PocRequirements(Case aCase){
            super(createCasePocRequirements(aCase));
        }
    }

//----------------------------------------------AMPLIAÇÃO DE SERVIÇO-----------------------------------------

    public static Case createCaseServiceMagnification(Product2 aService){ 
        if(!fStaticRecord.containsKey(Label.ServiceMagnificationRecordType)){
            Id ServiceMagnificationRecType = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.ServiceMagnificationRecordType).getRecordTypeId();

            fStaticRecord.put(Label.ServiceMagnificationRecordType, new Case(
                RecordTypeId = ServiceMagnificationRecType,
                Segment__c = 'Automóvel',
                ServicedNewService__c = 'Carro',
                ServiceAllocationLine__c = 'Assistência',
                ServiceProvidedTo__c = 'Segurado',
                ExpectationMinimalProjection__c = 12,
                MonthlyGrowthExpectation__c = 2,
                GrowthReason__c = 'Motivação',
                GrowthValue__c = 12,
                GrowthStartDate__c = Date.newInstance(2020,12,12),
                Region__c = 'Central',
                MonitoringZone__c = 'Zona de monitoramento',
                Note__c = 'Observação',
                ProjectedAnnualAmountServices__c = 123,
                InitialTerm__c = Date.newInstance(2020,12,10),
                FinalTerm__c = Date.newInstance(2012,12,12),
                ManyResourcesNeeded__c = 123,
                NeedExtendNetwork__c = true,
                HaveChanged__c = true,
                Description = 'Descrição',
                Term__c = '5 dias',
                Service__c = aService.Id
            ));
        }
        return fStaticRecord.get(Label.ServiceMagnificationRecordType);
    }
    
    public class ServiceMagnification extends SObjectFactory {

        public ServiceMagnification() {
			this(
				(Product2) new Product2Factory.Service().createRecord()
			);
		}

        public ServiceMagnification(Product2 aService){
            super(createCaseServiceMagnification(aService));
        }
    }

//----------------------------------------------RETIRADA DE SERVIÇO-----------------------------------------

    public static Case createCaseRemoveService(Product2 aService){
        if(!fStaticRecord.containsKey(Label.RemoveServiceRecordType)){
            Id RemoveServiceRecType = SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RemoveServiceRecordType).getRecordTypeId();

            fStaticRecord.put(Label.RemoveServiceRecordType, new Case(
                RecordTypeId = RemoveServiceRecType,
                Segment__c = 'Chaveiro',
                RegionSizing__c = 'Região',
                MonitoringZone__c = 'Monitoramento',
                EndDateMarketing__c = Date.newInstance(2020,12,12),
                Region__c = 'Região',
                Specialty__c = 'Não será avaliado(a)',
                Modal__c = 'Não será avaliado(a)',
                Justification__c = 'Justificativa', //se der ruim, tira esse campo
                Service__c = aService.Id
            ));
        }
        return fStaticRecord.get(Label.RemoveServiceRecordType);
    }

    public class RemoveService extends SObjectFactory{

        public RemoveService(){
            this(
                (Product2) new Product2Factory.Service().createRecord()
            );
        }

        public RemoveService(Product2 aService){
            super(createCaseRemoveService(aService));
        }
    }

//----------------------------------------------ANEXO-----------------------------------------

    public static ContentDocumentLink createAttachment(Case aLinkedEntity){

        ContentVersion lContentVersion1 = new ContentVersion();
        lContentVersion1.Title = 'Text';
        lContentVersion1.PathOnClient = 'Text.txt';
        lContentVersion1.VersionData = Blob.valueOf('Test Content');
        lContentVersion1.IsMajorVersion = true;
        insert lContentVersion1;        

        ContentDocument lContentDoc1 = new ContentDocument();
        lContentDoc1 = [SELECT Id FROM ContentDocument  WHERE Title = 'Text'];      

        ContentDocumentLink  lDocLink = new ContentDocumentLink();
        lDocLink.contentdocumentId = lContentDoc1.Id;
        lDocLink.LinkedEntityId = aLinkedEntity.Id;
        lDocLink.ShareType = 'V';       

        return lDocLink;
    }
}