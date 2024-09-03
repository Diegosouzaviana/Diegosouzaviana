/**
**************************************************************************************************************
* @company          Sys4b
* @author           Guilherme
* @project          DesktopSA
* @name             UpdatePlanSpeedController
* @description      Controller
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2023-09-02   Guilherme                     Initial version. 
******
**/
public with sharing class UpdatePlanSpeedController {
    static List<String> MessageValidationList = new List<String>();
    public static UpdatePlanSpeedWrapper UpdatePlanSpeed(WorkStep ws, Boolean IsChangePlan) {
        try {
            ServiceAppointment serviceApp = [SELECT AppointmentNumber, WorkOrder__c, CorrelationId__c
                                                FROM serviceAppointment WHERE WorkOrder__c = :ws.workOrderId Limit 1];
            String correlationId, contractedPlan;
            vlocity_cmt__ContractLineItem__c contractLI;


            //TODO conferir valor -> WorkOrder__r.Case.PlanoNovo__r.ProductCode.
            //TODO  remover 'PA-' e 'SVA-'
            if (IsChangePlan){
                contractedPlan = ws.WorkOrder.Case.PlanoNovo__r.ProductCode.replace('PA-','').replace('SVA-','');
            }else{
                contractedPlan = ws.WorkOrder.Asset.ProductCodeFormula__c;
            }
            
            //Integer ContractReferenceNumber = getIntegerValue(ws.WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 'Contract Reference Number em Contrato', false, true);
            Integer ContractReferenceNumber = ws.WorkOrder.Case.Contrato__r.Prospect__c != '' ? getIntegerValue(ws.WorkOrder.Case.Contrato__r.Prospect__c, 'Prospect em Contrato', true) : getIntegerValue(ws.WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 'Contract Reference Number em Contrato', true);

            UpdatePlanSpeedWrapper uPWrapper    = new UpdatePlanSpeedWrapper();
            uPWrapper.correlation_id            = serviceApp.CorrelationId__c;
            uPWrapper.user_plan_id              = getIntegerValue(String.valueOf(ws.WorkOrder.Asset.IdPlanoUsuario__c), 'IdPlanoUsuario', true);
            uPWrapper.contracted_plan           = contractedPlan;
            uPWrapper.promotion                 = getIntegerValue(String.valueOf(ws.WorkOrder.Asset.IdPromocao__c), 'Promoção', false);
            uPWrapper.customer_current_plan     = ws.WorkOrder.Asset.ProductCodeFormula__c;
            uPWrapper.customer_id               = ContractReferenceNumber;
            uPWrapper.origem                    = 'SALESFORCE';

            RequiredFields(uPWrapper, IsChangePlan);

            if (MessageValidationList.size() > 0){
                uPWrapper.message_validation_list = MessageValidationList;
            }
            System.debug(uPWrapper);
            return uPWrapper;
        } catch (Exception e) {
            String message = 'Error on UpdatePlanSpeed ' + e.getMessage() + ' ' +e.getStackTraceString();
            System.debug(message);
            Util.insertLogValidation(message, 'Desktop Service', 'Erro UpdatePlanSpeed', 'Erro', 'Outbound');
            return null;        
        }
    }

    private static void RequiredFields(UpdatePlanSpeedWrapper nc, Boolean IsChangePlan){
        System.debug('--------------------------' + IsChangePlan);

        if (nc.contracted_plan == null || nc.contracted_plan == '') {
            if (IsChangePlan) {
                MessageValidationList.add('Campo \'Código do equipamento\' em Product2 obrigatório.');
            } else {
                MessageValidationList.add('Campo \'Product Code Formula\' em Ativo obrigatório.');
            }
        }
        if (nc.customer_current_plan == null || nc.customer_current_plan == '') {
            MessageValidationList.add('Campo \'Product Code Formula\' do Ativo comercial obrigatório.');
        }
    }

    private static Integer getIntegerValue(String valueToInteger, String fieldName, Boolean isRequired) {
        try {
            if (valueToInteger==null){
                return null;
            }
            return Integer.valueOf(valueToInteger.replaceAll('[^0-9]', ''));
        } catch (Exception e) {
            System.debug('Erro ao converter valor para Integer '+valueToInteger + ' '+e.getMessage() + ' '+e.getStackTraceString());
            if (isRequired){
                MessageValidationList.add('Valor inválido para número: '+valueToInteger+'. Campo '+fieldName);
            }
            return null;
        }
    }
}