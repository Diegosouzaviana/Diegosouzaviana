public class DesktopService {
    
    public static String CorrelationId = null;
    static final String RECREATEPLAN_URI = '/field/v1/provision/salesforce/recreate_plan_full';
    static final String UPDATEPLANSPEED_URI = '/field/v1/provision/salesforce/update_plan_speed';
    static final String NEWCUSTOMER_URI = '/field/v1/provision/salesforce/provision_new_costumer';
    static final String ADDRESSCHANGE_URI = '/field/v1/provision/salesforce/address-change';

    @AuraEnabled(cacheable=false)
    public static String DesktopService(Id WorkStep, String cto, Integer porta_cto) {
        System.debug('porta_cto '+porta_cto);
        String serviceName='Desktop_Service';
        String body=null;
        String method = 'POST';
        Integer timeout=120000;
        String queryParameters=null;
        String msg='';
        String WorkType = null;
        String jsonBody = null;
        String flow = 'Outbound';
        Id WorkOrderId = null;
        HttpResponse res;
        try {
            System.debug('WorkStep '+WorkStep);
            //Select aqui para verificar o tipo de trabalho na work order, passando objeto WorkStep por parametro
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
                                    WHERE Id = :WorkStep];

            BodyRequest bodyReq = getBodyByWorkType(ws, cto, porta_cto);
            body                = bodyReq.body;
            queryParameters     = bodyReq.queryParameters;
            WorkOrderId         = ws.WorkOrderId;

            System.debug('body '+body);
            if (bodyReq.success==false) {
                System.debug('success==false. message: '+bodyReq.message);
                return bodyReq.message;
            }

            if (body!=null) {
                res = Util.executarHttpRequest(serviceName,  method,  body,  timeout, queryParameters);
                System.debug('Response DesktopService : '+ res.getBody());
                if(res.getStatusCode() == 504){
                    //msg='O aprovisionamento está fora do ar, favor entrar em contato com o COP e seguir com as instruções fornecidas.';
                    msg='O aprovisionamento está fora do ar, favor entrar em contato com o Suporte a campo e seguir com as instruções fornecidas.';
                    throw new DesktopException ( msg );
                }else if ( res.getStatusCode() != 200  && res.getStatusCode() != 202 && res.getStatusCode()!=504) {
                    //msg='Erro:Desktop Service não retornou 200. Retornou='+res.getStatusCode()+ res.getBody();
                    msg= 'Sistema indisponível, tente novamente em 2 minutos.';
                    throw new DesktopException ( msg );
                }

                String contentType = res.getHeader('content-type');
                if (!contentType.contains('application/json')) {
                    msg='Erro: Desktop Service não retornou JSON como content type "application/json".Retornou "'+contentType+'"';
                    throw new DesktopException ( msg );
                }
                jsonBody = res.getBody();

                System.debug(jsonBody);
                System.debug('workOrderId '+workOrderId);
                System.debug('correlation_id-> '+CorrelationId);
                saveWO(WorkOrderId, cto, porta_cto);
                updateContract(ws.WorkOrder.Case.Contrato__c);
            }
            return jsonBody;


        } catch ( Exception e ) {
                    
            msg='DesktopService Exception. Erro= '+e.getMessage() + e.getStackTraceString();
            System.debug(msg);
            System.debug('length '+res?.getBody().length());
            
            try {
                
                String logDesc = res?.getBody().length() < 128000 ? res?.getBody():res?.getBody().substring(1,128000);
                Util.insertLogValidation(msg, 'Desktop Service', logDesc, 'Erro', 'Outbound');
                
            } catch (Exception ee) {
                System.debug('Qualquer coisa');
                System.debug('Erro ao inserir log de validação: '+ee.getMessage() + ' - '+ee.getStackTraceString());
            } finally {
                //throw new AuraException ('DesktopService Exception. Erro=  ' + e.getMessage() ); 

            }
            return 'Ocorreu um Erro.  ' + e.getMessage();
        }       
    }
    
    //gravar CTO e porta_cto digitado na workOrder
    private static void saveWO(Id WorkOrderId, String cto, Integer porta_cto) {
        try {
            WorkOrder wo = [SELECT Id, Porta__c, CTO__c FROM WorkOrder WHERE Id =:WorkOrderId];
            wo.CTO__c = cto;
            wo.Porta__c = porta_cto;
            update wo;
        } catch (Exception e) {
            System.debug('Erro ao atualizar WorkOrder: '+e.getMessage() + ' - '+e.getStackTraceString());
        }
    }
    
    // atualizar o contrato de prospect para ativo
    public static void updateContract(String contractId) {
        try{
            // verificar acesso do objeto
            List<Contract> contratos = [Select Id, Status FROM Contract WHERE Status = 'Prospect' AND Id =:contractId]; 
            if (contratos.size()>0){
                System.debug('Contrato que será atualizado para Ativo foi encontrado: ' + contractId);
                contratos[0].Status = 'Ativo';
                update contratos;
            } else if(contractId!=''){
                Contract c = new Contract();
                c.Id = contractId;
                c.status = 'Ativo';
                update c;
            }else{
               System.debug('Não existe contrato em Prospect para ser Ativado');
            }   
        } catch (Exception e) {
            System.debug('Erro ao atualizar Contrato: '+e.getMessage() + ' - '+e.getStackTraceString());    
        } 
    }
    
    
    

    @AuraEnabled
    public static ResponseWrapper checkCallback(id workStepId) {
        ResponseWrapper response = new ResponseWrapper();
        try {
            WorkStep workStep = [Select WorkOrderId,Status From WorkStep Where Id = :workStepId Limit 1];

            ServiceAppointment sa = [SELECT AppointmentNumber, WorkOrder__r.CTO__c,WorkOrder__r.Porta__c, WorkOrder__r.Work_Type_WO__c, Old_Pu_Id__c,
                        WorkOrder__r.Work_Subtype_WO__c, message__c, message_update_speed__c, WorkOrder__c,
                        message_recreate_plan__c,WorkOrder__r.Case.Contrato__c,WorkOrder__r.Case.Contrato__r.Id,WorkOrder__r.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, WorkOrder__r.AssetId,
                        LongUserPlanId__c,PPPOE_Connected__c, StringPPoeUser__c, sac_login__c, workorder__r.Case.PlanoAntigo__c,
                        sac_password__c, wifi_ssid__c, wifi_password__c,ONU_Signal__c, WorkOrder__r.City, WorkOrder__r.Country,
                        WorkOrder__r.State, WorkOrder__r.Street, WorkOrder__r.PostalCode, WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.ShippingCity,
                        WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.ShippingCountry, WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.ShippingState, 
                        WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.ShippingStreet,
                        WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode,WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.Id,
                        WorkOrder__r.Case.Asset.IdPlanoUsuario__c,
                        WorkOrder__r.Case.AssetId,
                        workorder__r.Case.Asset.Product2.ProductCode  
                    FROM serviceAppointment 
                    WHERE WorkOrder__c = :workStep.workOrderId Limit 1
            ];
            System.debug('-----SA -------' + sa.LongUserPlanId__c);
            Boolean IsSameModel = IsSameModel(sa.WorkOrder__c);// obs: if IsSameModel==false is recreate_plan
            if (sa.WorkOrder__r.Work_Type_WO__c=='Alteração de Plano') {
                if(sa.WorkOrder__r.Work_Subtype_WO__c=='Alteração de Velocidade') {
                    if (String.isNotBlank(sa.LongUserPlanId__c) &&
                        String.isNotBlank(sa.StringPPoeUser__c) && 
                        String.isNotBlank(sa.sac_login__c) &&
                        String.isNotBlank(sa.sac_password__c) &&
                        String.isNotBlank(sa.wifi_ssid__c) &&
                        String.isNotBlank(sa.wifi_password__c) 
                    ) {
                        response.success = true;
                        response.callback = sa;
                        workStep.Status = 'Completed';
                        //update workStep;
                        updatePlanUserId(sa.WorkOrder__r.Case.Contrato__c,sa.LongUserPlanId__c);
                        updateAssets(sa.WorkOrder__r.case.AssetId, sa.WorkOrder__r.AssetId, sa.WorkOrder__r.CTO__c,String.valueOf(sa.WorkOrder__r.Porta__c), sa.LongUserPlanId__c, sa.StringPPoeUser__c);
                        updateAdmContract(sa.WorkOrder__r.Case.Contrato__r.Id, sa.sac_login__c);

                    } else if (String.isNotBlank(sa.message_update_speed__c)) {
                        response.success = false;
                        response.message = sa.message_update_speed__c;
                    }
                    System.debug('message_update_speed__c - '+sa.message_update_speed__c);
                } else if(sa.WorkOrder__r.Work_Subtype_WO__c=='Adição de Serviço' || sa.WorkOrder__r.Work_Subtype_WO__c== 'Alteração de Velocidade' ) {
                    if (String.isNotBlank(sa.LongUserPlanId__c) &&
                            String.isNotBlank(sa.StringPPoeUser__c) && 
                            String.isNotBlank(sa.sac_login__c) &&
                            String.isNotBlank(sa.sac_password__c) &&
                            String.isNotBlank(sa.wifi_ssid__c) &&
                            String.isNotBlank(sa.wifi_password__c) &&
                            (IsSameModel==true || (IsSameModel==false && sa.Old_Pu_Id__c != null))
                    ) {
                        response.success = true;
                        response.callback = sa;
                        workStep.Status = 'Completed';
                        //update workStep;
                        updatePlanUserId(sa.WorkOrder__r.Case.Contrato__c,sa.LongUserPlanId__c);
                        if (IsSameModel==false)
                            updateWorkOrder(sa.WorkOrder__c, sa.LongUserPlanId__c, sa.Old_Pu_Id__c);
                        //updateProvisionedAsset(sa.WorkOrder__r.AssetId, false);
                        updateAssets(sa.WorkOrder__r.case.AssetId, sa.WorkOrder__r.AssetId, sa.WorkOrder__r.CTO__c,String.valueOf(sa.WorkOrder__r.Porta__c), sa.LongUserPlanId__c, sa.StringPPoeUser__c);
                        updateAdmContract(sa.WorkOrder__r.Case.Contrato__r.Id, sa.sac_login__c);
                    } else if (String.isNotBlank(sa.message_recreate_plan__c)) {
                        response.success = false;
                        response.message = sa.message_recreate_plan__c;
                    }
                    System.debug('message_recreate_plan__c - '+sa.message_recreate_plan__c);
                }
            } else if(sa.WorkOrder__r.Work_Type_WO__c=='Migração') {
                if(sa.WorkOrder__r.Work_Subtype_WO__c=='Migração entre Empresa' || sa.WorkOrder__r.Work_Subtype_WO__c=='Zhone') {
                    if (String.isNotBlank(sa.LongUserPlanId__c) &&
                            String.isNotBlank(sa.StringPPoeUser__c) && 
                            String.isNotBlank(sa.sac_login__c) &&
                            String.isNotBlank(sa.sac_password__c) &&
                            String.isNotBlank(sa.wifi_ssid__c) &&
                            String.isNotBlank(sa.wifi_password__c) 
                    ) {
                        response.success = true;
                        response.callback = sa;
                        workStep.Status = 'Completed';
                        //update workStep;
                        //updateProvisionedAsset(sa.WorkOrder__r.AssetId, true);
                        updateAssets(sa.WorkOrder__r.case.AssetId, sa.WorkOrder__r.AssetId, sa.WorkOrder__r.CTO__c,String.valueOf(sa.WorkOrder__r.Porta__c), sa.LongUserPlanId__c, sa.StringPPoeUser__c);
                        updateAdmContract(sa.WorkOrder__r.Case.Contrato__r.Id, sa.sac_login__c);
                    } else if (String.isNotBlank(sa.message__c)) {
                        response.success = false;
                        response.message = sa.message__c;
                    }
                }
            } else if(sa.WorkOrder__r.Work_Type_WO__c=='Ativação') {
                if (String.isNotBlank(sa.LongUserPlanId__c) &&
                        String.isNotBlank(sa.StringPPoeUser__c) && 
                        String.isNotBlank(sa.sac_login__c) &&
                        String.isNotBlank(sa.sac_password__c) &&
                        String.isNotBlank(sa.wifi_ssid__c) &&
                        String.isNotBlank(sa.wifi_password__c) 
                ) {
                    response.success = true;
                    response.callback = sa;
                    workStep.Status = 'Completed';
                    //update workStep;
                    updatePlanUserId(sa.WorkOrder__r.Case.Contrato__c,sa.LongUserPlanId__c);
                    //updateProvisionedAsset(sa.WorkOrder__r.AssetId, true);
                    updateAssets(sa.WorkOrder__r.case.AssetId, sa.WorkOrder__r.AssetId, sa.WorkOrder__r.CTO__c,String.valueOf(sa.WorkOrder__r.Porta__c), sa.LongUserPlanId__c, sa.StringPPoeUser__c);
                    updateAdmContract(sa.WorkOrder__r.Case.Contrato__r.Id, sa.sac_login__c);
                } else if (String.isNotBlank(sa.message__c)) {
                    response.success = false;
                    response.message = sa.message__c;
                }
            } else if (sa.WorkOrder__r.Work_Type_WO__c=='Manutenção' || sa.WorkOrder__r.Work_Type_WO__c == 'Mudança de endereço' || sa.WorkOrder__r.Work_Type_WO__c == 'Serviços Adicionais') {
            system.debug(IsSameModel);
                if (String.isNotBlank(sa.LongUserPlanId__c) &&
                        String.isNotBlank(sa.StringPPoeUser__c) && 
                        String.isNotBlank(sa.sac_login__c) &&
                        String.isNotBlank(sa.sac_password__c) &&
                        String.isNotBlank(sa.wifi_ssid__c) &&
                        String.isNotBlank(sa.wifi_password__c) &&
                        (IsSameModel==true || (IsSameModel==false && sa.Old_Pu_Id__c != null))
                ) {
                    response.success = true;
                    response.callback = sa;
                    workStep.Status = 'Completed';
                    //update workStep;
                    updatePlanUserId(sa.WorkOrder__r.Case.Contrato__c,sa.LongUserPlanId__c);
                    if (IsSameModel==false)
                        updateWorkOrder(sa.WorkOrder__c, sa.LongUserPlanId__c, sa.Old_Pu_Id__c); //TODO atualizar pu_id e old_pu_id na WO apenas em recreate plan - checkCallback
                    //updateProvisionedAsset(sa.WorkOrder__r.AssetId, false);// TODO ALTERAR O STATUS DOS ATIVOS PROVISIONADOS PARA ALOCADO (A) - checkCallback
                    updateAssets(sa.WorkOrder__r.case.AssetId, sa.WorkOrder__r.AssetId, sa.WorkOrder__r.CTO__c,String.valueOf(sa.WorkOrder__r.Porta__c), sa.LongUserPlanId__c, sa.StringPPoeUser__c);
                    updateAdmContract(sa.WorkOrder__r.Case.Contrato__r.Id, sa.sac_login__c);
                    if(sa.WorkOrder__r.Work_Type_WO__c == 'Mudança de endereço'){
                        updateServiceAccount(String.valueOf(sa.WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.Id), sa.WorkOrder__r.City,sa.WorkOrder__r.State,sa.WorkOrder__r.Country, sa.WorkOrder__r.Street, sa.WorkOrder__r.PostalCode);
                    }
                } else if (String.isNotBlank(sa.message_recreate_plan__c)) {
                    response.success = false;
                    response.message = sa.message_recreate_plan__c;
                }
                System.debug('message_recreate_plan__c - '+sa.message_recreate_plan__c);
            
            }
            System.debug('ServiceAppointment '+sa.AppointmentNumber +'. WorkType '+sa.WorkOrder__r.Work_Type_WO__c + ' e subtipo '+ sa.WorkOrder__r.Work_Subtype_WO__c);
           
        } catch (Exception e) {
            String errorMsg = 'Error on checkCallback ' + e.getMessage() + ' ' + e.getStackTraceString();
            System.debug(errorMsg);
            response.message = 'Ocorreu um erro!';
        } 

        return response;
    }


    @AuraEnabled 
    public static String getWorkType(id workStepId) {
        WorkStep workStep = [Select WorkOrderId,Status From WorkStep Where Id = :workStepId Limit 1];

        ServiceAppointment sa = [SELECT WorkOrder__r.Work_Type_WO__c, 
                    WorkOrder__r.Work_Subtype_WO__c,
                    WorkOrder__r.case.Asset.IdPlanoUsuario__c
                FROM serviceAppointment 
                WHERE WorkOrder__c = :workStep.workOrderId Limit 1
        ];

        return sa.WorkOrder__r.Work_Type_WO__c+'@'+sa.WorkOrder__r.Work_Subtype_WO__c;
    }

    @AuraEnabled
    public static String getCtoPort(Id workStepId) {
        System.debug('Init getCtoPort');
        String response = '';
        WorkStep workStep = new WorkStep();
        Boolean isWorkStepAccessible = Schema.sObjectType.WorkStep.isAccessible();
        try {
            if(isWorkStepAccessible) {
                workStep = [
                    SELECT 
                        WorkOrder.CTO__c,WorkOrder.Porta__c, WorkOrder.Asset.PortaCTO__c,WorkOrder.Asset.CTO__c, WorkOrder.Asset.CaixaCTO__c, WorkOrder.Asset.SiglaCTO__c 
                    FROM WorkStep 
                    WHERE Id = :workStepId
                ];
            }
            if (
                String.isNotBlank(workStep.WorkOrder.CTO__c)
                && String.isNotBlank(String.valueOf(workStep.WorkOrder.Porta__c))
            ) {
                response = workStep.WorkOrder.CTO__c + '@' + workStep.WorkOrder.Porta__c;
            } else {
                response = '';
            }
        } catch (Exception e) {
            System.debug('erro getCtoPort '+e.getMessage() + ' - '+e.getStackTraceString());
            throw new AuraException(e.getMessage());
        }
        return response;
    }

    public static void updateWorkOrder(String workOrderId, String pu_id, Decimal old_pu_id) {
        try {
            WorkOrder wo = [SELECT PuId__c, OldPuId__c FROM WorkOrder WHERE Id = :workOrderId];
            wo.PuId__c = Decimal.valueOf(pu_id);
            wo.OldPuId__c = old_pu_id;
            update wo;
        } catch (Exception e) {
            System.debug('Erro ao atualizar WO '+ workOrderId + '. '+e.getMessage()+' - '+e.getStackTraceString());
        }
    }

    private static BodyRequest getBodyByWorkType(WorkStep sa, String cto, Integer porta_cto) {
        BodyRequest resp = new BodyRequest();
        resp.success=true;
        resp.message = '';
        try {
            switch on sa.WorkOrder.Work_Type_WO__c { //Tipo de Trabalho
                when 'Alteração de Plano' {
                    switch on sa.WorkOrder.Work_Subtype_WO__c { //Subtipo de Trabalho
                        // TODO Alteração de Velocidade 
                        when 'Adição de Serviço' {
                            PlanWrapper planWrapper = PlanController.RecreatePlan(sa,cto,porta_cto, false);
                            if (planWrapper != null) {
                                if (planWrapper.message_validation_list.size() > 0) {
                                    resp.success = false;
                                    resp.body = null;
                                    resp.message = String.join(planWrapper.message_validation_list, '');
                                } else {
                                    CorrelationId = planWrapper.correlation_id;
                                    resp.body = JSON.serialize(planWrapper);
                                    resp.queryParameters = RECREATEPLAN_URI;
                                }
                            }
                        }
                        when 'Alteração de Velocidade' {
                            if (IsSameModel(sa.WorkOrderId)) {
                                UpdatePlanSpeedWrapper updateSpeedWrapper = UpdatePlanSpeedController.UpdatePlanSpeed(sa, true);
                                if (updateSpeedWrapper != null) {
                                    CorrelationId = updateSpeedWrapper.correlation_id;
                                    resp.body = JSON.serialize(updateSpeedWrapper);
                                    resp.queryParameters = UPDATEPLANSPEED_URI;
                                }
                            } else {
                                PlanWrapper planWrapper = PlanController.RecreatePlan(sa,cto,porta_cto, true);
                                if (planWrapper != null) {
                                    if (planWrapper.message_validation_list.size() > 0) {
                                        resp.success = false;
                                        resp.body = null;
                                        resp.message = String.join(planWrapper.message_validation_list, '');
                                    } else {
                                        CorrelationId = planWrapper.correlation_id;
                                        resp.body = JSON.serialize(planWrapper);
                                        resp.queryParameters = RECREATEPLAN_URI;
                                    }
                                }
                            }
                        }
                        when else {
                            setLogType(sa.WorkOrder.Work_Type_WO__c, sa.WorkOrder.Work_Subtype_WO__c);
                            resp.body = null;
                            resp.queryParameters = null;
                        }
                    }
                }
                when 'Migração' {
                    switch on sa.WorkOrder.Work_Subtype_WO__c {
                        when 'Migração Tecnologia' {
                            if(sa.WorkOrder.case.Asset.IdPlanoUsuario__c == null){
                                NewCustomerWrapper customerWrapper = CustomerController.NewCustomer(sa, cto, porta_cto);
                                if (customerWrapper != null) {
                                    if (customerWrapper.message_validation_list.size() > 0) {
                                        resp.success = false;
                                        resp.body = null;
                                        resp.message = String.join(customerWrapper.message_validation_list, '');
                                    } else {
                                        CorrelationId = customerWrapper.correlation_id;
                                        resp.body = JSON.serialize(customerWrapper);
                                        resp.queryParameters = NEWCUSTOMER_URI;
                                    }
                                }
                            }else{
                                
                                PlanWrapper planWrapper = PlanController.RecreatePlan(sa,cto,porta_cto, false);
                                if (planWrapper != null) {
                                    if (planWrapper.message_validation_list.size() > 0) {
                                        resp.success = false;
                                        resp.body = null;
                                        resp.message = String.join(planWrapper.message_validation_list, '');
                                    } else {
                                        CorrelationId = planWrapper.correlation_id;
                                        resp.body = JSON.serialize(planWrapper);
                                        resp.queryParameters = RECREATEPLAN_URI;
                                    }
                                }
                            }
                        }
                        when 'Migração entre Empresa' {
                            NewCustomerWrapper customerWrapper = CustomerController.NewCustomer(sa, cto, porta_cto);
                            if (customerWrapper != null) {
                                if (customerWrapper.message_validation_list.size() > 0) {
                                    resp.success = false;
                                    resp.body = null;
                                    resp.message = String.join(customerWrapper.message_validation_list, '');
                                } else {
                                    CorrelationId = customerWrapper.correlation_id;
                                    resp.body = JSON.serialize(customerWrapper);
                                    resp.queryParameters = NEWCUSTOMER_URI;
                                }
                            }
                        }
                        when 'Zhone'{
                            PlanWrapper planWrapper = PlanController.RecreatePlan(sa,cto,porta_cto, false);
                                if (planWrapper != null) {
                                    if (planWrapper.message_validation_list.size() > 0) {
                                        resp.success = false;
                                        resp.body = null;
                                        resp.message = String.join(planWrapper.message_validation_list, '');
                                    } else {
                                        CorrelationId = planWrapper.correlation_id;
                                        resp.body = JSON.serialize(planWrapper);
                                        resp.queryParameters = RECREATEPLAN_URI;
                                    }
                                }
                        }

                        when else {
                            setLogType(sa.WorkOrder.Work_Type_WO__c, sa.WorkOrder.Work_Subtype_WO__c);
                            resp.body = null;
                            resp.queryParameters = null;
                        }
                    }
                }
                when 'Ativação' {
                    NewCustomerWrapper customerWrapper = CustomerController.NewCustomer(sa, cto, porta_cto);
                    if (customerWrapper != null) {
                        if (customerWrapper.message_validation_list.size() > 0) {
                            resp.success = false;
                            resp.body = null;
                            resp.message = String.join(customerWrapper.message_validation_list, '');
                        } else {
                            CorrelationId = customerWrapper.correlation_id;
                            resp.body = JSON.serialize(customerWrapper);
                            resp.queryParameters = NEWCUSTOMER_URI;
                        }
                    }
                }
                when 'Manutenção' {
                        PlanWrapper planWrapper = PlanController.RecreatePlan(sa,cto,porta_cto, false);
                        if (planWrapper != null) {
                            if (planWrapper.message_validation_list.size() > 0) {
                                resp.success = false;
                                resp.body = null;
                                resp.message = String.join(planWrapper.message_validation_list, '');
                            } else {
                                CorrelationId = planWrapper.correlation_id;
                                resp.body = JSON.serialize(planWrapper);
                                resp.queryParameters = RECREATEPLAN_URI;
                            }
                        }
                }
                when 'Mudança de endereço' {
                    ChangeAddressWrapper planWrapper = PlanController.RecreatePlanFull(sa,cto,porta_cto, false);
                    //PlanWrapper planWrapper = PlanController.RecreatePlan(sa,cto,porta_cto, false);
                    System.debug('PlanWrapper -> ' + planWrapper);
                    if (planWrapper != null) {
                        if (planWrapper.message_validation_list.size() > 0) {
                            resp.success = false;
                            resp.body = null;
                            resp.message = String.join(planWrapper.message_validation_list, '');
                        } else {
                            CorrelationId = planWrapper.correlation_id;
                            resp.body = JSON.serialize(planWrapper);
                            resp.queryParameters = ADDRESSCHANGE_URI;
                        }
                    }  
                }	
                when 'Serviços Adicionais' {
                    
                    PlanWrapper planWrapper = PlanController.RecreatePlan(sa,cto,porta_cto, false);
                    if (planWrapper != null) {
                        if (planWrapper.message_validation_list.size() > 0) {
                            resp.success = false;
                            resp.body = null;
                            resp.message = String.join(planWrapper.message_validation_list, '');
                        } else {
                            CorrelationId = planWrapper.correlation_id;
                            resp.body = JSON.serialize(planWrapper);
                            resp.queryParameters = RECREATEPLAN_URI;
                        }
                    }
                }
                when else {
                    setLogType(sa.WorkOrder.Work_Type_WO__c, null);
                    resp.body = null;
                    resp.queryParameters = null;
                }
            }
            return resp;
        } catch (Exception e) {
            System.debug('Erro ao obter body WorkType '+e.getMessage() + ' - '+e.getStackTraceString());
            return null;
        }
    }

    private static Boolean IsSameModel(Id WorkOrderId) {
        try {
            List<ProductConsumed> pConsumedList = [SELECT ProductName, Product2.ProductCode,  WorkOrderId, WorkOrder.WorkOrderNumber,  id FROM ProductConsumed WHERE WorkOrderId = :WorkOrderId And Product2.IsSerialized = true And Product2.RecordType.DeveloperName = 'Equipamento'];
            if (pConsumedList.size() > 0) {
                List<String> productCodeList = new List<String>();
                for (ProductConsumed pc : pConsumedList) {
                    productCodeList.add(pc.Product2.ProductCode);
                    System.debug('ProductCode consumed '+pc.Product2.ProductCode);
                }
                List<WorkOrderLineItem> wli =  [SELECT Asset.ProductCodeFormula__c,  id FROM WorkOrderLineItem WHERE WorkOrderId = :WorkOrderId AND Asset.ProductCodeFormula__c IN :productCodeList];
                
                if (wli.size() > 0) {
                    System.debug('returning true. assetList.size() > 0.');
                    return true;
                } else {
                    System.debug('returning false. assetList.size() == 0.');
                    return false;
                }
            }
            System.debug('returnig false. pConsumedList.size() == 0');
            return false;
        } catch (Exception e) {
            System.debug('erro ao verificar ativo consumido '+e.getMessage()+' '+e.getStackTraceString());
            return false;
        }
    }

    @AuraEnabled
    public static Boolean clearCallbackMessages(Id WorkStepId){
        try {
            WorkStep workStep = [Select WorkOrderId,Status From WorkStep Where Id = :workStepId Limit 1];

            ServiceAppointment sa = [SELECT message_certificate__c,message_recreate_plan__c, message_update_speed__c,
                    ONU_Signal__c,correlationId__c,
                    LongUserPlanId__c,PPPOE_Connected__c, StringPPoeUser__c, sac_login__c, sac_password__c, wifi_ssid__c, wifi_password__c
                    FROM serviceAppointment 
                    WHERE WorkOrder__c = :workStep.workOrderId Limit 1
            ];
            sa.message__c = null;
            sa.message_recreate_plan__c = null;
            sa.message_update_speed__c = null;
            sa.message_certificate__c = null;
            sa.ONU_Signal__c = null;
            sa.LongUserPlanId__c = null;
            sa.StringPPoeUser__c = null;
            sa.sac_login__c = null;
            sa.sac_password__c = null;
            sa.wifi_ssid__c = null;
            sa.wifi_password__c = null;
            if (!String.isNotBlank(sa.correlationId__c)) {
                sa.correlationId__c = Util.generateRandomString();
                System.debug('new correlationId__c ' + sa.correlationId__c );
            }
            update sa;
            return true;
        } catch (Exception e) {
            System.debug('Error clearCallbackMessages '+ e.getMessage() + ' ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class BodyRequest {
        public String body;
        public String queryParameters;
        public Boolean success;
        public String message;
    }

    private static void setLogType(String type, String subtype) {
        String MessageValidation;
        if (type != null && subtype != null)
            MessageValidation = 'Type not found: '+type+'. Subtype not found: '+subtype+'.';
        else 
            MessageValidation =  'Type not found: '+type;
        System.debug('Erro ao obter Tipo ou Subtipo de WorkOrder: '+ MessageValidation);
        Util.insertLogValidation(MessageValidation, 'Desktop Service', 'Erro ao enviar dados', 'Erro', 'Outbound');
    }



    @AuraEnabled
    public static string getNextStep(Integer executionOrder, String woId, String workplanId){
        System.debug('executionOrder => ' + executionOrder);
        System.debug('woId => ' + woId);
        System.debug('workPlanId => ' + workplanId);

        try {
            Integer eOrder = executionOrder + 1;
            WorkStep nextStep = new WorkStep();
            nextStep = [SELECT id,ValidationExecutionOrder__c FROM WorkStep WHERE ExecutionOrder =: eOrder AND WorkOrderId =:woId AND WorkPlanId =: workPlanId LIMIT 1];
            System.debug('Next step -> ' + nextStep);
            if(nextStep != null){
                System.debug('Retornando valor => '+ String.valueOf(nextStep.id));
                return String.valueOf(nextStep.id);
            }else{
                System.debug('Retornando nulo ');
                return '';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Novo método para verificar o registro antes de possibilitar um aprovisionamento
    @AuraEnabled
    public static ResponseWrapper checkProvisioning(id workStepId) {
        ResponseWrapper response = new ResponseWrapper();
        try {
            WorkStep workStep = [
                SELECT WorkOrderId, Status, ValidationExecutionOrder__c, ExecutionOrder
                FROM WorkStep
                WHERE Id = :workStepId
                LIMIT 1
            ];

            WorkStep workStep2 = [
                SELECT WorkOrderId, Status, ValidationExecutionOrder__c, ExecutionOrder
                FROM WorkStep
                WHERE ExecutionOrder = :(workStep.ExecutionOrder + 1)
                LIMIT 1
            ];

            ServiceAppointment sa = [SELECT AppointmentNumber, WorkOrder__r.CTO__c,WorkOrder__r.Porta__c, WorkOrder__r.Work_Type_WO__c, Old_Pu_Id__c,
                        WorkOrder__r.Work_Subtype_WO__c, message__c, message_update_speed__c, WorkOrder__c,
                        message_recreate_plan__c,WorkOrder__r.Case.Contrato__c, WorkOrder__r.AssetId,
                        LongUserPlanId__c,PPPOE_Connected__c, StringPPoeUser__c, sac_login__c, workorder__r.Case.PlanoAntigo__c,
                        sac_password__c, wifi_ssid__c, wifi_password__c,ONU_Signal__c, WorkOrder__r.City, WorkOrder__r.Country,
                        WorkOrder__r.State, WorkOrder__r.Street, WorkOrder__r.PostalCode, WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.ShippingCity,
                        WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.ShippingCountry, WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.ShippingState, 
                        WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.ShippingStreet,
                        WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode,WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.Id,
                        WorkOrder__r.Case.Asset.IdPlanoUsuario__c,
                        WorkOrder__r.Case.AssetId,
                        workorder__r.Case.Asset.Product2.ProductCode  
                    FROM serviceAppointment 
                    WHERE WorkOrder__c = :workStep.workOrderId Limit 1
            ];
            System.debug('-----SA -------' + sa.LongUserPlanId__c);
            if (String.isNotBlank(sa.LongUserPlanId__c) &&
                String.isNotBlank(sa.StringPPoeUser__c) && 
                String.isNotBlank(sa.sac_login__c) &&
                String.isNotBlank(sa.sac_password__c) &&
                String.isNotBlank(sa.wifi_ssid__c) &&
                String.isNotBlank(sa.wifi_password__c) 
            ) {
                response.success = true;
                response.callback = sa;
                workStep.Status = 'Completed';

                updateRecords(sa, workStep, workStep2);
                //update workStep;
            } else if (String.isNotBlank(sa.message_update_speed__c)) {
                response.success = false;
                response.message = sa.message_update_speed__c;
            }
        } catch (Exception e) {
            String errorMsg = 'Error on checkCallback ' + e.getMessage() + ' ' + e.getStackTraceString();
            System.debug(errorMsg);
            response.message = 'Ocorreu um erro!';
        } 

        return response;
    }

    public static void updateRecords(ServiceAppointment sa, WorkStep stepProvisioning, WorkStep stepCertificate){
        List<SObject> recordsToUpdate = new List<SObject>();
        
        if(!isAdmContractUpdated(sa.WorkOrder__r.Case.Contrato__c, sa.sac_login__c)){
            recordsToUpdate.add(processAdmContract(sa.WorkOrder__r.Case.Contrato__c, sa.sac_login__c));
        }

        if(!isServiceAccountUpdated(sa.WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.Id, sa.WorkOrder__r.City,sa.WorkOrder__r.State,sa.WorkOrder__r.Country, sa.WorkOrder__r.Street, sa.WorkOrder__r.PostalCode)){
            recordsToUpdate.add(processServiceAccount(String.valueOf(sa.WorkOrder__r.Asset.vlocity_cmt__ServiceAccountId__r.Id), sa.WorkOrder__r.City,sa.WorkOrder__r.State,sa.WorkOrder__r.Country, sa.WorkOrder__r.Street, sa.WorkOrder__r.PostalCode));
        }

        if(!isPlanUserIdUpdated(sa.WorkOrder__r.Case.Contrato__c, sa.LongUserPlanId__c)){
            recordsToUpdate.addAll(processPlanUserId(sa.WorkOrder__r.Case.Contrato__c, sa.LongUserPlanId__c));
        }

        if(!isAssetsUpdated(sa.WorkOrder__r.case.AssetId, sa.WorkOrder__r.AssetId, sa.WorkOrder__r.CTO__c,String.valueOf(sa.WorkOrder__r.Porta__c), sa.LongUserPlanId__c, sa.StringPPoeUser__c)){
            recordsToUpdate.addAll(processAssets(sa.WorkOrder__r.case.AssetId, sa.WorkOrder__r.AssetId, sa.WorkOrder__r.CTO__c,String.valueOf(sa.WorkOrder__r.Porta__c), sa.LongUserPlanId__c, sa.StringPPoeUser__c));
        }

        stepProvisioning.Status = 'Completed';
        recordsToUpdate.add(stepProvisioning);

        stepCertificate.ValidationExecutionOrder__c = true;
        recordsToUpdate.add(stepCertificate);

        update recordsToUpdate;
    }

    public static Boolean isAdmContractUpdated(Id contractId, String adm){
        Contract contract = [
            SELECT Id, vlocity_cmt__ContractReferenceNumber__c
            FROM Contract
            WHERE Id = :contractId
            LIMIT 1
        ];

        return contract.vlocity_cmt__ContractReferenceNumber__c == adm;
    }

    public static void updateAdmContract(String contractId, String adm){
        update processAdmContract(contractId, adm);
    }

    public static Contract processAdmContract(String contractId, String adm){
        Contract ct = new Contract();
        ct.Id = contractId;
        ct.vlocity_cmt__ContractReferenceNumber__c = adm;
        
        return ct;
    }



    public static Boolean isServiceAccountUpdated(Id accId, String city, String state, String country, String street, String postalCode){
        Account acc = [
            SELECT Id,
                ShippingCity,
                ShippingState,
                ShippingCountry,
                ShippingStreet,
                ShippingPostalCode
            FROM Account
            WHERE Id = :accId
            LIMIT 1
        ];

        return (
            acc.ShippingCity == city &&
            acc.ShippingState == state &&
            acc.ShippingCountry == country &&
            acc.ShippingStreet == street &&
            acc.ShippingPostalCode == postalCode
        );
    }

    public static void updateServiceAccount(String acId, String city,String state, String country, String street, String postalCode){
        Database.update(processServiceAccount(acId, city, state, country, street, postalCode), false);
    }

    public static Account processServiceAccount(String acId, String city,String state, String country, String street, String postalCode){
        Account ac = new Account();
        ac.Id = acId;
        ac.ShippingCity = city;
        ac.ShippingCountry = country;
        ac.ShippingState = state;
        ac.ShippingStreet = street;
        ac.ShippingPostalCode = postalCode;
        
        return ac;
    }



    public static Boolean isAssetsUpdated(Id caseAssetId, Id commercialAssetId, String cto, String porta, String plan, String ppoeUser){
        Set<Id> assetIdSet = new Set<Id>{caseAssetId, commercialAssetId};
        Map<Id, Asset> assetMap = new Map<Id, Asset>([
            SELECT Id, 
                Status,
                SiglaCTO__c,
                CaixaCTO__c,
                PortaCTO__c,
                IdPlanoUsuario__c,
                PlanLogin__c,
                ParentId
            FROM Asset
            WHERE ParentId IN :assetIdSet
            OR Id IN :assetIdSet
            WITH SECURITY_ENFORCED
        ]);

        Boolean isUpdated = true;

        Asset oldAsset = assetMap.get(caseAssetId);

        if(caseAssetId != commercialAssetId){
            if(oldAsset.Status != 'B' || oldAsset.vlocity_cmt__Action__c != 'Disconnect'){
                return false;
            }
        }

        Asset commercialAsset = assetMap.get(commercialAssetId);

        if(
            commercialAsset.Status != 'A' ||
            commercialAsset.SiglaCTO__c != (cto.split('-').size()>0 ? cto.split('-')[0] : '') ||
            commercialAsset.CaixaCTO__c != (cto.split('-').size()>0 ? cto.split('-')[1] : '') ||
            commercialAsset.PortaCTO__c != porta ||
            commercialAsset.IdPlanoUsuario__c != Double.valueOf(plan) ||
            commercialAsset.PlanLogin__c != ppoeUser
        ){
            return false;
        }

        for(Asset a : assetMap.values()){
            if(a.Id != caseAssetId && a.Id != commercialAssetId &&
                (a.Status != 'A' ||
                a.PortaCTO__c != porta ||
                a.SiglaCTO__c != (cto.split('-').size()>0 ? cto.split('-')[0] : '') ||
                a.CaixaCTO__c != (cto.split('-').size()>0 ? cto.split('-')[1] : '') ||
                a.IdPlanoUsuario__c != Double.valueOf(plan) ||
                a.ParentId != commercialAssetId ||
                a.PlanLogin__c != ppoeUser)
            ){
                return false;
            }
        }

        return true;
    }

    private static void updateAssets(Id caseAssetId, Id commercialAssetId, String cto, String porta, String plan, String ppoeUser) {
        List<Asset> assetList = processAssets(caseAssetId, commercialAssetId, cto, porta, plan, ppoeUser);

        Database.update(assetList, false);
    }

    private static List<Asset> processAssets(Id caseAssetId, Id commercialAssetId, String cto, String porta, String plan, String ppoeUser) {
        //List<String> tipoAtivoList;
        List<Asset> assetList;
        List<Asset> upAssets = new List<Asset>();
        try {
            //tipoAtivoList = (isNewCustomer) ? new List<String>{'onu', 'R', 'SB', 'S', 'aditional'} : new List<String>{'onu', 'R', 'SB'};
            List<String> listAssetId = new List<String>();
            listAssetId.add(String.valueOf(commercialAssetId));
            if(!listAssetId.contains(String.valueOf(caseAssetId))){
                listAssetId.add(String.valueOf(caseAssetId));
            }
            if(Schema.sObjectType.Asset.isAccessible() && Schema.sObjectType.Asset.isUpdateable()) {
                assetList = [SELECT id, Status FROM Asset WHERE ParentId IN: listAssetId];
            }
            if(caseAssetId != commercialAssetId){
                Asset oldAsset = new Asset();
                oldAsset.Id = caseAssetId;
                oldAsset.vlocity_cmt__DisconnectDate__c = DateTime.now();
                oldAsset.Status = 'B';
                oldAsset.vlocity_cmt__Action__c = 'Disconnect';
                upAssets.add(oldAsset);
            }
            Asset a = new Asset();
            a.Id = commercialAssetId;
            a.Status = 'A';
            //a.CTO__c = cto;
            a.SiglaCTO__c = cto.split('-').size()>0 ? cto.split('-')[0] : '';
            a.CaixaCTO__c = cto.split('-').size()>0 ? cto.split('-')[1] : '';
            a.PortaCTO__c = porta;
            a.IdPlanoUsuario__c = Double.valueOf(plan);
            a.PlanLogin__c = ppoeUser;
            a.InstallDate = Date.today();
            upAssets.add(a);
            for (Asset ass : assetList) {
                if((ass.status == 'L' || ass.status == 'A') && !upAssets.contains(ass)){
                    ass.Status = 'A';
                    //ass.CTO__c = cto;
                    ass.PortaCTO__c = porta;
                    ass.SiglaCTO__c = cto.split('-').size()>0 ? cto.split('-')[0] : '';
                    ass.CaixaCTO__c = cto.split('-').size()>0 ? cto.split('-')[1] : '';
                    ass.IdPlanoUsuario__c = Double.valueOf(plan);
                    ass.ParentId = commercialAssetId;
                    a.PlanLogin__c = ppoeUser;
                    upAssets.add(ass);
                }  
            }
            
            return upAssets;
                
        } catch (Exception e) {
            System.debug('Erro ao alterar status de ativos aprovisionados: '+e.getMessage()+' - '+e.getStackTraceString());
            return new List<Asset>();
        }
    }



    public static Boolean isPlanUserIdUpdated(Id contractId, String planId){
        List<vlocity_cmt__ContractLineItem__c> contractLineItem = [
            SELECT IdPlanoUsuario__c
            FROM vlocity_cmt__ContractLineItem__c 
            WHERE vlocity_cmt__ContractId__c = :contractId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if(!contractLineItem.isEmpty()){
            return contractLineItem[0].IdPlanoUsuario__c == Decimal.valueOf(planId);
        }

        return false;
    }

    private static void updatePlanUserId(String contractId, String planId) {
        List<vlocity_cmt__ContractLineItem__c> contractLI = processPlanUserId(contractId, planId);

        if(!contractLI.isEmpty()){
            update contractLI;
        }
    }

    private static List<vlocity_cmt__ContractLineItem__c> processPlanUserId(String contractId, String planId) {
        List<vlocity_cmt__ContractLineItem__c> contractLi = [
            SELECT IdPlanoUsuario__c
            FROM vlocity_cmt__ContractLineItem__c
            WHERE vlocity_cmt__ContractId__c = :contractId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if(contractLi.size() > 0){
            contractLI[0].IdPlanoUsuario__c = Decimal.valueOf(planId); 
        }

        return contractLi;
    }

    public class ResponseWrapper {
        @AuraEnabled public Boolean success {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public ServiceAppointment callback {get;set;}
    }

    class DesktopException extends Exception {}
}