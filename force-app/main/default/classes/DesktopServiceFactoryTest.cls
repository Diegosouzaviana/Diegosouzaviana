@IsTest
public class DesktopServiceFactoryTest {
    @TestSetup
    public static void setup(){
        try {

            
            vlocity_cmt__ObjectClass__c obj = new 
            vlocity_cmt__ObjectClass__c();
            obj.Name = 	
            'Plano Desktop';
            obj.vlocity_cmt__ObjectApiName__c = 'Product2';
            insert obj;

            System.debug('obj ->' + obj);
            if(obj.id == null || String.valueOf(obj.id) == '' ){
                obj = [SELECT id FROM vlocity_cmt__ObjectClass__c WHERE Name = 'Plano Desktop' LIMIT 1];
            }


            Product2 prod2 = createProduct2(obj);
            List<WorkType> wts = new List<WorkType>();
            wts = createWorkType();
            /*
            * Não teve cobertura
            WorkPlanTemplate wp = createPlanTemplate();
            List<WorkStepTemplate> ws = createStepTemplate();
            createPlanEntry(wp,ws);
            createPlanRule(wp, wts);*/

            Account acc = new Account(
                Name = 'New Account Name',
                CNPJ__c = '49401667000195',
                LXD_CPF__c = '40094880000',
                LXD_Email__c='teste@gmail.com',
                BillingStreet = 'R. Dr. Marcos Antonio Samartine, 99',
                LXD_NewAddressComplement__c = null,
                BillingPostalCode = '13.067-450',
                LXD_AddressNeighborhood__c = 'Nucleo Habitacional Boa Vista',
                BillingCity = 'Campinas',
                BillingState = 'SP',
                ShippingStreet = 'Rua Carioba',
                LXD_AddressNumber__c = '99', 
                ShippingPostalCode = '13472560',
                ShippingCity = 'Americana',
                ShippingState = 'SP'
            );
            insert acc;

            List<Contract> listCon = new List<Contract>();
            Contract contract = new Contract();
            contract.vlocity_cmt__ContractReferenceNumber__c = '236598856';
            contract.IdPromocao__c = 1230;
            contract.AccountId = acc.Id;
            listCon.add(contract);

            Contract contract2 = new Contract();
            contract2.vlocity_cmt__ContractReferenceNumber__c = '000000001';
            contract2.IdPromocao__c = 1230;
            contract2.AccountId = acc.Id;
            listCon.add(contract2);
            
            Contract contract3 = new Contract();
            contract3.vlocity_cmt__ContractReferenceNumber__c = '000000002';
            contract3.IdPromocao__c = 1230;
            contract3.AccountId = acc.Id;
            listCon.add(contract3);
            
            Contract contract4 = new Contract();
            contract4.vlocity_cmt__ContractReferenceNumber__c = '000000003';
            contract4.IdPromocao__c = 1230;
            contract4.AccountId = acc.Id;
            listCon.add(contract4);
            
            Contract contract5 = new Contract();
            contract5.vlocity_cmt__ContractReferenceNumber__c = '000000004';
            contract5.IdPromocao__c = 1230;
            contract5.AccountId = acc.Id;
            listCon.add(contract5);
            
            Contract contract6 = new Contract();
            contract6.vlocity_cmt__ContractReferenceNumber__c = '000000005';
            contract6.IdPromocao__c = 1230;
            contract6.AccountId = acc.Id;
            listCon.add(contract6);
            
            Contract contract7 = new Contract();
            contract7.vlocity_cmt__ContractReferenceNumber__c = '000000006';
            contract7.IdPromocao__c = 1230;
            contract7.AccountId = acc.Id;
            listCon.add(contract7);
            
            Contract contract8 = new Contract();
            contract8.vlocity_cmt__ContractReferenceNumber__c = '000000007';
            contract8.IdPromocao__c = 1230;
            contract8.AccountId = acc.Id;
            listCon.add(contract8);
            
            Contract contract9 = new Contract();
            contract9.vlocity_cmt__ContractReferenceNumber__c = '000000008';
            contract9.IdPromocao__c = 1230;
            contract9.AccountId = acc.Id;
            listCon.add(contract9);
            insert listCon;

            //criar product2 antes de asset
            List<Asset> ass = createAsset(acc, prod2,listCon);

            vlocity_cmt__ContractLineItem__c  vlocityCLI = new vlocity_cmt__ContractLineItem__c(
                vlocity_cmt__ContractId__c = contract.Id
            );
            insert vlocityCLI;

            Contact ct = new Contact(
                FirstName='First Name',
                LastName='LastName',
                Email='emailTest@desktop.com.br',
                Phone='(81) 98515-2450'
            );
            insert ct;
			List<Case> caseList = new List<Case>();
            Case case1 = new Case();
            case1.accountId = acc.Id;
            case1.Contrato__c = contract.Id;
            case1.PlanoNovo__c = prod2.Id;
            case1.vlocity_cmt__BillingAccountId__c = acc.Id;
            case1.assetid = ass[0].Id;
            insert case1;
              caseList.add(case1);
            Case case2 = new Case();
            case2.accountId = acc.Id;
            case2.Contrato__c = contract2.Id;
            case2.PlanoNovo__c = prod2.Id;
            case2.vlocity_cmt__BillingAccountId__c = acc.Id;
            case2.assetid = ass[1].Id;
            insert case2;
              caseList.add(case2);
            Case case3 = new Case();
            case3.accountId = acc.Id;
            case3.Contrato__c = contract3.Id;
            case3.PlanoNovo__c = prod2.Id;
            case3.vlocity_cmt__BillingAccountId__c = acc.Id;
            case3.assetid = ass[2].Id;
            insert case3;
              caseList.add(case3);
            Case case4 = new Case();
            case4.accountId = acc.Id;
            case4.Contrato__c = contract4.Id;
            case4.PlanoNovo__c = prod2.Id;
            case4.vlocity_cmt__BillingAccountId__c = acc.Id;
            case4.assetid = ass[3].Id;
            insert case4;
            caseList.add(case4);

            Case case5 = new Case();
            case5.accountId = acc.Id;
            case5.Contrato__c = contract5.Id;
            case5.PlanoNovo__c = prod2.Id;
            case5.vlocity_cmt__BillingAccountId__c = acc.Id;
            case5.assetid = ass[4].Id;
            insert case5;
            caseList.add(case5);
            
             Case case6 = new Case();
            case6.accountId = acc.Id;
            case6.Contrato__c = contract6.Id;
            case6.PlanoNovo__c = prod2.Id;
            case6.vlocity_cmt__BillingAccountId__c = acc.Id;
            case6.assetid = ass[5].Id;
            insert case6;
            caseList.add(case6);
            
            
             Case case7 = new Case();
            case7.accountId = acc.Id;
            case7.Contrato__c = contract7.Id;
            case7.PlanoNovo__c = prod2.Id;
            case7.vlocity_cmt__BillingAccountId__c = acc.Id;
            case7.assetid = ass[6].Id;
            insert case7;
            caseList.add(case7);
            
            
             Case case8 = new Case();
            case8.accountId = acc.Id;
            case8.Contrato__c = contract8.Id;
            case8.PlanoNovo__c = prod2.Id;
            case8.vlocity_cmt__BillingAccountId__c = acc.Id;
            case8.assetid = ass[7].Id;
            insert case8;
            caseList.add(case8);
            
             Case case9 = new Case();
            case9.accountId = acc.Id;
            case9.Contrato__c = contract9.Id;
            case9.PlanoNovo__c = prod2.Id;
            case9.vlocity_cmt__BillingAccountId__c = acc.Id;
            case9.assetid = ass[8].Id;
            insert case9;
            caseList.add(case9);
            
            
            // Create Work Order. Service Appointment is created via the Work Type
            createWorkWorder(acc, ass, case1, ct.Id,caseList);


        } catch (Exception w) {
            System.debug('erro ao gerar dados '+w.getMessage() +' '+w.getStackTraceString());
        }
    }

    private static Product2 createProduct2(vlocity_cmt__ObjectClass__c obj) {
        try {
            
            RecordType rtEq = [SELECT Id FROM RecordType WHERE DeveloperName = 'Equipamento'];
    
            List<Product2> product2List = new List<Product2>();
            Product2 p1 = new Product2(
                CanUseQuantitySchedule  = true,
                CanUseRevenueSchedule   = true,
                Description             = 'T-F-23.200M.4000G',
                IsActive                = true,
                IsSerialized            = false,
                Name                    = 'Fibra Home 200M 2023',
                ProductCode             = 'T-F-23.200M.4000G',
                vlocity_cmt__ObjectTypeId__c = obj.Id
            );
            Product2 p2 = new Product2(
                CanUseQuantitySchedule  = true,
                CanUseRevenueSchedule   = true,
                Description             = 'T-F-23.400M.5000G',
                IsActive                = true,
                IsSerialized            = true,
                Name                    = 'Fibra Home 200M 2024',
                ProductCode             = 'T-F-23.400M.5000G',
                RecordTypeId            = rtEq.Id,
                vlocity_cmt__ObjectTypeId__c = obj.Id
            );
            product2List.add(p2);
            product2List.add(p1);
            insert product2List;
            return p1;
        } catch (Exception e) {
            System.debug('erro ao criar produtos '+e.getMessage()+ ' - '+e.getStackTraceString());
            throw e;
        }
    }

    public static List<WorkType> createWorkType() {
        List<WorkType> WorkTypeList = new List<WorkType>();
        WorkTypeList.add(
                new WorkType(
                    Name = 'Alteração de Plano - Adição de Serviço',
                    Work_Type_WT__c = 'Alteração de Plano',
                    Work_Subtype_WT__c = 'Adição de Serviço',
                    ShouldAutoCreateSvcAppt = true,
                    FSL__Due_Date_Offset__c = 60*24*7,
                    DurationType = 'Minutes',
                    EstimatedDuration = 60
                )
            );
        WorkTypeList.add(
                new WorkType(
                    Name = 'Alteração de Plano - Alteração de Velocidade',
                    Work_Type_WT__c = 'Alteração de Plano',
                    Work_Subtype_WT__c = 'Alteração de Velocidade',
                    ShouldAutoCreateSvcAppt = true,
                    FSL__Due_Date_Offset__c = 60*24*7,
                    DurationType = 'Minutes',
                    EstimatedDuration = 60
                )
            );
        WorkTypeList.add(
            new WorkType(
                Name = 'Migração - Migração Tecnologia',//com err
                Work_Type_WT__c = 'Migração',
                Work_Subtype_WT__c = 'Migração Tecnologia',
                ShouldAutoCreateSvcAppt = true,
                FSL__Due_Date_Offset__c = 60*24*7,
                DurationType = 'Minutes',
                EstimatedDuration = 60
            )
        );
        WorkTypeList.add(
            new WorkType(
                Name = 'Migração - Migração entre Empresa',
                Work_Type_WT__c = 'Migração',
                Work_Subtype_WT__c = 'Migração entre Empresa',
                ShouldAutoCreateSvcAppt = true,
                FSL__Due_Date_Offset__c = 60*24*7,
                DurationType = 'Minutes',
                EstimatedDuration = 60
            )
        );
        WorkTypeList.add(
            new WorkType(
                Name = 'Ativação',
                Work_Type_WT__c = 'Ativação',
                Work_Subtype_WT__c = 'Internet + TV',
                ShouldAutoCreateSvcAppt = true,
                FSL__Due_Date_Offset__c = 60*24*7,
                DurationType = 'Minutes',
                EstimatedDuration = 60
            ) 
        );
        WorkTypeList.add(
            new WorkType(
                Name = 'Manutenção',
                Work_Type_WT__c = 'Manutenção',
                Work_Subtype_WT__c = 'Corretiva',
                ShouldAutoCreateSvcAppt = true,
                FSL__Due_Date_Offset__c = 60*24*7,
                DurationType = 'Minutes',
                EstimatedDuration = 60
            )
        );
        WorkTypeList.add(
            new WorkType(
                Name = 'Mudança de endereço',
                Work_Type_WT__c = 'Mudança de endereço',
                Work_Subtype_WT__c = 'Internet + TV',
                ShouldAutoCreateSvcAppt = true,
                FSL__Due_Date_Offset__c = 60*24*7,
                DurationType = 'Minutes',
                EstimatedDuration = 60
            )
        );
        WorkTypeList.add(
            new WorkType(
                Name = 'Serviços Adicionais',
                Work_Type_WT__c = 'Serviços Adicionais',
                Work_Subtype_WT__c = 'Ponto Adicional de TV',
                ShouldAutoCreateSvcAppt = true,
                FSL__Due_Date_Offset__c = 60*24*7,
                DurationType = 'Minutes',
                EstimatedDuration = 60
            )
        );
        insert WorkTypeList; 
        return WorkTypeList;
    }

    private static List<Asset> createAsset(Account acc, Product2 prod2, List<Contract> cont) {
        List<Asset> AssetList = new List<Asset>();
        List<Asset> AssetListRet = new List<Asset>();
        Asset ass = new Asset(
            Name = 'Fibra Home 200M 2023',
            Status = 'A',
            AccountId = acc.Id,
            Product2Id = prod2.Id,
            IdPlanoAdicional__c = 683350,
            IdPlanoUsuario__c = 3658968,
            IdPromocao__c = 6589,
            CodigoAtivo__c = 'ZN310011',
            TipoAtivo__c = 'ONU',
            CTO__c = '25',
            PortaCTO__c = '1',
            SiglaCTO__c = 'ACD',
            CaixaCTO__c = '32',
            vlocity_cmt__ContractId__c = cont[0].id,
            vlocity_cmt__ServiceAccountId__c = acc.id
        );
        insert ass;
        //2
        AssetList.add(new Asset(
            Name = 'Fibra Home 200M 2023',
            Status = 'A',
            AccountId = acc.Id,
            Product2Id = prod2.Id,
            IdPlanoAdicional__c = 683350,
            IdPlanoUsuario__c = 3658968,
            IdPromocao__c = 6589,
            CodigoAtivo__c = 'ZN310011',
            TipoAtivo__c = 'ONU',
            CTO__c = '25',
            PortaCTO__c = '1',
            SiglaCTO__c = 'ACD',
            CaixaCTO__c = '32',
            vlocity_cmt__ContractId__c = cont[1].id,
            vlocity_cmt__ServiceAccountId__c = acc.id
        ));
        //3
        AssetList.add(new Asset(
            Name = 'Fibra Home 200M 2023',
            Status = 'A',
            AccountId = acc.Id,
            Product2Id = prod2.Id,
            IdPlanoAdicional__c = 683350,
            IdPlanoUsuario__c = 3658968,
            IdPromocao__c = 6589,
            CodigoAtivo__c = 'ZN310011',
            TipoAtivo__c = 'ONU',
            CTO__c = '25',
            PortaCTO__c = '1',
            SiglaCTO__c = 'ACD',
            CaixaCTO__c = '32',
            vlocity_cmt__ContractId__c = cont[2].id,
            vlocity_cmt__ServiceAccountId__c = acc.id
        ));
        //4
        AssetList.add(new Asset(
            Name = 'Fibra Home 200M 2023',
            Status = 'A',
            AccountId = acc.Id,
            Product2Id = prod2.Id,
            IdPlanoAdicional__c = 683350,
            IdPlanoUsuario__c = 3658968,
            IdPromocao__c = 6589,
            CodigoAtivo__c = 'ZN310011',
            TipoAtivo__c = 'ONU',
            CTO__c = '25',
            PortaCTO__c = '1',
            SiglaCTO__c = 'ACD',
            CaixaCTO__c = '32',
            vlocity_cmt__ContractId__c = cont[3].id,
            vlocity_cmt__ServiceAccountId__c = acc.id
        ));
        
        //5
        AssetList.add(new Asset(
            Name = 'Fibra Home 200M 2023',
            Status = 'A',
            AccountId = acc.Id,
            Product2Id = prod2.Id,
            IdPlanoAdicional__c = 683350,
            IdPlanoUsuario__c = 3658968,
            IdPromocao__c = 6589,
            CodigoAtivo__c = 'ZN310011',
            TipoAtivo__c = 'ONU',
            CTO__c = '25',
            PortaCTO__c = '1',
            SiglaCTO__c = 'ACD',
            CaixaCTO__c = '32',
            vlocity_cmt__ContractId__c = cont[4].id,
            vlocity_cmt__ServiceAccountId__c = acc.id
        ));
        //6
        AssetList.add(new Asset(
            Name = 'Fibra Home 200M 2023',
            Status = 'A',
            AccountId = acc.Id,
            Product2Id = prod2.Id,
            IdPlanoAdicional__c = 683350,
            IdPlanoUsuario__c = 3658968,
            IdPromocao__c = 6589,
            CodigoAtivo__c = 'ZN310011',
            TipoAtivo__c = 'ONU',
            CTO__c = '25',
            PortaCTO__c = '1',
            SiglaCTO__c = 'ACD',
            CaixaCTO__c = '32',
            vlocity_cmt__ContractId__c = cont[5].id,
            vlocity_cmt__ServiceAccountId__c = acc.id
        ));
        //7
        AssetList.add(new Asset(
            Name = 'Fibra Home 200M 2023',
            Status = 'A',
            AccountId = acc.Id,
            Product2Id = prod2.Id,
            IdPlanoAdicional__c = 683350,
            IdPlanoUsuario__c = 3658968,
            IdPromocao__c = 6589,
            CodigoAtivo__c = 'ZN310011',
            TipoAtivo__c = 'ONU',
            CTO__c = '25',
            PortaCTO__c = '1',
            SiglaCTO__c = 'ACD',
            CaixaCTO__c = '32',
            vlocity_cmt__ContractId__c = cont[6].id,
            vlocity_cmt__ServiceAccountId__c = acc.id
        ));
        //8
        AssetList.add(new Asset(
            Name = 'Fibra Home 200M 2023',
            Status = 'A',
            AccountId = acc.Id,
            Product2Id = prod2.Id,
            IdPlanoAdicional__c = 683350,
            IdPlanoUsuario__c = 3658968,
            IdPromocao__c = 6589,
            CodigoAtivo__c = 'ZN310011',
            TipoAtivo__c = 'ONU',
            CTO__c = '25',
            PortaCTO__c = '1',
            SiglaCTO__c = 'ACD',
            CaixaCTO__c = '32',
            vlocity_cmt__ContractId__c = cont[7].id,
            vlocity_cmt__ServiceAccountId__c = acc.id
        ));
        //9
        AssetList.add(new Asset(
            Name = 'Fibra Home 200M 2023',
            Status = 'A',
            AccountId = acc.Id,
            Product2Id = prod2.Id,
            IdPlanoAdicional__c = 683350,
            IdPlanoUsuario__c = 3658968,
            IdPromocao__c = 6589,
            CodigoAtivo__c = 'ZN310011',
            TipoAtivo__c = 'ONU',
            CTO__c = '25',
            PortaCTO__c = '1',
            SiglaCTO__c = 'ACD',
            CaixaCTO__c = '32',
            vlocity_cmt__ContractId__c = cont[8].id,
            vlocity_cmt__ServiceAccountId__c = acc.id
        ));
        AssetList.add(
            new Asset(
                Name = 'Fibra Home 200M 2023',
                Status = 'L',
                AccountId = acc.Id,
                Product2Id = prod2.Id,
                ParentId = ass.Id,
                IdPlanoAdicional__c = 683351,
                IdPlanoUsuario__c = 3658969,
                IdPromocao__c = 65896,
                CTO__c = '25',
                PortaCTO__c = '1',
                TipoAtivo__c = 'ONU',
                CodigoAtivo__c = 'ZY246458',
                vlocity_cmt__ContractId__c = cont[0].id,
                vlocity_cmt__ServiceAccountId__c = acc.id
            )
        );
        AssetList.add(
            new Asset(
                Name = 'Roteador Zyxel EMG3525-T50B',
                Status = 'L',
                AccountId = acc.Id,
                Product2Id = prod2.Id,
                ParentId = ass.Id,
                IdPlanoAdicional__c = 683355,
                IdPlanoUsuario__c = 3658967,
                IdPromocao__c = 65896,
                CTO__c = '42',
                PortaCTO__c = '2',
                TipoAtivo__c = 'R',
                CodigoAtivo__c = 'ZY224119',
                vlocity_cmt__ContractId__c = cont[0].id,
                vlocity_cmt__ServiceAccountId__c = acc.id
            )
        );
        AssetList.add(
            new Asset(
                Name = 'STB Aria 7 X',
                Status = 'L',
                AccountId = acc.Id,
                Product2Id = prod2.Id,
                ParentId = ass.Id,
                IdPlanoAdicional__c = 683352,
                IdPlanoUsuario__c = 3658966,
                IdPromocao__c = 65896,
                CTO__c = '25',
                PortaCTO__c = '1',
                TipoAtivo__c = 'SB',
                CodigoAtivo__c = 'SB043136',
                vlocity_cmt__ContractId__c = cont[0].id,
                vlocity_cmt__ServiceAccountId__c = acc.id
            )
        );
        Product2 p2 = [SELECT Id FROM Product2 WHERE ProductCode = 'T-F-23.400M.5000G' LIMIT 1];
        AssetList.add(
            new Asset(
                Name = 'STB Aria 7 X 2',
                Status = 'L',
                AccountId = acc.Id,
                Product2Id = P2.Id,
                ParentId = ass.Id,
                IdPlanoAdicional__c = 683352,
                IdPlanoUsuario__c = 3658966,
                IdPromocao__c = 65896,
                CTO__c = '25',
                PortaCTO__c = '1',
                TipoAtivo__c = 'SB',
                CodigoAtivo__c = 'SB043137',
                vlocity_cmt__ContractId__c = cont[0].id,
                vlocity_cmt__ServiceAccountId__c = acc.Id
            )
        );
        insert AssetList;
        AssetListRet.add(ass);
        AssetListRet.addAll(AssetList);
        return AssetListRet;
    }

    private static Map<String,Id> getRecordTypeMap() {
        try {
            Map<String, Id> recordTypeMap = new Map<String, Id>();
            //cria lista com os tipos de registros
            Set<String> DNRTList = new Set<String>{'Activation','PlanChange','Migration','AddressChange','Maintenance','AdditionalServices'};
            
            List<RecordType> recordTypeList = [SELECT DeveloperName, Id FROM RecordType WHERE DeveloperName in:DNRTList];

            for (RecordType rt : recordTypeList) {
                System.debug('DeveloperName '+rt.DeveloperName);
                recordTypeMap.put(rt.DeveloperName, rt.Id);
            }

            return recordTypeMap;
            
        } catch (Exception e) {
            System.debug('Erro ao inserir recordType '+e.getMessage()+ ' '+e.getStackTraceString());
            throw e;
        }
    }

    private static void createWorkWorder(Account acc, List<Asset> ass, Case case1, Id ContId, List<Case> caseList) {
        try {
            System.debug('inserindo work orders ');
            Map<String, Id> recordTypeMap = getRecordTypeMap();

            WorkType WT_ApAs = [SELECT Id FROM WorkType WHERE Name = 'Alteração de Plano - Adição de Serviço'];
            WorkType WT_ApAv = [SELECT Id FROM WorkType WHERE Name = 'Alteração de Plano - Alteração de Velocidade'];
            WorkType WT_MigMigTec = [SELECT Id FROM WorkType WHERE Name = 'Migração - Migração Tecnologia'];
            WorkType WT_MigMigEmp = [SELECT Id FROM WorkType WHERE Name = 'Migração - Migração entre Empresa'];
            WorkType WT_Ativ = [SELECT Id FROM WorkType WHERE Name = 'Ativação'];
            WorkType WT_Manut = [SELECT Id FROM WorkType WHERE Name = 'Manutenção'];
            WorkType WT_Mudanca_Endereco = [SELECT Id FROM WorkType WHERE Name = 'Mudança de endereço'];
            WorkType WT_Servicos_Adicionais = [SELECT Id FROM WorkType WHERE Name = 'Serviços Adicionais'];
            List<WorkOrder> WorkOrderList = new List<WorkOrder>();
            List<WorkStep> WorkStepList = new List<WorkStep>();
            List<WorkPlan> WorkPlanList = new List<WorkPlan>();
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_ApAs.Id,
                    AssetId = ass[0].Id,
                    CaseId = caseList[0].Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('PlanChange'),
                    //Work_Type_WO__c = 'Alteração de Plano',
                    Work_Subtype_WO__c = 'Alteração de Velocidade',
                    cto__c='GTT-135',
                    porta__c=1
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_ApAv.Id,
                    AssetId = ass[1].Id,
                    CaseId = caseList[1].Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('PlanChange'),
                    //Work_Type_WO__c = 'Alteração de Plano',
                    Work_Subtype_WO__c = 'Alteração de Velocidade',
                      cto__c='GTT-135',
                    porta__c=1
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_ApAv.Id,
                    AssetId = ass[2].Id,
                    CaseId = caseList[2].Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('PlanChange'),
                    //Work_Type_WO__c = 'Alteração de Plano',
                    Work_Subtype_WO__c = 'Adição de Serviço',
                      cto__c='GTT-135',
                    porta__c=1
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_MigMigTec.Id,
                    ContactId = ContId,
                    AssetId = ass[3].Id,
                    CaseId = caseList[3].Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('Migration'),
                    // Work_Type_WO__c = 'Migração',
                    Work_Subtype_WO__c = 'Migração Tecnologia',
                      cto__c='GTT-135',
                    porta__c=1
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_MigMigEmp.Id,
                    ContactId = ContId,
                    AssetId = ass[4].Id,
                    CaseId = caseList[4].Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('Migration'),
                    //Work_Type_WO__c = 'Migração',
                    Work_Subtype_WO__c = 'Migração entre Empresa',
                      cto__c='GTT-135',
                    porta__c=1
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_Ativ.Id,
                    ContactId = ContId,
                    AssetId = ass[0].Id,
                    CaseId = caseList[5].Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('Activation'),
                    //Work_Type_WO__c = 'Ativação',
                    Work_Subtype_WO__c = 'Internet',
                      cto__c='GTT-135',
                    porta__c=1
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_Manut.Id,
                    ContactId = ContId,
                    AssetId = ass[6].Id,
                    CaseId = caseList[6].Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 XX',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('Maintenance'),
                    //Work_Type_WO__c = 'Manutenção',
                    Work_Subtype_WO__c = 'Corretiva',
                      cto__c='GTT-135',
                    porta__c=1
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_Mudanca_Endereco.Id,
                    ContactId = ContId,
                    AssetId = ass[7].Id,
                    CaseId = caseList[7].Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('AddressChange'),
                    //Work_Type_WO__c = 'Mudança de endereço',
                    Work_Subtype_WO__c = 'Internet + TV',
                      cto__c='GTT-135',
                    porta__c=1
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_Servicos_Adicionais.Id,
                    ContactId = ContId,
                    AssetId = ass[8].Id,
                    CaseId = caseList[8].Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('AdditionalServices'),
                    //Work_Type_WO__c = 'Serviços Adicionais',
                    Work_Subtype_WO__c = 'Ponto Adicional de TV',
                      cto__c='GTT-135',
                    porta__c=1
                )
            );
            insert WorkOrderList;

            for (WorkOrder wo : WorkOrderList) {
                System.debug('wo created '+wo.Id+' '+wo.Work_Subtype_WO__c);
                WorkPlanList.add(
                    new WorkPlan(
                        Name = wo.Work_Subtype_WO__c,
                        WorkOrderId = wo.Id
                    )
                );
            }
            insert WorkPlanList;
            for (WorkPlan wp : WorkPlanList) {
                System.debug('wp created '+wp.Id+' '+wp.Name);
                WorkStepList.add(
                    new WorkStep(
                        Name                    = wp.Name,
                        Status                  = 'New',
                        WorkPlanId              = wp.Id,
                        ExecutionOrder          = 1
                    )
                );
                WorkStepList.add(
                    new WorkStep(
                        Name                    = wp.Name,
                        Status                  = 'New',
                        WorkPlanId              = wp.Id,
                        ExecutionOrder          = 2
                    )
                );
            }
            insert WorkStepList;
            for (WorkStep ws : WorkStepList) {
                System.debug('ws created '+ws.Name);
            }
        } catch (Exception e) {
            System.debug('Error '+e.getMessage() + ' - '+e.getStackTraceString());
        }

    }

    /*private static WorkPlanTemplate createPlanTemplate(){
        WorkPlanTemplate wp = new WorkPlanTemplate();
        wp.Name = 'Teste';
        wp.IsActive = true;
        wp.RelativeExecutionOrder = 1;
        insert wp;

        return wp;
    }
    
    private static List<WorkStepTemplate> createStepTemplate(){

        List<WorkStepTemplate> ws = new List<WorkStepTemplate>();
        ws.add(new WorkStepTemplate(
                Name = 'Teste 1',
                IsActive = true
            )

        );
        ws.add(new WorkStepTemplate(
                Name = 'Teste 2',
                IsActive = true
            )

        );
        
        insert ws;

        return ws;
    }

    private static void createPlanEntry(WorkPlanTemplate wp, List<WorkStepTemplate> ws){
        List<WorkPlanTemplateEntry> wpe = new List<WorkPlanTemplateEntry>();
        Integer i = 1;
        for(WorkStepTemplate w : ws){
            WorkPlanTemplateEntry we = new WorkPlanTemplateEntry();
            we.ExecutionOrder = i;
            we.WorkPlanTemplateId =  wp.Id;
            we.WorkStepTemplateId = w.Id;
            i++;
            wpe.add(we);
        }
        if(wpe.size()>0){
            insert wpe;
        }
    }

    private static void createPlanRule(WorkPlanTemplate wp , List<WorkType> wts){
        List<WorkPlanSelectionRule> wsr = new List<WorkPlanSelectionRule>();
        Integer i = 1;
        for(WorkType wt : wts){
            WorkPlanSelectionRule sr = new WorkPlanSelectionRule();
            sr.IsActive = true;
            sr.WorkPlanTemplateId = wp.Id;
            sr.WorkTypeId = wt.Id;
            i++;
            wsr.add(sr);
        }
        if(wsr.size()>0){
            insert wsr;
        }
    }*/
}