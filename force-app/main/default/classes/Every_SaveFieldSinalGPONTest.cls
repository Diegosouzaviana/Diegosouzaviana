@isTest
public with sharing class Every_SaveFieldSinalGPONTest {

    @TestSetup
    static void makeData(){
        try {
            Product2 prod2 = createProduct2();
            createWorkType();
           
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

            Asset ass = createAsset(acc, prod2);
            Map<String, Integer> quantityByStatus = new Map<String, Integer>();
            quantityByStatus.put('L', 2);
            quantityByStatus.put('A', 1);
            createChildAssets(ass, quantityByStatus);

            Contract contract = new Contract();
            contract.vlocity_cmt__ContractReferenceNumber__c = '236598856';
            contract.IdPromocao__c = 1230;
            contract.AccountId = acc.Id;
            insert contract;
            
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

            Case case1 = new Case();
            case1.accountId = acc.Id;
            case1.Contrato__c = contract.Id;
            case1.PlanoNovo__c = prod2.Id;
            case1.vlocity_cmt__BillingAccountId__c = acc.Id;
            case1.Nivel_Sinal__c = 'Teste';
            insert case1;
            createWorkWorder(acc, ass, case1, ct.Id);

        } catch (Exception w) {
            System.debug('erro ao gerar dados '+w.getMessage() +' '+w.getStackTraceString());
        } 
    }

    private static Product2 createProduct2() {
        try {
            
            RecordType rtEq = [SELECT Id FROM RecordType WHERE DeveloperName = 'Equipment'];
    
            List<Product2> product2List = new List<Product2>();
            Product2 p1 = new Product2(
                CanUseQuantitySchedule  = true,
                CanUseRevenueSchedule   = true,
                Description             = 'T-F-23.200M.4000G',
                IsActive                = true,
                IsSerialized            = false,
                Name                    = 'Fibra Home 200M 2023',
                ProductCode             = 'T-F-23.200M.4000G'
            );
            Product2 p2 = new Product2(
                CanUseQuantitySchedule  = true,
                CanUseRevenueSchedule   = true,
                Description             = 'T-F-23.400M.5000G',
                IsActive                = true,
                IsSerialized            = true,
                Name                    = 'Fibra Home 200M 2024',
                ProductCode             = 'T-F-23.400M.5000G',
                RecordTypeId            = rtEq.Id
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

    public static void createWorkType() {
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
                Name = 'Migração - Migração Tecnologia',
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
    }

    private static Asset createAsset(Account acc, Product2 prod2) {
        List<Asset> AssetList = new List<Asset>();
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
            CaixaCTO__c = '32'
        );
        insert ass;
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
                CodigoAtivo__c = 'ZY246458'
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
                CodigoAtivo__c = 'ZY224119'
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
                CodigoAtivo__c = 'SB043136'
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
                CodigoAtivo__c = 'SB043137'
            )
        );
        insert AssetList;
        return ass;
    }

    private static void createChildAssets(
        Asset parentAsset, Map<String, Integer> quantityByStatusMap
    ) {
        List<Asset> assets = new List<Asset>();
        Integer assetQuantity;
        for(String assetStatus : quantityByStatusMap.keySet()) {
            assetQuantity = quantityByStatusMap.get(assetStatus);
            for(Integer i = 0; i < assetQuantity; i++) {
                assets.add(
                    new Asset(
                        Name = 'Fibra Test - ' + assetStatus + ' - ' + i,
                        Status = assetStatus,
                        ParentId = parentAsset.Id,
                        AccountId = parentAsset.AccountId,
                        Product2Id = parentAsset.Product2Id,
                        IdPlanoAdicional__c = 683350,
                        IdPlanoUsuario__c = 3658968,
                        IdPromocao__c = 6589,
                        CodigoAtivo__c = 'ZN310011',
                        TipoAtivo__c = 'ONU',
                        CTO__c = '25',
                        PortaCTO__c = '1',
                        SiglaCTO__c = 'ACD',
                        CaixaCTO__c = '32'
                    )
                );
            }
        }
        insert assets;
    }

    private static Map<String,Id> getRecordTypeMap() {
        try {
            Map<String, Id> recordTypeMap = new Map<String, Id>();
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

    private static void createWorkWorder(Account acc, Asset ass, Case case1, Id ContId) {
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
                    AssetId = ass.Id,
                    CaseId = case1.Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('PlanChange'),
                    Work_Subtype_WO__c = 'Alteração de Velocidade'
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_ApAv.Id,
                    AssetId = ass.Id,
                    CaseId = case1.Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('PlanChange'),
                    Work_Subtype_WO__c = 'Alteração de Velocidade'
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_ApAv.Id,
                    AssetId = ass.Id,
                    CaseId = case1.Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('PlanChange'),
                    Work_Subtype_WO__c = 'Adição de Serviço'
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_MigMigTec.Id,
                    ContactId = ContId,
                    AssetId = ass.Id,
                    CaseId = case1.Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('Migration'),
                    Work_Subtype_WO__c = 'Migração Tecnologia'
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_MigMigEmp.Id,
                    ContactId = ContId,
                    AssetId = ass.Id,
                    CaseId = case1.Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('Migration'),
                    Work_Subtype_WO__c = 'Migração entre Empresa'
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_Ativ.Id,
                    ContactId = ContId,
                    AssetId = ass.Id,
                    CaseId = case1.Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('Activation'),
                    Work_Subtype_WO__c = 'Internet'
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_Manut.Id,
                    ContactId = ContId,
                    AssetId = ass.Id,
                    CaseId = case1.Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 XX',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('Maintenance'),
                    Work_Subtype_WO__c = 'Corretiva'
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_Mudanca_Endereco.Id,
                    ContactId = ContId,
                    AssetId = ass.Id,
                    CaseId = case1.Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('AddressChange'),
                    Work_Subtype_WO__c = 'Internet + TV'
                )
            );
            WorkOrderList.add(
                new WorkOrder(
                    AccountId = acc.Id,
                    WorkTypeId = WT_Servicos_Adicionais.Id,
                    ContactId = ContId,
                    AssetId = ass.Id,
                    CaseId = case1.Id,
                    Subject = 'Test',
                    Street = 'Kerkstraat 2 Test',
                    PostalCode = '3581 RD',
                    City = 'Utrecht',
                    Country = 'NL',
                    State = 'AM',
                    RecordTypeId = recordTypeMap.get('AdditionalServices'),
                    Work_Subtype_WO__c = 'Ponto Adicional de TV'
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
                        WorkPlanId              = wp.Id
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

    @isTest
    static void testIntegracaoIPTrigger() {      
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
            Every_SaveFieldSinalGPON.integracaoIPTrigger(wo.Id);
        Test.stopTest();

        Case casoTeste = [SELECT Nivel_Sinal__c FROM Case LIMIT 1];
        System.assertEquals('Teste', casoTeste.Nivel_Sinal__c);
    }

    @isTest
    static void testMetodoCondicoes1(){
        List<Case> casos = [SELECT Id FROM Case LIMIT 1];
        String jsonString = '{"statusCode": 422,"response": "Dados inconsistentes para executar essa ação, abrir um chamado no GLPI."}';
        Map<String, Object> mapTest = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
        Every_SaveFieldSinalGPON.metodoCondicoes(casos, mapTest);

    }

    @isTest
    static void testMetodoCondicoes2(){
        List<Case> casos = [SELECT Id FROM Case LIMIT 1];
        String jsonString = '{"apiStatus":{"success":200},"fullJson":{"status":{"olts":{"onu_status":"active","onu_conf":"active","onu_down":"NoUpgrade","onu_oper":"up","onu_dist":"2.769","onu_onu_rx":"-15.9","onu_olt_rx":"-20.3"},"status":"found"}}}';
        Map<String, Object> mapTest = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
        Every_SaveFieldSinalGPON.metodoCondicoes(casos, mapTest);

    }
}