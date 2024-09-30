public with sharing class PlanController {
    static String flow = 'Outbound';
    static List<String> MessageValidationList = new List<String>();

    public static PlanWrapper RecreatePlan(WorkStep ws, String cto, Integer porta, Boolean IsChangePlan) {
        try {
            System.debug('portaa '+porta);
            System.debug('cto->> '+cto);
            Id commercialAssetId = ws.WorkOrder.AssetId;
            String ContractId, AtivoOnu = '', AtivoRouter = null, contractedPlan, clientActualPlan;
            Double UserPlanId, Promotion;
            Integer ReferenceNumber, promtion;
            String CorrelationId, ProductCode, PlanCategory = null;
            List<String> ativosStbList = new List<String>();
            List<Integer> aditionalList = new List<Integer>();
            Boolean moreThanOneAditional = false;
            List<String> tipoAtivoList = new List<String>{'onu','R','SB','ONU','Roteador','STB'};

            PlanWrapper planoW = new PlanWrapper();
            User currentUser = [SELECT FirstName, LastName FROM User WHERE id =: UserInfo.getUserId()];

            ServiceAppointment serviceApp = [SELECT AppointmentNumber, workorder__r.Case.Asset.Product2.ProductCode, WorkOrder__c, CorrelationId__c, WorkOrder__r.AccountId, WorkOrder__r.Work_Type_WO__c, TechnicianName__c,WorkOrder__r.Work_Subtype_WO__c, TechniciansCompany__c,WorkOrder__r.case.AssetId 
                                                FROM serviceAppointment WHERE WorkOrder__c = :ws.workOrderId Limit 1];
            List<String> listAssetId = new List<String>();
            listAssetId.add(String.valueOf(commercialAssetId));
            if(!listAssetId.contains(String.valueOf(serviceApp.WorkOrder__r.case.AssetId)) && (serviceApp.WorkOrder__r.Work_Subtype_WO__c == 'Ponto Adicional de TV' || serviceApp.WorkOrder__r.Work_Subtype_WO__c == 'Adição de Serviço')){
                listAssetId.add(String.valueOf(serviceApp.WorkOrder__r.case.AssetId));
            }
            try {
                List<Asset> assetList = new List<Asset>();
                //SE NÃO HOUVER ALTERAÇÃO DE PLANO PEGAR TODOS OS ASSETS ASSOCIADOS
                if(IsChangePlan == false){
                    assetList = [SELECT id, Name,  Status, Account.Name, CodigoAtivo__c, TipoAtivo__c, ProductCodeFormula__c, Parent.CategoriaPlano__c, IdPlanoAdicional__c FROM Asset where ParentId IN :listAssetId AND TipoAtivo__c in :tipoAtivoList AND (Status = 'L' OR Status = 'A')];
                }else{
                    assetList = [SELECT id, Name,  Status, Account.Name, CodigoAtivo__c, TipoAtivo__c, ProductCodeFormula__c, Parent.CategoriaPlano__c, IdPlanoAdicional__c FROM Asset where ParentId IN : listAssetId AND TipoAtivo__c in :tipoAtivoList AND Status = 'L'];              
                }

                // TODO SE NÃO ENCONTRAR REGISTRO, RETORNAR MENSAGEM: 'Não encontrado(s) equipamento(s) para provisionar.'
                if (assetList.size() == 0) {
                    if (serviceApp.WorkOrder__r.Work_Type_WO__c == 'Mudança de endereço') {
                        assetList = [SELECT id, Name,  Account.Name, CodigoAtivo__c, TipoAtivo__c, ProductCodeFormula__c, Parent.CategoriaPlano__c, IdPlanoAdicional__c FROM Asset where ParentId = :commercialAssetId AND TipoAtivo__c in :tipoAtivoList AND Status = 'A'];                        
                        if (assetList.size() == 0) {
                            System.debug('NÃO encontrado ativos com status L e A para provisionar');
                            MessageValidationList.add('Não encontrado(s) equipamento(s) para provisionar.');
                        }
                    } else if (serviceApp.WorkOrder__r.Work_Type_WO__c == 'Alteração de Plano' || serviceApp.WorkOrder__r.Work_Subtype_WO__c == 'Ponto Adicional de TV') {
                        System.debug('Alteração de plano');
                        commercialAssetId = serviceApp.WorkOrder__r.case.AssetId;
                        assetList = [SELECT id, Name,  Account.Name, CodigoAtivo__c, TipoAtivo__c, ProductCodeFormula__c, Parent.CategoriaPlano__c, IdPlanoAdicional__c FROM Asset where ParentId = :commercialAssetId AND TipoAtivo__c in :tipoAtivoList AND Status = 'A'];                        
                    }else {
                        MessageValidationList.add('Não encontrado(s) equipamento(s) para provisionar.');
                    }
                }
                if(assetList.size() > 0) {
                    for (Asset a : assetList) {
                        System.debug(a.TipoAtivo__c+' ProductCodeFormula__c '+a.ProductCodeFormula__c);
                        if (a.TipoAtivo__c == 'onu' || a.TipoAtivo__c == 'ONU') {
                            AtivoOnu = a.CodigoAtivo__c;
                            PlanCategory = a.Parent.CategoriaPlano__c;
                        }
                        if (a.TipoAtivo__c == 'R' || a.TipoAtivo__c == 'r' || a.TipoAtivo__c == 'Roteador') {
                            AtivoRouter = a.CodigoAtivo__c;
                            PlanCategory = a.Parent.CategoriaPlano__c;    
                        }
                        if (a.CodigoAtivo__c != null && (a.TipoAtivo__c == 'SB' || a.TipoAtivo__c == 'sb' || a.TipoAtivo__c == 'STB')) {
                            PlanCategory = a.Parent.CategoriaPlano__c;
                            ativosStbList.add(a.CodigoAtivo__c);
                            
                            if(moreThanOneAditional == true){
                                
                                aditionalList.add(1);
                            }
                            moreThanOneAditional = true;
                        }
                        System.debug('PlanCategory@# '+PlanCategory);
                    }
                    System.debug('ativo onu '+AtivoOnu+' AtivoRouter '+AtivoRouter);
                }
            } catch (Exception e) {
                System.debug('erro ao obter assets '+e.getMessage()+' '+e.getStackTraceString());
            }

            try {
                if(ws.workorder.Case.PlanoAntigo__c == null || String.valueOf(ws.workorder.Case.PlanoAntigo__c) == '' || serviceApp.WorkOrder__r.Work_Subtype_WO__c == 'Ponto Adicional de TV'){
                    System.debug('Client ActualPlan 1 -> ' + ws.workorder.Case.Asset.Product2.ProductCode);
                    clientActualPlan = ws.workorder.Case.Asset.Product2.ProductCode.replace('PA-','').replace('SVA-','');
                }else{
                    System.debug('Client ActualPlan 2 -> ' + ws.workorder.Case.PlanoAntigo__r.ProductCode);
                    clientActualPlan = ws.workorder.Case.PlanoAntigo__r.ProductCode.replace('PA-','').replace('SVA-','');

                }
            } catch (Exception e) {
                System.debug('Erro ao obter plato atual em workorder.Case.PlanoAntigo__r.ProductCode '+e.getMessage() + e.getStackTraceString());
            }
            
            if (IsChangePlan) {
                try {
                    contractedPlan = ws.WorkOrder.Case.PlanoNovo__r.ProductCode.replace('PA-','').replace('SVA-','');
                } catch (Exception e) {
                    MessageValidationList.add('Campo \'Plano Novo\' em Caso obrigatório.');
                }
            } else {
                try {
                    contractedPlan = ws.WorkOrder.Asset.ProductCodeFormula__c;
                } catch (Exception e) {
                    MessageValidationList.add('Campo \'Product Code Formula\' em Ativo obrigatório.');
                }
            }
            //Integer ContractReferenceNumber = getIntegerValue(ws.WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 'Contract Reference Number em Contrato', false, true);
            //Integer ContractReferenceNumber = ws.WorkOrder.Case.Contrato__r.Prospect__c != '' ? getIntegerValue(ws.WorkOrder.Case.Contrato__r.Prospect__c, 'Prospect em Contrato',  false,true) : getIntegerValue(ws.WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 'Contract Reference Number em Contrato',  false,true);

            
            Integer ContractReferenceNumber;
            if(ws.WorkOrder.Case.Contrato__r.Prospect__c == '' || ws.WorkOrder.Case.Contrato__r.Prospect__c == null){
                ContractReferenceNumber = 1;
            }else{
                ContractReferenceNumber = getIntegerValue(ws.WorkOrder.Case.Contrato__r.Prospect__c, 'Prospect em Contrato', false, true);

            }

            planoW.correlation_id           = serviceApp.CorrelationId__c;
            planoW.customer_id              = ContractReferenceNumber;
            planoW.user_plan_id             = getIntegerValue(String.valueOf(ws.WorkOrder.Case.Asset.IdPlanoUsuario__c), 'IdPlanoUsuario', false, true);
            planoW.contracted_plan          = contractedPlan;
            planoW.client_actual_plan       = clientActualPlan;
            planoW.contract_id              = ContractReferenceNumber;
            planoW.employee                 = currentUser.FirstName + ' '+ currentUser.LastName;
            planoW.ativo_onu                = AtivoOnu;
            planoW.ativo_router             = AtivoRouter;
            planoW.ativos_stb               = ativosStbList;
            planoW.aditional                = aditionalList;
            planoW.fixed_discount           = null;
            planoW.promotion                = ws.WorkOrder.Asset.IdPromocao__c == null ? null : getIntegerValue(String.valueOf(ws.WorkOrder.Asset.IdPromocao__c), 'IdPromocao',false, false);
            planoW.cto                      = cto.ToUpperCase().replace(' ','');
            planoW.cto_port                 = String.valueOf(porta);
            planow.origem                   = 'SALESFORCE';
  

            RequiredFields(planoW, IsChangePlan);

            planoW.message_validation_list = MessageValidationList;
            	
            return planoW;
        } catch (Exception e) {
          //  String MessageValidation = 'Erro ao obter dados do plano: '+ e.getMessage() + ' - '+e.getStackTraceString() + '. WorkOrderId '+ws.workOrderId;
          //  System.debug(MessageValidation);
            Util.insertLogValidation('Erro ao obter dados do plano: '+ e.getMessage() + ' - '+e.getStackTraceString() + '. WorkOrderId '+ws.workOrderId, 'Desktop Service', 'Erro ao enviar dados', 'Erro', flow);
            return null;
        }
    }

    private static void RequiredFields(PlanWrapper nc, Boolean IsChangePlan){
        if (nc.contracted_plan == null || nc.contracted_plan == '') {
            if (IsChangePlan) {
                MessageValidationList.add('Campo \'Código do equipamento\' em Product2 obrigatório.');
            } else {
                MessageValidationList.add('Campo \'Product Code Formula\' em Ativo obrigatório.');
            }
        }
        // if (nc.client_actual_plan == null) 
        //     MessageValidationList.add('Campo ProductCode em Workorder.Case.PlanoAntigo__r obrigatório');
        if (nc.contract_id == null || nc.customer_id == null) 
            MessageValidationList.add('Campo vlocity_cmt__ContractReferenceNumber__c obrigatório.');
        if (nc.employee == null || nc.employee == '') 
            MessageValidationList.add('Campo Name de Usuário obrigatório.');
        if (nc.ativo_onu == null || nc.ativo_onu == '') 
            MessageValidationList.add('Campo Codigo Ativo para o tipo de ativo onu obrigatório.');  
        if (nc.user_plan_id == null) 
            MessageValidationList.add('Campo IdPlanoUsuario para o ativo comercial obrigatório.');  
    }

    private static Integer getIntegerValue(String valueToInteger, String fieldName, Boolean isObj, Boolean isRequired) {
        try {
            Integer value;
            if (isObj) {
                value = Integer.valueOf((Object)valueToInteger.replaceAll('[^0-9]', ''));
            } else {
                value = Integer.valueOf(valueToInteger.replaceAll('[^0-9]', ''));
            }
            return value;
        } catch (Exception e) {
            System.debug('Erro ao converter valor para Integer '+valueToInteger + ' - '+fieldName+' - '+e.getMessage() + ' - '+e.getStackTraceString());
            if (isRequired)
                MessageValidationList.add('Valor inválido para número: '+valueToInteger+'. Campo '+fieldName+'.');
            return null;
        }
    }

    /*private static Long getLongValue(String v, String fieldName) {
        try {
            Long value = Long.valueOf(v.replaceAll('[^0-9]', ''));
            return value;
        } catch (Exception e) {
            System.debug('Erro ao converter valor '+v+'. Campo '+fieldName+'. '+e.getMessage() + ' '+e.getStackTraceString());
            MessageValidationList.add('Valor inválido para número: '+v+'. Campo '+fieldName+'.');
            return null;
        }
    }*/

    public static ChangeAddressWrapper RecreatePlanFull(WorkStep ws, String cto, Integer porta, Boolean IsChangePlan){
        try{
            ChangeAddressWrapper pl = new ChangeAddressWrapper();
            
            
            System.debug('portaa '+porta);
            System.debug('cto->> '+cto);
            Id commercialAssetId = ws.WorkOrder.AssetId;
            String ContractId, AtivoOnu = '', AtivoRouter = null, contractedPlan, clientActualPlan;
            Double UserPlanId, Promotion;
            Integer ReferenceNumber, promtion;
            String CorrelationId, ProductCode, PlanCategory = null;
            List<String> ativosStbList = new List<String>();
            List<Integer> aditionalList = new List<Integer>();
            
            Boolean moreThanOneAditional = false;
            List<String> tipoAtivoList = new List<String>{'onu','R','SB','ONU','Roteador','STB'};

            User currentUser = [SELECT FirstName, LastName FROM User WHERE id =: UserInfo.getUserId()];

            ServiceAppointment serviceApp = [SELECT AppointmentNumber, workorder__r.Case.Asset.Product2.ProductCode, WorkOrder__c, CorrelationId__c, WorkOrder__r.AccountId, WorkOrder__r.Work_Type_WO__c, TechnicianName__c, TechniciansCompany__c,WorkOrder__r.case.AssetId
                                                FROM serviceAppointment WHERE WorkOrder__c = :ws.workOrderId Limit 1];
            try {
                List<Asset> assetList = new List<Asset>();
                //SE NÃO HOUVER ALTERAÇÃO DE PLANO PEGAR TODOS OS ASSETS ASSOCIADOS
                if(IsChangePlan == false){
                    assetList = [SELECT id, Name,  Status, Account.Name, CodigoAtivo__c, TipoAtivo__c, ProductCodeFormula__c, Parent.CategoriaPlano__c, IdPlanoAdicional__c FROM Asset where ParentId = :commercialAssetId AND TipoAtivo__c in :tipoAtivoList AND (Status = 'L' OR Status = 'A')];
                }else{
                    assetList = [SELECT id, Name,  Status, Account.Name, CodigoAtivo__c, TipoAtivo__c, ProductCodeFormula__c, Parent.CategoriaPlano__c, IdPlanoAdicional__c FROM Asset where ParentId = :commercialAssetId AND TipoAtivo__c in :tipoAtivoList AND Status = 'L'];              
                }

                // TODO SE NÃO ENCONTRAR REGISTRO, RETORNAR MENSAGEM: 'Não encontrado(s) equipamento(s) para provisionar.'
                if (assetList.size() == 0) {
                    if (serviceApp.WorkOrder__r.Work_Type_WO__c == 'Mudança de endereço') {
                        assetList = [SELECT id, Name,  Account.Name, CodigoAtivo__c, TipoAtivo__c, ProductCodeFormula__c, Parent.CategoriaPlano__c, IdPlanoAdicional__c FROM Asset where ParentId = :commercialAssetId AND TipoAtivo__c in :tipoAtivoList AND Status = 'A'];                        
                        if (assetList.size() == 0) {
                            System.debug('NÃO encontrado ativos com status L e A para provisionar');
                            MessageValidationList.add('Não encontrado(s) equipamento(s) para provisionar.');
                        }
                    } else if (serviceApp.WorkOrder__r.Work_Type_WO__c == 'Alteração de Plano') {
                        System.debug('Alteração de plano');
                        commercialAssetId = serviceApp.WorkOrder__r.case.AssetId;
                        assetList = [SELECT id, Name,  Account.Name, CodigoAtivo__c, TipoAtivo__c, ProductCodeFormula__c, Parent.CategoriaPlano__c, IdPlanoAdicional__c FROM Asset where ParentId = :commercialAssetId AND TipoAtivo__c in :tipoAtivoList AND Status = 'A'];                        
                    }else {
                        MessageValidationList.add('Não encontrado(s) equipamento(s) para provisionar.');
                    }
                }
                if(assetList.size() > 0) {
                    for (Asset a : assetList) {
                        System.debug(a.TipoAtivo__c+' ProductCodeFormula__c '+a.ProductCodeFormula__c);
                        if (a.TipoAtivo__c == 'onu' || a.TipoAtivo__c == 'ONU') {
                            AtivoOnu = a.CodigoAtivo__c;
                            PlanCategory = a.Parent.CategoriaPlano__c;
                        }
                        if (a.TipoAtivo__c == 'R' || a.TipoAtivo__c == 'r' || a.TipoAtivo__c == 'Roteador') {
                            AtivoRouter = a.CodigoAtivo__c;
                            PlanCategory = a.Parent.CategoriaPlano__c;    
                        }
                        if (a.CodigoAtivo__c != null && (a.TipoAtivo__c == 'SB' || a.TipoAtivo__c == 'sb' || a.TipoAtivo__c == 'STB')) {
                            //PlanCategory = a.ProductCodeFormula__c;
                            PlanCategory = a.Parent.CategoriaPlano__c; 
                            ativosStbList.add(a.CodigoAtivo__c);
                            
                            if(moreThanOneAditional == true){
                                
                                aditionalList.add(1);
                            }
                            moreThanOneAditional = true;
                        }
                        System.debug('PlanCategory@# '+PlanCategory);
                    }
                    System.debug('ativo onu '+AtivoOnu+' AtivoRouter '+AtivoRouter);
                }
            } catch (Exception e) {
                System.debug('erro ao obter assets '+e.getMessage()+' '+e.getStackTraceString());
            }

            try {
                if(ws.workorder.Case.PlanoAntigo__c == null || ws.workorder.Case.PlanoAntigo__c == ''){
                    clientActualPlan = ws.workorder.Case.Asset.Product2.ProductCode.replace('PA-','').replace('SVA-','');
                }else{
                    clientActualPlan = ws.workorder.Case.PlanoAntigo__r.ProductCode.replace('PA-','').replace('SVA-','');

                }
            } catch (Exception e) {
                System.debug('Erro ao obter plato atual em workorder.Case.PlanoAntigo__r.ProductCode '+e.getMessage() + e.getStackTraceString());
            }
            
            if (IsChangePlan) {
                try {
                    contractedPlan = ws.WorkOrder.Case.PlanoNovo__r.ProductCode.replace('PA-','').replace('SVA-','');
                } catch (Exception e) {
                    MessageValidationList.add('Campo \'Plano Novo\' em Caso obrigatório.');
                }
            } else {
                try {
                    contractedPlan = ws.WorkOrder.Asset.ProductCodeFormula__c;
                } catch (Exception e) {
                    MessageValidationList.add('Campo \'Product Code Formula\' em Ativo obrigatório.');
                }
            }
            //Integer ContractReferenceNumber = getIntegerValue(ws.WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 'Contract Reference Number em Contrato', false, true);
            //Integer ContractReferenceNumber = ws.WorkOrder.Case.Contrato__r.Prospect__c != '' ? getIntegerValue(ws.WorkOrder.Case.Contrato__r.Prospect__c, 'Prospect em Contrato', false,true) : getIntegerValue(ws.WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 'Contract Reference Number em Contrato', false,true);

            Integer ContractReferenceNumber;
            if(ws.WorkOrder.Case.Contrato__r.Prospect__c == '' || ws.WorkOrder.Case.Contrato__r.Prospect__c == null){
                ContractReferenceNumber = 1;
            }else{
                ContractReferenceNumber = getIntegerValue(ws.WorkOrder.Case.Contrato__r.Prospect__c, 'Prospect em Contrato', false, true);
            }

            pl.correlation_id           = serviceApp.CorrelationId__c;
            pl.customer_id              = ContractReferenceNumber;
            pl.user_plan_id             = getIntegerValue(String.valueOf(ws.WorkOrder.Case.Asset.IdPlanoUsuario__c), 'IdPlanoUsuario', false, true);
            pl.contracted_plan          = contractedPlan;
            pl.client_actual_plan       = clientActualPlan;
            pl.contract_id              = ContractReferenceNumber;
            pl.employee                 = currentUser.FirstName + ' '+ currentUser.LastName;
            pl.ativo_onu                = AtivoOnu;
            pl.ativo_router             = AtivoRouter;
            pl.ativos_stb               = ativosStbList;
            pl.aditional                = aditionalList;
            pl.fixed_discount           = null;
            pl.promotion                = ws.WorkOrder.Asset.IdPromocao__c == null ? null : getIntegerValue(String.valueOf(ws.WorkOrder.Asset.IdPromocao__c), 'IdPromocao',false, false);
            pl.cto                      = cto.ToUpperCase().replace(' ','');
            pl.cto_port                 = String.valueOf(porta);
            pl.origem                   = 'SALESFORCE';

            pl.message_validation_list = MessageValidationList;
            
            //campos recuperados do asset associada à workOrder
            List<String> str = new List<string>();
            str = ws.WorkOrder.street.split(',');
            if(str.size()>1){
                pl.new_installation_number = str[1].deleteWhitespace();
            }
            pl.new_installation_street = str[0];
            pl.new_installation_cep = ws.WorkOrder.PostalCode;
            pl.new_installation_city = ws.WorkOrder.city;
            pl.new_installation_uf = ws.WorkOrder.state;
            pl.new_installation_district = !String.IsEmpty(ws.WorkOrder.AddressNeighborhoodServiceAccount__c) ? ws.WorkOrder.AddressNeighborhoodServiceAccount__c: '';
            pl.new_installation_complement = '';
            pl.new_billing_street = ws.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingStreet;
            pl.new_billing_number = ws.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressNumber__c;
            pl.new_billing_cep = ws.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingPostalCode;
            pl.new_billing_district = !String.IsEmpty(ws.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressNeighborhood__c) ? ws.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressNeighborhood__c : '';
            pl.new_billing_city = ws.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingCity;
            pl.new_billing_uf = ws.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingState;
            pl.new_billing_complement = !String.IsEmpty(ws.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressComplement__c) ? ws.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressComplement__c: '';
        
            return pl;
        }catch (Exception e) {
            String MessageValidation = 'Erro ao obter dados do plano: '+ e.getMessage() + ' - '+e.getStackTraceString() + '. WorkOrderId '+ws.workOrderId;
            System.debug(MessageValidation);
            Util.insertLogValidation(MessageValidation, 'Desktop Service', 'Erro ao enviar dados', 'Erro', flow);
            return null;
        }
    }
}