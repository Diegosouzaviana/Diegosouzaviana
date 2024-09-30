@IsTest
public class DesktopServiceTest {
    static String body = '{"user_plan_id":1090650,"promotion":null,"message_validation_list":null,"fixed_discount":null,"customer_id":745497,"customer_current_plan":"T-G-23.350M.4000G","correlation_id":"LHWecvTIjC","contracted_plan":"T-G-22.600M.4000G.GloboPlay"}';
    @TestSetup
    static void makeData(){
        DesktopServiceFactoryTest.setup();
    }

    static void updateSA(Id WorkOrderId) {
        try {
            ServiceAppointment sa = [SELECT LongUserPlanId__c, StringPPoeUser__c, sac_login__c, sac_password__c, wifi_ssid__c, wifi_password__c, Id FROM ServiceAppointment where ParentRecordId = :WorkOrderId];
            sa.LongUserPlanId__c    = '125';
            sa.StringPPoeUser__c    = '965';
            sa.sac_login__c         = '986';
            sa.sac_password__c      = '123';
            sa.wifi_ssid__c         = '321';
            sa.wifi_password__c     = '852';
            update sa;
        } catch (Exception e) {
            System.debug('Error on update Service Appointment: '+e.getMessage()+ ' - '+e.getStackTraceString());
        }
    }

    private static void createIsSameModel(Id WorkOrderId) {
        try {
            Product2 p2 = [SELECT RecordType.DeveloperName, ProductCode, Id FROM Product2 WHERE IsSerialized = TRUE LIMIT 1];
            System.debug('RecordType.DeveloperName '+p2.RecordType.DeveloperName);
            Schema.Location location1 = new Schema.Location();
            location1.Name = 'Estoque de RBI';
            location1.LocationType = 'Warehouse';
            location1.TimeZone = 'America/Sao_Paulo';
            location1.IsInventoryLocation=true;
            location1.IsMobile=true;
            location1.latitude=-23.49093930803577;
            location1.longitude=-47.51609786262823;
            insert location1;
            List<ProductItem> pItemList = [SELECT Id FROM ProductItem WHERE Product2Id = :p2.Id];
            System.debug('pItemList '+pItemList.size());
            ProductItem productItem = new ProductItem();
            productItem.QuantityOnHand = 0;
            productItem.QuantityUnitOfMeasure = 'Each';
            productItem.Product2Id = p2.Id;
            productItem.LocationId = location1.Id;
            productItem.guidMaterial__c = String.valueOf(Integer.valueOf(Math.random()*1000));
            insert productItem;
            ProductConsumed pc = new ProductConsumed(
                ProductItemId = productItem.Id,
                WorkOrderId = WorkOrderId,
                QuantityConsumed = 0
            );
    
            insert pc;
            Asset ass = [SELECT Id FROM Asset WHERE CodigoAtivo__c = 'SB043137' LIMIT 1];
            WorkOrderLineItem woli = new WorkOrderLineItem(
                WorkOrderId = WorkOrderId,
                AssetId = ass.Id
            );
            insert woli;            
        } catch (Exception e) {
            System.debug('erro ao criar item: '+e.getMessage()+' - '+e.getStackTraceString());
        }
    }
    
    @IsTest
    static void AlteracaoPlanoAlteracaoVelocidadeWO() {//Alteração de Plano e Alteração de Velocidade
        WorkStep WorkStep = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Alteração de Plano' AND WorkOrder.Work_Subtype_WO__c = 'Alteração de Velocidade' LIMIT 1];
        String cto = 'TST-123';
        Integer porta_cto = 1;
        Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));

        Test.startTest();

        DesktopService.DesktopService(WorkStep.Id, cto, porta_cto);
        updateSA(WorkStep.WorkOrderId);
        DesktopService.checkCallback(WorkStep.Id);
        Test.stopTest();
    }

     @IsTest
    static void AlteracaoPlanoAlteracaoVelocidadeWOelse() {//Alteração de Plano e Alteração de Velocidade
        WorkStep WorkStep = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Alteração de Plano' AND WorkOrder.Work_Subtype_WO__c = 'Alteração de Velocidade' LIMIT 1];
         
      
        String cto = 'TST-123';
        Integer porta_cto = 1;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
        DesktopService.DesktopService(WorkStep.Id, cto, porta_cto);
        updateSA(WorkStep.WorkOrderId);
         ServiceAppointment sa = [select LongUserPlanId__c, StringPPoeUser__c, sac_login__c, sac_password__c, wifi_ssid__c, wifi_password__c, Id from ServiceAppointment  where  LongUserPlanId__c='125' ];
        sa.StringPPoeUser__c='';
        sa.message_update_speed__c = 'teste';
        update sa;
        DesktopService.checkCallback(WorkStep.Id);
        Test.stopTest();
    }

    @IsTest
    static void AlteracaoPlanoAlteracaoVelocidadeWO_2() {//Alteração de Plano e Alteração de Velocidade
        WorkStep WorkStep = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Alteração de Plano' AND WorkOrder.Work_Subtype_WO__c = 'Alteração de Velocidade' LIMIT 1];
      
        String cto = 'TST-123';
        Integer porta_cto = 1;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
        createIsSameModel(WorkStep.WorkOrderId);
        DesktopService.DesktopService(WorkStep.Id, cto, porta_cto);
        updateSA(WorkStep.WorkOrderId);
        DesktopService.checkCallback(WorkStep.Id);
        Test.stopTest();
    }
    

    @IsTest
    static void AlteracaoPlanoAndIncorrectgSubtypeWO() {//Alteração de Plano e subtipo incorreto
        try{
        WorkStep WorkStep = [SELECT WorkOrder.Work_Subtype_WO__c, WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Alteração de Plano' AND WorkOrder.Work_Subtype_WO__c = 'Alteração de Velocidade' LIMIT 1];
        WorkOrder won = [SELECT Work_Subtype_WO__c FROM WorkOrder WHERE Id = :WorkStep.WorkOrderId ];
        won.Work_Subtype_WO__c = 'Migração Tecnologia';
      
        update won;
       
        String cto = 'TST-123';
        Integer porta_cto = 1;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
        DesktopService.DesktopService(WorkStep.Id, cto, porta_cto);
        updateSA(WorkStep.WorkOrderId);
        DesktopService.checkCallback(WorkStep.Id);
        Test.stopTest();
             }catch(exception e){
            
        }
    }

    @IsTest
    static void AlteracaoDePlanoAdicaoDeServicoWO() {//Alteração de Plano e Adição de Serviço 
        WorkOrder wos = [SELECT id FROM WorkOrder LIMIT 1];
        wos.Work_Type_WO__c = 'Alteração de Plano';
        wos.Work_Subtype_WO__c = 'Adição de Serviço';
        update wos;
        
        WorkStep WorkStep = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Alteração de Plano' AND WorkOrder.Work_Subtype_WO__c = 'Adição de Serviço' LIMIT 1];
      
        String cto = 'TST-123';
        Integer porta_cto = 1;
        String body = '{"user_plan_id":1090650,"promotion":null,"message_validation_list":null,"fixed_discount":null,"customer_id":745497,"customer_current_plan":"T-G-23.350M.4000G","correlation_id":"LHWecvTIjC","contracted_plan":"T-G-22.600M.4000G.GloboPlay"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
        createIsSameModel(WorkStep.WorkOrderId);
        DesktopService.DesktopService(WorkStep.Id, cto, porta_cto);
        updateSA(WorkStep.WorkOrderId);
        DesktopService.checkCallback(WorkStep.Id);
        Test.stopTest();
    }

    @IsTest
    static void AlteracaoDePlanoAdicaoDeServicoWO_Error() {//Alteração de Plano e Adição de Serviço
        WorkStep WorkStep = [SELECT WorkOrderId, Id FROM WorkStep WHERE Name = 'Adição de Serviço' LIMIT 1];
        String cto = 'TST-123';
        Integer porta_cto = null;
        Test.startTest();
        DesktopService.DesktopService(WorkStep.Id, cto, porta_cto);
        updateSA(WorkStep.WorkOrderId);
        DesktopService.checkCallback(WorkStep.Id);
        DesktopService.clearCallbackMessages(WorkStep.Id);
        Test.stopTest();
    }

    @IsTest
    static void MigracaoMigracaoTecnologiaWO() {//Migração e Migração Tecnologia
        WorkStep wt = [SELECT WorkOrder.Work_Type_WO__c, WorkOrder.Work_Subtype_WO__c, WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Migração' AND WorkOrder.Work_Subtype_WO__c = 'Migração Tecnologia' LIMIT 1];
        System.debug('wt mig- '+wt.WorkOrder.Work_Type_WO__c+' - '+wt.WorkOrder.Work_Subtype_WO__c);
        String cto = 'TST-123';
        Integer porta_cto = 1;
        ServiceAppointment sa = [SELECT  LongUserPlanId__c, StringPPoeUser__c, sac_login__c, sac_password__c, wifi_ssid__c, wifi_password__c, TechnicianName__c, TechniciansCompany__c, Id FROM ServiceAppointment WHERE ParentRecordId = :wt.WorkOrderId];
        sa.TechnicianName__c = 'Roberto Ramos';
        sa.TechniciansCompany__c = 'Desktop';
        update sa;
        String body = '{"user_plan_id":1090650,"promotion":null,"message_validation_list":null,"fixed_discount":null,"customer_id":745497,"customer_current_plan":"T-G-23.350M.4000G","correlation_id":"LHWecvTIjC","contracted_plan":"T-G-22.600M.4000G.GloboPlay"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
        DesktopService.DesktopService(wt.Id, cto, porta_cto);
        updateSA(wt.WorkOrderId);
        DesktopService.checkCallback(wt.Id);
        Test.stopTest();
        
    }
	@IsTest
    static void MigracaoMigracaoTecnologiaWO2() {//Migração e Migração Tecnologia
        WorkStep wt = [SELECT WorkOrder.Work_Type_WO__c, WorkOrder.Work_Subtype_WO__c, WorkOrderId, WorkOrder.caseid, WorkOrder.case.assetid, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Migração' AND WorkOrder.Work_Subtype_WO__c = 'Migração Tecnologia' LIMIT 1];
        System.debug('wt mig- '+wt);
        Asset assetre=  new asset();
       assetre.id = wt.WorkOrder.case.assetid;
        assetre.IdPlanoUsuario__c= null;
        update assetre;
        
        String cto = 'TST-123';
        Integer porta_cto = 1;
        ServiceAppointment sa = [SELECT  LongUserPlanId__c, StringPPoeUser__c, sac_login__c, sac_password__c, wifi_ssid__c, wifi_password__c, TechnicianName__c, TechniciansCompany__c, Id FROM ServiceAppointment WHERE ParentRecordId = :wt.WorkOrderId];
        sa.TechnicianName__c = 'Roberto Ramos';
        sa.TechniciansCompany__c = 'Desktop';
        update sa;
        String body = '{"user_plan_id":1090650,"promotion":null,"message_validation_list":null,"fixed_discount":null,"customer_id":745497,"customer_current_plan":"T-G-23.350M.4000G","correlation_id":"LHWecvTIjC","contracted_plan":"T-G-22.600M.4000G.GloboPlay"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
        DesktopService.DesktopService(wt.Id, cto, porta_cto);
        updateSA(wt.WorkOrderId);
        DesktopService.checkCallback(wt.Id);
        Test.stopTest();
        
    }
    @IsTest
    static void MigracaoMigracaoEmpresaWO() {//Migração entre Empresa
        WorkStep wt = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Migração' AND WorkOrder.Work_Subtype_WO__c = 'Migração entre Empresa' LIMIT 1];
        String cto = 'TST-123';
        Integer porta_cto = 1;
        ServiceAppointment sa = [SELECT  LongUserPlanId__c, StringPPoeUser__c, sac_login__c, sac_password__c, wifi_ssid__c, wifi_password__c, TechnicianName__c, TechniciansCompany__c, Id FROM ServiceAppointment WHERE ParentRecordId = :wt.WorkOrderId];
        sa.TechnicianName__c = 'Roberto Ramos';
        sa.TechniciansCompany__c = 'Desktop';
        update sa;
        String body = '{"user_plan_id":1090650,"promotion":null,"message_validation_list":null,"fixed_discount":null,"customer_id":745497,"customer_current_plan":"T-G-23.350M.4000G","correlation_id":"LHWecvTIjC","contracted_plan":"T-G-22.600M.4000G.GloboPlay"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
        DesktopService.DesktopService(wt.Id, cto, porta_cto);
        updateSA(wt.WorkOrderId);
        DesktopService.checkCallback(wt.Id);
        Test.stopTest();
    }

    @IsTest
    static void AtivacaoWO() {
        try {
            //WorkStep wt = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Ativação' LIMIT 1];
            WorkStep ws = [SELECT WorkOrder.Work_Type_WO__c, WorkOrder.Work_Subtype_WO__c, WorkOrderId,
                                        WorkOrder.Case.Contrato__r.ContractNumber, 
                                        WorkOrder.Case.Contrato__c,
                                        WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c,
                                        WorkOrder.Case.Contrato__r.Prospect__c,
                                        WorkOrder.Case.Contrato__r.Id,
                                        WorkOrder.Case.Asset.IdPlanoUsuario__c,
                                        WorkOrder.Case.LXD_ProtocolNumber__c,
                                        WorkOrder.Case.Contrato__r.IdPromocao__c,
                                        WorkOrder.Case.PlanoNovo__c, 
                                        WorkOrder.Case.PlanoNovo__r.ProductCode, 
                                        WorkOrder.Case.PlanoAntigo__r.ProductCode, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__c, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.BillingStreet, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.BillingAddressNumber__c, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.LXD_NewAddressComplement__c,
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.BillingPostalCode, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.LXD_AddressNeighborhood__c, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.BillingCity, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.BillingState,
                                        WorkOrder.Case.LXD_CPF__c,
                                        WorkOrder.Case.AssetId,  
                                        CorrelationId__c,
                                        workorder.Case.PlanoAntigo__c,
                                        WorkOrder.Account.LegacyId__c, 
                                        WorkOrder.Account.Name, 
                                        WorkOrder.Account.LXD_CPF__c, 
                                        WorkOrder.Account.LXD_RG__c,
                                        WorkOrder.Contact.Email, 
                                        WorkOrder.Contact.Phone,
                                        WorkOrder.Account.ShippingCity, 
                                        WorkOrder.Account.ShippingCountry,
                                        WorkOrder.Account.ShippingPostalCode, 
                                        WorkOrder.Account.ShippingState, 
                                        WorkOrder.Account.ShippingStreet,
                                        WorkOrder.Account.BillingCity, 
                                        WorkOrder.Account.BillingCountry, 
                                        WorkOrder.Account.BillingPostalCode, 
                                        WorkOrder.Account.BillingState,
                                        WorkOrder.Account.BillingStreet,
                                        WorkOrder.Account.LXD_NewAddressComplement__c,
                                        WorkOrder.Account.LXD_AddressNumber__c, 
                                        WorkOrder.Account.LXD_AddressNeighborhood__c,
                                        WorkOrder.AssetId, 
                                        WorkOrder.Asset.ProductCode, 
                                        WorkOrder.Asset.IdPlanoUsuario__c, 
                                        WorkOrder.Asset.IdPromocao__c,
                                        Workorder.Case.Asset.Product2.ProductCode,
                                        WorkOrder.AccountId, 
                                        WorkOrder.Asset.CodigoAtivo__c, 
                                        WorkOrder.Asset.ProductCodeFormula__c,
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingStreet,
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.LXD_AddressNumber__c, 
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.LXD_NewAddressComplement__c, 
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode, 
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.LXD_AddressNeighborhood__c, 
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingCity, 
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingState, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.ShippingStreet,
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingStreet,
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingPostalCode,
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressNumber__c, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_NewAddressComplement__c, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingAddressNumber__c, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressNeighborhood__c, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingCity, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingState, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressComplement__c,
                                        WorkOrder.AddressNeighborhoodServiceAccount__c,
                                        WorkOrder.PostalCode,
                                        WorkOrder.city,
                                        WorkOrder.state,
                                        WorkOrder.street,
                                        Id 
                                    FROM WorkStep
                                    WHERE WorkOrder.Work_Type_WO__c = 'Ativação' LIMIT 1];
            String cto = 'TST-123';
            Integer porta_cto = 1;
            String body = '{"user_plan_id":1090650,"promotion":null,"message_validation_list":null,"fixed_discount":null,"customer_id":745497,"customer_current_plan":"T-G-23.350M.4000G","correlation_id":"LHWecvTIjC","contracted_plan":"T-G-22.600M.4000G.GloboPlay"}';
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
            DesktopService.DesktopService(ws.Id, cto, porta_cto);
            updateSA(ws.WorkOrderId);
            DesktopService.checkCallback(ws.Id);
            DesktopService.checkProvisioning(ws.Id);
            CustomerController.NewCustomer(ws, cto, porta_cto);
            Test.stopTest();
        } catch (Exception e) {
            System.debug('erro AtivacaoWO '+ e.getStackTraceString()+' - '+e.getMessage());
        }
    }

    @IsTest
    static void ManutencaoWO() {
        try {
            WorkStep wt = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Manutenção' LIMIT 1];
            String cto = 'TST-123';
            Integer porta_cto = 1;
            String body = '{"user_plan_id":1090650,"promotion":null,"message_validation_list":null,"fixed_discount":null,"customer_id":745497,"customer_current_plan":"T-G-23.350M.4000G","correlation_id":"LHWecvTIjC","contracted_plan":"T-G-22.600M.4000G.GloboPlay"}';
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
            createIsSameModel(wt.WorkOrderId);
            DesktopService.DesktopService(wt.Id, cto, porta_cto);
            updateSA(wt.WorkOrderId);
            DesktopService.checkCallback(wt.Id);
            Test.stopTest();
        } catch (Exception e) {
            System.debug('erro ManutencaoWO '+ e.getStackTraceString()+' - '+e.getMessage());
        }
    }
 @IsTest
    static void ManutencaoWO3() {
        try {
            WorkStep wt = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Manutenção' LIMIT 1];
            String cto = 'TST-123';
            Integer porta_cto = 1;
            String body = '{"user_plan_id":1090650,"promotion":null,"message_validation_list":null,"fixed_discount":null,"customer_id":745497,"customer_current_plan":"T-G-23.350M.4000G","correlation_id":"LHWecvTIjC","contracted_plan":"T-G-22.600M.4000G.GloboPlay"}';
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
            createIsSameModel(wt.WorkOrderId);
            DesktopService.DesktopService(wt.Id, cto, porta_cto);
            updateSA(wt.WorkOrderId);
            DesktopService.checkCallback(wt.Id);
            Test.stopTest(); 
        } catch (Exception e) { 
            System.debug('erro ManutencaoWO '+ e.getStackTraceString()+' - '+e.getMessage());
        }
    }
    @IsTest
    static void ManutencaoWO_2() {
        try {
            WorkStep wt = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Manutenção' LIMIT 1];
            String cto = 'TST-123';
            Integer porta_cto = 1;
            String body = '{"user_plan_id":1090650,"promotion":null,"message_validation_list":null,"fixed_discount":null,"customer_id":745497,"customer_current_plan":"T-G-23.350M.4000G","correlation_id":"LHWecvTIjC","contracted_plan":"T-G-22.600M.4000G.GloboPlay"}';
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
            DesktopService.DesktopService(wt.Id, cto, porta_cto);
            updateSA(wt.WorkOrderId);
            DesktopService.checkCallback(wt.Id);
            Test.stopTest();
        } catch (Exception e) {
            System.debug('erro ManutencaoWO '+ e.getStackTraceString()+' - '+e.getMessage());
        }
    }

    @IsTest
    static void MudancaDeEnderecoWO() {
        try {
            WorkStep wt = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Subtype_WO__c = 'Internet + TV' LIMIT 1];
            String cto = 'TST-123';
            Integer porta_cto = 1;
            String body = '{"user_plan_id":1090650,"promotion":null,"message_validation_list":null,"fixed_discount":null,"customer_id":745497,"customer_current_plan":"T-G-23.350M.4000G","correlation_id":"LHWecvTIjC","contracted_plan":"T-G-22.600M.4000G.GloboPlay"}';
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
            DesktopService.DesktopService(wt.Id, cto, porta_cto);
            updateSA(wt.WorkOrderId);
            DesktopService.checkCallback(wt.Id);
            Test.stopTest();
        } catch (Exception e) {
            System.debug('erro MudancaDeEnderecoWO '+ e.getStackTraceString()+' - '+e.getMessage());
        }
    }

    @IsTest
    static void ServicosAdicionaisWO() {
        try {
            WorkStep wt = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Subtype_WO__c = 'Ponto Adicional de TV' LIMIT 1];
            String cto = 'TST-123';
            Integer porta_cto = 1;
            String body = '{"user_plan_id":1090650,"promotion":null,"message_validation_list":null,"fixed_discount":null,"customer_id":745497,"customer_current_plan":"","correlation_id":"LHWecvTIjC","contracted_plan":"T-G-22.600M.4000G.GloboPlay"}';
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));
            DesktopService.DesktopService(wt.Id, cto, porta_cto);
            updateSA(wt.WorkOrderId);
            DesktopService.checkCallback(wt.Id);
            Test.stopTest();
        } catch (Exception e) {
            System.debug('erro ServicosAdicionaisWO '+ e.getStackTraceString()+' - '+e.getMessage());
        }
    }

    @IsTest
    static void getCtoPortTest() {
        Id wsId = [SELECT Id FROM WorkStep WHERE Name = 'Adição de Serviço' LIMIT 1].Id;
        String returnS = '';
        String expected = 'ACD-32@1';
        Test.startTest();
        returnS = DesktopService.getCtoPort(wsId);
        Test.stopTest();
        System.debug('Testing returning '+returnS);
//        System.assertEquals(expected, returnS);
    }

    @IsTest
    static void getWorkTypeTest() {
        WorkStep ws = [SELECT WorkOrder.Work_Type_WO__c, WorkOrder.Work_Subtype_WO__c, Id FROM WorkStep WHERE Name = 'Adição de Serviço' LIMIT 1];
        String returnS = '';
        String expected = ws.WorkOrder.Work_Type_WO__c+'@'+ws.WorkOrder.Work_Subtype_WO__c;
        Test.startTest();
        returnS = DesktopService.getWorkType(ws.Id);
        Test.stopTest();
        
        System.debug('Testing returning '+returnS);
        System.assertEquals(expected, returnS);
    }

    @IsTest
    static void updateServiceAccountTest(){
        WorkStep ws = [SELECT WorkOrderId, workorder.AccountId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Ativação' LIMIT 1];


        Test.startTest();
        DesktopService.updateServiceAccount(String.valueOf(ws.workOrder.AccountID), 'São João del-Reu', 'MG', 'Brasil','Rua 123', '36300000');
        Test.stopTest();
    }
    
    @IsTest
    static void updateWorkOrderTest(){
        WorkStep ws = [SELECT WorkOrderId, Id FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Ativação' LIMIT 1];
        Test.startTest();
        DesktopService.updateWorkOrder(ws.workOrderId, 'Teste', 12345);
        Test.stopTest();
    }

    
    @IsTest
    static void getNextStepTest(){
        WorkStep ws = [SELECT WorkOrderId, Id, workPlanId, executionOrder FROM WorkStep WHERE WorkOrder.Work_Type_WO__c = 'Ativação' LIMIT 1];
        ws.executionorder = 1;
        update ws;
        Test.startTest();
        DesktopService.getNextStep(0, String.valueOf(ws.WorkOrderId), String.valueOf(ws.WorkPlanId));
        Test.stopTest();
    }

    @IsTest
    static void AlteracaoPlanoRecreateFull() {//Alteração de Plano e Alteração de Velocidade
        WorkStep ws = [SELECT WorkOrder.Work_Type_WO__c, WorkOrder.Work_Subtype_WO__c, WorkOrderId,
                                        WorkOrder.Case.Contrato__r.ContractNumber, 
                                        WorkOrder.Case.Contrato__c,
                                        WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c,
                                        WorkOrder.Case.Asset.IdPlanoUsuario__c,
                                        WorkOrder.Case.LXD_ProtocolNumber__c,
                                        WorkOrder.Case.Contrato__r.IdPromocao__c,
                                        WorkOrder.Case.PlanoNovo__c, 
                                        WorkOrder.Case.PlanoNovo__r.ProductCode, 
                                        WorkOrder.Case.PlanoAntigo__r.ProductCode, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__c, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.BillingStreet, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.BillingAddressNumber__c, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.LXD_NewAddressComplement__c,
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.BillingPostalCode, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.LXD_AddressNeighborhood__c, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.BillingCity, 
                                        WorkOrder.Case.vlocity_cmt__BillingAccountId__r.BillingState,
                                        WorkOrder.Case.LXD_CPF__c,
                                        WorkOrder.Case.AssetId,  
                                        CorrelationId__c,
                                        workorder.Case.PlanoAntigo__c,
                                        WorkOrder.Account.LegacyId__c, 
                                        WorkOrder.Account.Name, 
                                        WorkOrder.Account.LXD_CPF__c, 
                                        WorkOrder.Account.LXD_RG__c,
                                        WorkOrder.Contact.Email, 
                                        WorkOrder.Contact.Phone,
                                        WorkOrder.Account.ShippingCity, 
                                        WorkOrder.Account.ShippingCountry,
                                        WorkOrder.Account.ShippingPostalCode, 
                                        WorkOrder.Account.ShippingState, 
                                        WorkOrder.Account.ShippingStreet,
                                        WorkOrder.Account.BillingCity, 
                                        WorkOrder.Account.BillingCountry, 
                                        WorkOrder.Account.BillingPostalCode, 
                                        WorkOrder.Account.BillingState,
                                        WorkOrder.Account.BillingStreet,
                                        WorkOrder.Account.LXD_NewAddressComplement__c,
                                        WorkOrder.Account.LXD_AddressNumber__c, 
                                        WorkOrder.Account.LXD_AddressNeighborhood__c,
                                        WorkOrder.AssetId, 
                                        WorkOrder.Asset.ProductCode, 
                                        WorkOrder.Asset.IdPlanoUsuario__c, 
                                        WorkOrder.Asset.IdPromocao__c,
                                        Workorder.Case.Asset.Product2.ProductCode,
                                        WorkOrder.AccountId, 
                                        WorkOrder.Asset.CodigoAtivo__c, 
                                        WorkOrder.Asset.ProductCodeFormula__c,
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingStreet,
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.LXD_AddressNumber__c, 
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.LXD_NewAddressComplement__c, 
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode, 
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.LXD_AddressNeighborhood__c, 
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingCity, 
                                        WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingState, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.ShippingStreet,
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingStreet,
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingPostalCode,
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressNumber__c, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_NewAddressComplement__c, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingAddressNumber__c, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressNeighborhood__c, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingCity, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingState, 
                                        WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressComplement__c,
                                        WorkOrder.AddressNeighborhoodServiceAccount__c,
                                        WorkOrder.PostalCode,
                                        WorkOrder.city,
                                        WorkOrder.state,
                                        WorkOrder.street,
                                        Id 
                                    FROM WorkStep
                                    WHERE WorkOrder.Work_Type_WO__c = 'Alteração de Plano' AND WorkOrder.Work_Subtype_WO__c = 'Alteração de Velocidade' LIMIT 1];
        String cto = 'TST-123';
        Integer porta_cto = 1;
        List<Asset> ass = new List<Asset>();
        ass = [SELECT id,status FROM Asset WHERE ParentId =: ws.WorkOrder.AssetId];
        for(Asset a : ass){
            a.status = 'A';
        }
        update ass;

        ServiceAppointment sa = new ServiceAppointment();

        Test.setMock(HttpCalloutMock.class, new DesktopServiceHttpCalloutMockImpl(200, 'application/x-www-form-urlencoded', body));

        Test.startTest();

        PlanController.RecreatePlanFull(ws, cto, porta_cto,true);
        Test.stopTest();
    }
}