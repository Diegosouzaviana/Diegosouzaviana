/**
**************************************************************************************************************
* @company          Sys4b
* @author           Guilherme
* @project          DesktopSA
* @name             ProvisioningCertificateController
* @description      Controller
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2023-09-02   Guilherme                     Initial version. 
******
**/

public with sharing class ProvisioningCertificateController {

    public static ProvisioningCertificateWrapper ProvisioningCertificate(Id contractId) {
        IntegrationData__mdt values;
        List<IntegrationData__mdt> integMetadataList = IntegrationData__mdt.getAll().values();
        for (IntegrationData__mdt dataMdt : integMetadataList) {
            if (dataMdt.DeveloperName == 'Desktop_Service') {
                values = dataMdt;
                break;
            }
        }

        ProvisioningCertificateWrapper provisioningCertificate = new ProvisioningCertificateWrapper(
            values.ReferenceMaxSignal__c, //reference_max_signal Valor fixado conforme card DSK00122-82
            values.ReferenceSignalTolerance__c, //reference_signal_tolerance Valor fixado conforme card DSK00122-82
            Integer.valueOf(values.CtoClientThreshold__c), //cto_client_threshold Valor fixado conforme card DSK00122-82
            null,
            values.SecondValidationKeyActivated__c, //Botão para Ativação da chave de Segunda Validação. conforme card DSK00122-461
            'SALESFORCE'
        );
system.debug('response aqui' + provisioningCertificate);
        return provisioningCertificate;
    }

    @AuraEnabled
    public static ResponseWrapper integrate(Id workStepId,Boolean isTest) {
        ResponseWrapper response = new ResponseWrapper();
        WorkStep workStep = [Select WorkOrderId,Status,WorkOrder.Asset.IdPlanoUsuario__c From WorkStep Where Id = :workStepId Limit 1];
        ServiceAppointment serviceAppointment = [Select Id,RequestNumber__c,CorrelationId__c,
                CTO_Avg_Signal__c,WorkOrder__r.Case.Contrato__c From ServiceAppointment Where WorkOrder__c = :workStep.workOrderId Limit 1];
        Boolean newCorrelation = false;
        String correlationId;
        if (String.isNotBlank(serviceAppointment.CorrelationId__c)) {
            correlationId = serviceAppointment.CorrelationId__c;
            Integer reqNumber = serviceAppointment.RequestNumber__c == null ? 0 : Integer.valueOf(serviceAppointment.RequestNumber__c);
            serviceAppointment.RequestNumber__c = Double.valueOf(reqNumber + 1);
        } else {
            correlationId = Util.generateRandomString();
            serviceAppointment.CorrelationId__c = correlationId;
            newCorrelation = true;
        }

        ProvisioningCertificateWrapper pcw = ProvisioningCertificate(serviceAppointment.WorkOrder__r.Case.Contrato__c );
        pcw.correlation_id = correlationId;
        pcw.validate_cto_avg_signal = isTest;

        pcw.pu_id = Integer.valueOf(workStep.WorkOrder.Asset.IdPlanoUsuario__c);

        String serviceName='Desktop_Service';
        String body = JSON.serialize(pcw);
        String msg = '';
        String queryParams = '/field/v1/provision/salesforce/provisioning_certificate';
        HttpResponse res;
        try {
            res = Util.executarHttpRequest(serviceName,  'POST',  body,  120000,queryParams);
            ProvisioningCertificateResponseWrapper responseWrapper = ProvisioningCertificateResponseWrapper.parse(res.getBody()); 
             

            response.message = responseWrapper.message;
            response.success = responseWrapper.message == 'Processing ...';
            if (newCorrelation)
                update serviceAppointment; //Atualiza correlationId

            return response;
        } catch ( Exception e ) {
            
            msg = 'ProvisioningCertificateController Integrate Error '+e.getMessage() + e.getStackTraceString();
            try {
                IntegrationLog__c log   = new IntegrationLog__c();
                log.ExecutionDate__c    = System.now();
                log.LogDescription__c   = res?.getBody().length() < 128000 ? res?.getBody():res?.getBody().substring(1,128000);
                log.Integration__c      = serviceName.replace('_', ' ');
                log.LogResult__c        = msg.length() < 128000 ? msg:msg.substring(1,128000);
                log.Flow__c             = 'Outbound';
                log.LogStatus__c        = 'Erro';
                log.Name                = 'Erro ao receber/salvar dados de integração';
                insert log;
                response.message = msg;
                response.success = false; 
                return response;  
            } catch (Exception e2) {
                System.debug('Erro ao inserir log de validação: '+e2.getMessage() + ' - '+e2.getStackTraceString());
                response.message = msg;
                response.success = false;
                return response;
            }  
        } 
    }

    @AuraEnabled
    public static ResponseWrapper checkCallback(id workStepId, Boolean block) {
        ResponseWrapper response  = new ResponseWrapper();
        response.success = false;
        try {
            WorkStep workStep = [Select WorkOrderId,Status From WorkStep Where Id = :workStepId Limit 1];
            ServiceAppointment serviceAppointment = [Select 
                    Certificated__c,message_certificate__c,ONU_Signal__c,CTO_Avg_Signal__c
                    From ServiceAppointment 
                    Where WorkOrder__c = :workStep.workOrderId Limit 1
            ];
            String signalValue = serviceAppointment.ONU_Signal__c != null ? String.valueOf(serviceAppointment.ONU_Signal__c) : ' ';
            String avgValue = serviceAppointment.CTO_Avg_Signal__c != null ? String.valueOf(serviceAppointment.CTO_Avg_Signal__c) : ' ';
            if (serviceAppointment.Certificated__c == true && 
                    String.isNotBlank(serviceAppointment.message_certificate__c) && 
                    serviceAppointment.message_certificate__c.toLowerCase().contains('certificado') && block == true) 
            {
                workStep.Status = 'Completed';
                //update workStep;
                response.success = true;
                response.message = 'Equipamento Certificado. Sinal Medido: ' +  signalValue +  ' dBm';
            } else if (serviceAppointment.Certificated__c == false && String.isNotBlank(serviceAppointment.message_certificate__c) ) {
                if (serviceAppointment.message_certificate__c.toLowerCase().contains('sinal fora') && String.isNotBlank(signalValue)) {
                    response.message = 'Nível de sinal fora dos parâmetros técnico. Sinal Medido: ' + signalValue+'.Média de ONUs Conectadas na CTO '+avgValue;
                }  else {
                    response.message = serviceAppointment.message_certificate__c;
                } 
            }else if(serviceAppointment.Certificated__c == true && 
            String.isNotBlank(serviceAppointment.message_certificate__c) && 
            serviceAppointment.message_certificate__c.toLowerCase().contains('certificado') && block == false){

                response.success = true;
                response.message = 'Sinal Medido: ' +  signalValue +  ' dBm';
            }
            return response;
        } catch (Exception e) {
            String errorMsg = 'Error on checkCallback ' + e.getMessage() + ' ' + e.getStackTraceString();
            System.debug(errorMsg);
            throw new AuraException(errorMsg);
        }
    }

    @AuraEnabled
    public static Boolean clearCallbackMessages(Id WorkStepId){
        try {
            WorkStep workStep = [Select WorkOrderId,Status From WorkStep Where Id = :workStepId Limit 1];

            ServiceAppointment sa = [SELECT message_certificate__c,message_recreate_plan__c, message_update_speed__c,
                    ONU_Signal__c,
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
            //sa.sac_login__c = null;
            //sa.sac_password__c = null;
            //sa.wifi_ssid__c = null;
            //sa.wifi_password__c = null;
            update sa;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ResponseWrapper {
        @AuraEnabled public Boolean success {get;set;}
        @AuraEnabled public String message {get;set;}
    }

  
}