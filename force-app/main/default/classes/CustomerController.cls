public with sharing class CustomerController {
    
    static String flow = 'Outbound';
    static List<String> MessageValidationList = new List<String>();

    public static NewCustomerWrapper NewCustomer(WorkStep sa, String cto, Integer porta) {
        try {
            NewCustomerWrapper newCustomerW = new NewCustomerWrapper();
            newCustomerW.message_validation_list = new List<String>();
            Id commercialAssetId = sa.WorkOrder.AssetId;
            String CorrelationId, ServiceAppointmentId, ProductCode = null, PlanCategory = null, TechnicianName = null, TechnicianCompany = null, AtivoOnu, AtivoRouter;
            Long ProtocolNumber;
            Boolean WorkSubtypeContainsTV = false;  //só validar stb se subtipo da workorder igual ou contem TV
            List<String> stbList = new List<String>();
            List<String> tipoAtivoList = new List<String>{'onu', 'R','SB', 'S', 'aditional', 'Roteador','STB'};
            List<Integer> aditionalPlansList = new List<Integer>();
            // TODO -- todos os campos são obrigatórios - há de ser realizado no campos
            // TODO validar tipos de dados - exibir mensagem para o usuário.
            ServiceAppointment serviceApp = [SELECT AppointmentNumber, WorkOrder__c, CorrelationId__c,RequestNumber__c,WorkOrder__r.AccountId,  TechnicianName__c, TechniciansCompany__c, WorkOrder__r.Work_Subtype_WO__c, Id
                                                FROM serviceAppointment WHERE WorkOrder__c = :sa.workOrderId LIMIT 1];

            try {
                if (serviceApp.WorkOrder__r.Work_Subtype_WO__c.contains('TV'))
                    WorkSubtypeContainsTV = true;
                
                List<Asset> assetList = [SELECT id, Name,  Account.Name, CodigoAtivo__c, TipoAtivo__c, Parent.CategoriaPlano__c, ProductCodeFormula__c FROM Asset where ParentId = :commercialAssetId AND TipoAtivo__c in :tipoAtivoList AND Status = 'L'];
                // TODO SE NÃO ENCONTRAR REGISTRO, RETORNAR MENSAGEM: 'Não encontrado(s) equipamento(s) para provisionar.'
                if (assetList.size() == 0) {
                    MessageValidationList.add('Não encontrado(s) equipamento(s) para provisionar.');
                } else {
                    for (Asset a : assetList) {
                        if (a.TipoAtivo__c == 'onu' || a.TipoAtivo__c == 'ONU') {
                            AtivoOnu = a.CodigoAtivo__c;
                            PlanCategory = a.Parent.CategoriaPlano__c;
                        }
                        if (a.TipoAtivo__c == 'R' || a.TipoAtivo__c == 'r' || a.TipoAtivo__c == 'Roteador') {
                            AtivoRouter = a.CodigoAtivo__c;
                            PlanCategory = a.Parent.CategoriaPlano__c;
                        }
                        if (a.CodigoAtivo__c != null && (a.TipoAtivo__c == 'SB' || a.TipoAtivo__c == 'sb' || a.TipoAtivo__c == 'STB'))
                            PlanCategory = a.Parent.CategoriaPlano__c;
                        if (a.TipoAtivo__c == 'S' || a.TipoAtivo__c == 's' || a.TipoAtivo__c == 'STB')
                            stbList.add(a.CodigoAtivo__c);
                        if (a.TipoAtivo__c == 'aditional' || a.TipoAtivo__c == 'ADITIONAL') {
                            try {
                                aditionalPlansList.add(Integer.valueOf(a.CodigoAtivo__c));
                            } catch (Exception e) {
                                System.debug('Erro ao converter '+a.CodigoAtivo__c+' para número: '+e.getMessage()+' - '+e.getStackTraceString());
                                newCustomerW.message_validation_list.add('Erro ao converter '+a.CodigoAtivo__c+' para número. Ativo: '+a.Name);
                            }
                        }
                    }
                }
                System.debug('PlanCategory@# '+PlanCategory);
            } catch (Exception e) {
                System.debug('erro ao obter assets '+e.getMessage()+' '+e.getStackTraceString());
            }
         
            TechnicianName              = serviceApp.TechnicianName__c;
            TechnicianCompany           = serviceApp.TechniciansCompany__c;
            //Integer ContractReferenceNumber = getIntegerValue(ws.WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 'Contract Reference Number em Contrato', false, true);
            
            Integer ContractReferenceNumber;
            if(sa.WorkOrder.Case.Contrato__r.Prospect__c == '' || sa.WorkOrder.Case.Contrato__r.Prospect__c == null){
                ContractReferenceNumber = 1;

            }else{
                ContractReferenceNumber = getIntegerValue(sa.WorkOrder.Case.Contrato__r.Prospect__c, 'Prospect em Contrato', true);

            }

            
            List<String> str = new List<string>();
            str = sa.WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingStreet.contains(',') ? sa.WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingStreet.split(',') : new List<String>{sa.WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingStreet};

            newCustomerW.correlation_id                 = serviceApp.CorrelationId__c;
            newCustomerW.contract_id                    = ContractReferenceNumber;
            newCustomerW.service_order_id               = sa.WorkOrderId;
            newCustomerW.contracted_plan                = sa.WorkOrder.Asset.ProductCodeFormula__c; 
            newCustomerW.plan_category                  = PlanCategory;
            newCustomerW.aditional_plans                = aditionalPlansList; //Id da tabela planos adicionais
            newCustomerW.promotion_id                   = sa.WorkOrder.Asset.IdPromocao__c != null ? getIntegerValue(String.valueOf(sa.WorkOrder.Asset.IdPromocao__c), 'Promoção em Ativo', false) : null;
            newCustomerW.customer_id                    = ContractReferenceNumber;
            newCustomerW.protocol_number                = getLongValue(sa.WorkOrder.Case.LXD_ProtocolNumber__c, 'Protocolo em Caso');
            newCustomerW.customer_full_name             = sa.WorkOrder.Account.Name;
            newCustomerW.customer_main_document         = sa.WorkOrder.Account.LXD_CPF__c != null ? sa.WorkOrder.Account.LXD_CPF__c.replaceAll('[^0-9]', '') : ''; // alterar para WorkOrder.Account.CPF
            newCustomerW.customer_secondary_document    = sa.WorkOrder.Account.LXD_RG__c != null ? sa.WorkOrder.Account.LXD_RG__c : '235060794480';
            newCustomerW.customer_email                 = sa.WorkOrder.Contact.Email;
            newCustomerW.customer_phone                 = getLongValue(sa.WorkOrder.Contact.Phone, 'Telefone comercial em Contato');
            newCustomerW.installation_street            = str[0];
            newCustomerW.installation_number            = sa.WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.LXD_AddressNumber__c;
            newCustomerW.installation_complement        = sa.WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.LXD_NewAddressComplement__c;
            newCustomerW.installation_cep               = sa.WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode != null ? Integer.valueOf(sa.WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode.replaceAll('[^0-9]', '')) : null;
            newCustomerW.installation_district          = sa.WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.LXD_AddressNeighborhood__c;
            newCustomerW.installation_city              = sa.WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingCity;
            newCustomerW.installation_uf                = sa.WorkOrder.Asset.vlocity_cmt__ServiceAccountId__r.ShippingState;
            newCustomerW.billing_street                 = sa.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingStreet;
            newCustomerW.billing_number                 = sa.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressNumber__c;
            newCustomerW.billing_complement             = sa.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_NewAddressComplement__c;
            newCustomerW.billing_cep                    = sa.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingPostalCode != null ? Integer.valueOf(sa.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingPostalCode.replaceAll('[^0-9]', '')) : null;
            newCustomerW.billing_district               = sa.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.LXD_AddressNeighborhood__c;
            newCustomerW.billing_city                   = sa.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingCity;
            newCustomerW.billing_uf                     = sa.WorkOrder.Asset.vlocity_cmt__BillingAccountId__r.BillingState;
            newCustomerW.cto                            = cto.ToUpperCase().replace(' ', '');
            newCustomerW.cto_port                       = String.valueOf(porta);
            newCustomerW.onu                            = AtivoOnu;
            newCustomerW.router                         = AtivoRouter;
            newCustomerW.stb_list                       = stbList;
            newCustomerW.technician_name                = TechnicianName;
            newCustomerW.technician_company             = TechnicianCompany;
            newCustomerW.origem                   = 'SALESFORCE';

            RequiredFields(newCustomerW, WorkSubtypeContainsTV);

            if (MessageValidationList.size() > 0) {
                newCustomerW.message_validation_list = MessageValidationList;
            }
            System.debug('CTO: ' + newCustomerW.onu);

            return newCustomerW;
        } catch (Exception e) {
            String MessageValidation = 'Erro ao obter newCustomer '+ e.getMessage() + ' '+e.getStackTraceString();
            System.debug(MessageValidation);
            Util.insertLogValidation(MessageValidation, 'Desktop Service', 'Erro ao enviar dados', 'Erro', flow);
            return null;
        }
    }

    private static void RequiredFields(NewCustomerWrapper nc, Boolean subtypeTV){
        if (nc.contract_id == null || nc.customer_id == null) 
            MessageValidationList.add('Campo Prospect__c obrigatório.');
        if (nc.contracted_plan == null || nc.contracted_plan == '') 
            MessageValidationList.add('Campo ProductCodeFormula__c do Ativo comercial obrigatório.');
        if (subtypeTV == true && nc.plan_category == null)
            MessageValidationList.add('Campo ProductCodeFormula__c obrigatório para o tipo ativo \'SB\'.');
        if (nc.customer_full_name == null || nc.customer_full_name == '')
            MessageValidationList.add('Campo Nome de Conta obrigatório.');
        if (nc.customer_main_document == null || nc.customer_main_document == '')
            MessageValidationList.add('Campo CPF/CNPJ de Conta obrigatório.');
        if (nc.customer_secondary_document == null || nc.customer_secondary_document == '')
            MessageValidationList.add('Campo RG de Conta obrigatório.');
        if (nc.customer_email == null || nc.customer_email == '')
            MessageValidationList.add('Campo Email de Contato obrigatório.');
        if (nc.customer_phone == null)
            MessageValidationList.add('Campo Telefone comercial de Contato obrigatório.');
        if (nc.installation_street == null || nc.installation_street == '')
            MessageValidationList.add('Campo Rua de entrega de Conta obrigatório.');
        if (nc.installation_number == null || nc.installation_number == '')
            MessageValidationList.add('Campo Número de entrega de Conta obrigatório.');
        if (nc.installation_cep == null)
            MessageValidationList.add('Campo CEP de entrega de Conta obrigatório.');
        if (nc.installation_district == null || nc.installation_district == '')
            MessageValidationList.add('Campo Bairro de entrega de Conta obrigatório.');
        if (nc.installation_city == null || nc.installation_city == '')
            MessageValidationList.add('Campo Cidade de entrega de Conta obrigatório.');
        if (nc.installation_uf == null || nc.installation_uf == '')
            MessageValidationList.add('Campo Estado/Província de entrega de Conta obrigatório.');
        if (nc.billing_street == null || nc.billing_street == '')
            MessageValidationList.add('Campo Rua de cobrança de Conta obrigatório.');
        if (nc.billing_number == null || nc.billing_number == '')
            MessageValidationList.add('Campo \'Endereço Número Billing\' de Conta obrigatório.');
        if (nc.billing_cep == null)
            MessageValidationList.add('Campo \'CEP de cobrança\' de Conta obrigatório.');
        if (nc.billing_district == null || nc.billing_district == '')
            MessageValidationList.add('Campo Bairro obrigatório.');
        if (nc.billing_city == null || nc.billing_city == '')
            MessageValidationList.add('Campo \'Cidade de cobrança\' obrigatório.');
        if (nc.billing_uf == null || nc.billing_uf == '')
            MessageValidationList.add('Campo \'Estado/Província\' de cobrança obrigatório.');
        if (nc.cto == null || nc.cto == '')
            MessageValidationList.add('CTO obrigatório.');
        if (nc.cto_port == null || nc.cto_port == '')
            MessageValidationList.add('PORTA CTO obrigatório.');
        if (nc.onu == null || nc.onu == '')
            MessageValidationList.add('Campo \'Codigo Ativo\' para o tipo de ativo onu obrigatório.');
        if (nc.technician_name == null || nc.technician_name == '')
            MessageValidationList.add('Campo \'Nome do Técnico\' de Compromisso de Serviço obrigatório.');
        if (nc.technician_company == null || nc.technician_company == '')
            MessageValidationList.add('Campo \'Empresa do Técnico\' de Compromisso de Serviço obrigatório.');
    }

    private static Integer getIntegerValue(String valueToInteger, String fieldName, Boolean isObj) {
        try {
            Integer value;
            if (isObj) {
                value = Integer.valueOf((Object)valueToInteger.replaceAll('[^0-9]', ''));
            } else {
                value = Integer.valueOf(valueToInteger.replaceAll('[^0-9]', ''));
            }
            return value;
        } catch (Exception e) {
            System.debug('Erro ao converter valor para Integer '+valueToInteger+'. Campo '+fieldName + ' - '+e.getMessage() + ' '+e.getStackTraceString());
            MessageValidationList.add('Campo '+fieldName+' obrigatório. - Valor inválido para número: '+valueToInteger+'.');
            return null;
        }
    }

    private static Long getLongValue(String v, String fieldName) {
        try {
            Long value = Long.valueOf(v.replaceAll('[^0-9]', ''));
            return value;
        } catch (Exception e) {
            System.debug('Erro ao converter valor '+v+'. Campo '+fieldName+'. '+e.getMessage() + ' '+e.getStackTraceString());
            MessageValidationList.add('Valor inválido para número: '+v+'. Campo '+fieldName+'.');
            return null;
        }
    }
}