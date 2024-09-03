public with sharing class ServiceResourceVF {

    public String resourceId {get;set;}//create variables for parameter values and allow access from VF page
    public String selectedVal {get; set;}
    @TestVisible
    public Boolean ButtonDisable = false;
    private Boolean IsRescheduling = true;
    public List<SelectOption> resourceOptions {get;set;}
    static Map<String, String> rescheduleReasonPickList = new Map<String, String>();
    public String reschedulingOrRelocationString {get;set;}
    // Reschedule_Reason_SA__c
    public ServiceResourceVF() {
        resourceId = apexpages.currentpage().getparameters().get('id');//initializing variables to parameter values from the related apex page (VF page that launched via console custom action)
        ServiceAppointment sa  = [SELECT Work_Type_SA__c, AppointmentNumber, Reschedule_Reason_SA__c, ArrivalWindowStartTime, ArrivalWindowEndTime, SchedStartTime, SchedEndTime, Status, Id FROM ServiceAppointment WHERE Id = :resourceId];
        if (sa.SchedStartTime >= sa.ArrivalWindowStartTime && sa.SchedStartTime <= sa.ArrivalWindowEndTime) { //-> Remanejamento
            reschedulingOrRelocationString = 'Motivo de Remanejamento';
            IsRescheduling = false;
            rescheduleReasonPickList = getPickListValues();
            resourceOptions = new list<SelectOption>();
            resourceOptions.add(new selectOption('', 'Selecione um motivo'));
            for (String pickListValue : rescheduleReasonPickList.keySet()) {
                resourceOptions.add(new selectOption(pickListValue, pickListValue));
            }
        } else { //-> Reagendamento
            reschedulingOrRelocationString = 'Motivo de Reagendamento';
            Schema.DescribeFieldResult F = ServiceAppointment.Reschedule_Reason_SA__c.getDescribe();
            Schema.sObjectField T = F.getSObjectField();
            Map<Object,List<String>> getDependenciesListValues = getDependentPicklistValues(T);
            List<String> listValues = getDependenciesListValues.get(sa.Work_Type_SA__c); 
            resourceOptions = new list<SelectOption>();
            resourceOptions.add(new selectOption('', 'Selecione um motivo'));
            for (String pickListValue : listValues) {
                resourceOptions.add(new selectOption(pickListValue, pickListValue));
            }
        }
    }

    public list<SelectOption> getOpenOptions(){
        return resourceOptions;
    }

    public Boolean disableSaveButton {
        get {
           return ButtonDisable;
        }
     }
//condição 
/**
 * 
 * Verificar antes de exibir na tela
 * 
 * Remanejamento
 * SchedStartTime >= ArrivalWindowStartTime && SchedStartTime <= ArrivalWindowEndTime
 * campo a utilizar: ReasonForRelocation__c
 * Não atualizar os campos AppointmentHistory__c e PriorArrivalStart__c
 * 
 * Reagendamento
 * SchedStartTime < ArrivalWindowStartTime || SchedStartTime > ArrivalWindowEndTime
 * Tá pronto!
 */
    public void saveRescheduleReasonValue(){
        try {
            Datetime schedStartDT, schedEndDT;
            if (selectedVal != null) {
                ServiceAppointment serviceA = [SELECT AppointmentNumber, PriorArrivalStart__c, AppointmentHistory__c, Reschedule_Reason_SA__c, ArrivalWindowStartTime, ArrivalWindowEndTime, SchedStartTime, SchedEndTime, Status, Id FROM ServiceAppointment WHERE id = :resourceId];
                if (serviceA.Status == 'Agendado') {
                    if (serviceA.SchedStartTime >= serviceA.ArrivalWindowStartTime && serviceA.SchedStartTime <= serviceA.ArrivalWindowEndTime) {
                        serviceA.ReasonForRelocation__c = selectedVal;
                    } else {                       
                        serviceA.Reschedule_Reason_SA__c  = selectedVal;
                        serviceA.ArrivalWindowStartTime   = serviceA.SchedStartTime.addHours(-1);
                        serviceA.ArrivalWindowEndTime     = serviceA.SchedStartTime.addHours(1);
                        serviceA.AppointmentHistory__c    = 'Reagendado';
                        serviceA.SchedStartTime = serviceA.SchedStartTime.addMinutes(1);
                    }
                    update serviceA;

                    ButtonDisable = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Registro atualizado com sucesso. Clique no X para fechar a tela.'));
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Compromisso de Serviço '+ serviceA.AppointmentNumber + ' não possui status \'Agendado\'. Clique no X para fechar a tela.'));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Selecione um motivo para salvar. Clique no X para fechar a tela.'));
            }
        } catch (Exception e) {
            System.debug('Erro ao atualizar Compromisso de Serviço '+e.getStackTraceString() + ' '+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    //Pass dependent field parameter e.g.: Account.YourDependentField__c
    private static Map<Object,List<String>> getDependentPicklistValues(Schema.sObjectField dependentField){
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        //Get dependent field result
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        //Get dependent field controlling field 
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        //Check controlling field is not null
        System.debug('controllerField-> '+controllerField);  
        if(controllerField == null){
            return null;
        } 
        //Get controlling field result
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        //Get controlling field picklist values if controlling field is not a checkbox
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
        
        //It is used to decode the characters of the validFor fields. 
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            if (entry.isActive()){
            //The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer i = 0; i < controllerValues.size(); i++){
                    Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                    Integer bitIndex = i / 6;
                    Integer bitShift = 5 - Math.mod(i, 6 );
                    if(controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                        continue;
                    } 
                    if (!dependentPicklistValues.containsKey(controllerValue)){
                        System.debug('v1 pickListValue-> '+controllerValue);    
                        dependentPicklistValues.put(controllerValue, new List<String>());
                    }
                    //System.debug('v3 pickListValue-> '+entry.getLabel());    
                    dependentPicklistValues.get(controllerValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }

    private static Map<String, String> getPickListValues() {
        try {
            Map<String, String> pickListValuesMap = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = ServiceAppointment.ReasonForRelocation__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesMap.put(pickListVal.getValue(), pickListVal.getLabel());
                System.debug('-> '+pickListVal.getValue() +' - '+pickListVal.getLabel());
            }
            return pickListValuesMap;
        } catch (Exception e) {
            String message = 'Erro ao obter picklist de unidade de medida '+e.getMessage()+' - '+e.getStackTraceString();
            System.debug(message);
            Util.insertLogValidation(message, 'Desktop Service', 'Erro EquipmentConsumptionController', 'Erro', 'InBound');
            throw new AuraHandledException(e.getMessage());
        }
    }
}