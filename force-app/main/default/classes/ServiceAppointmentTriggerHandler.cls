public with sharing class ServiceAppointmentTriggerHandler {
    public static Map<Id,ServiceAppointment> newMap = new Map<Id,ServiceAppointment>();
    public static Map<Id,ServiceAppointment> oldMap = new Map<Id,ServiceAppointment>();

    public static void SAHandler(Map<Id,ServiceAppointment> nMap, Map<Id,ServiceAppointment> oMap){
        newMap = nMap;
        oldMap = oMap;
        afterUpdate();
    }
    
    /*public override void beforeInsert(){}

    public override void beforeDelete(){}

    public override void afterInsert(){}

    public override void afterUpdate(){}

    public override void afterDelete(){}*/

    public static void afterUpdate(){
        List<String> listIds = new List<String>();
        for(ServiceAppointment sa : newMap.values()){
            if(sa.SchedStartTime != null && sa.SchedStartTime != oldMap.get(sa.Id).SchedStartTime && !listIds.contains(String.valueOf(sa.id))){
                listIds.add(String.valueOf(sa.id));
            }
        }

        if(listIds.size()>0){
            updateAppointments(listIds);
        }
    }

    public static void updateAppointments(List<String> listIds){
        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        List<AssignedResource> listAr = new List<AssignedResource>();

        listAr = [SELECT id, ServiceResourceId, ServiceAppointmentId FROM AssignedResource WHERE ServiceAppointmentId IN :listIds];

        List<String> listSRId = new List<String>();
        for(AssignedResource ar : listAr){
            if(!listSRId.contains(String.valueOf(ar.ServiceResourceId))){
                listSRId.add(String.valueOf(ar.ServiceResourceId));
            }
        }

        if(listSRId.size()>0){
            listSa = AssignedResourceTriggerHandler.searchNextAppointment(listSRId);
        }
        if(listSa.size()>0){
            Database.update(listSa,false);
        }
    }

    public static void checkSteps(Map<Id,ServiceAppointment> nMap, Map<Id,ServiceAppointment> oMap){

        try {
            Map<String, WorkOrder> mapWo = new Map<String, WorkOrder>();
            List<String> returnedIds = new List<String>();
            for (ServiceAppointment sa : nMap.values()) {
                if (sa.Status == 'Concluída' && oldMap.get(sa.Id).Status != sa.Status) {
                    WorkOrder wo = new WorkOrder();
                    wo.id = String.valueOf(sa.ParentRecordId);
                    mapWo.put(String.valueOf(sa.ParentRecordId), wo);
                }
            }    
            if(mapWo.size()>0){
                returnedIds = ServiceAppointmentTriggerHandler.verifySteps(mapWo);
            }   
            if(returnedIds.size()>0){
                for(ServiceAppointment sa : nMap.values()){
                    if(returnedIds.contains(String.valueOf(sa.ParentRecordId))){
                        sa.addError('Favor finalizar as etapas corretamente na ordem solicitada.');
                    }
                }
            } 
        } catch (Exception e) {
            System.debug('Error checkConnections '+ e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    public static List<String> verifySteps(Map<String, WorkOrder> mapWo){
        List<WorkStep> listWS = new List<WorkStep>();
        listWS = [SELECT id, WorkOrderId FROM WorkStep WHERE WorkOrderId IN: mapWo.keySet() AND Status = 'New'];

        List<String> listErrors = new List<String>();

        for(WorkStep ws : listWS){
            if(!listErrors.contains(String.valueOf(ws.WorkOrderId))){
                listErrors.add(String.valueOf(ws.WorkOrderId));
            }
        }
        return listErrors;
    }

    public static void checkProvisioning(Map<Id,ServiceAppointment> nMap, Map<Id,ServiceAppointment> oMap){
        for(String s : nMap.KeySet()){
            System.debug('nMap.get(s).StringPPoeUser__c 1 -> ' + nMap.get(s).StringPPoeUser__c);
            if(!String.isBlank(oMap.get(s).StringPPoeUser__c) && (String.isBlank(nMap.get(s).StringPPoeUser__c) || nMap.get(s).StringPPoeUser__c == '')){
                nMap.get(s).sac_login__c = oMap.get(s).sac_login__c;
                nMap.get(s).sac_password__c = oMap.get(s).sac_password__c;
                nMap.get(s).wifi_ssid__c = oMap.get(s).wifi_ssid__c;
                nMap.get(s).wifi_password__c = oMap.get(s).wifi_password__c;
                nMap.get(s).StringPPoeUser__c = oMap.get(s).StringPPoeUser__c;
                nMap.get(s).LongUserPlanId__c = oMap.get(s).LongUserPlanId__c;
                nMap.get(s).Old_Pu_Id__c = oMap.get(s).Old_Pu_Id__c;
                nMap.get(s).Old_PPPOE_User__c = oMap.get(s).Old_PPPOE_User__c;
                System.debug('nMap.get(s).StringPPoeUser__c 2 -> ' + nMap.get(s).StringPPoeUser__c);
            }
        }
    }
}