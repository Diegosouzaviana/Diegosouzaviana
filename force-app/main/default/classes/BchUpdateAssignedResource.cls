public with sharing class BchUpdateAssignedResource implements Database.Batchable<sObject>{
    
    public final String query;
    public BchUpdateAssignedResource() {
        
        DateTime startDt = DateTime.newInstance(System.Today().year(),System.Today().month(), System.Today().day(),0,0,0);
        String startstg = String.valueOf(startDt).split(' ')[0] + 'T' + String.valueOf(startDt).split(' ')[1] + 'Z';
        DateTime endDt = DateTime.newInstance(System.Today().year(),System.Today().month(), System.Today().day(),23,59,59);
        String endstg = String.valueOf(endDt).split(' ')[0] + 'T' + String.valueOf(endDt).split(' ')[1] + 'Z';
        query = 'SELECT id, (SELECT id FROM ServiceAppointments WHERE ServiceAppointment.SchedStartTime>=' + startstg + ' AND ServiceAppointment.SchedEndTime <= '+ endstg + ') FROM ServiceResource WHERE IsActive = true AND Id in (SELECT ServiceResourceId FROM AssignedResource WHERE ServiceAppointment.SchedStartTime>=' + startstg + ' AND ServiceAppointment.SchedEndTime <= '+ endstg+' )';
        System.debug('Query -> ' + query);
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug(query);        
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<ServiceResource> listSR){
        System.debug('listSR -> ' + listSR);
        List<String> listSRId = new List<String>();
        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        for(ServiceResource sr : listSR){
            if(!listSRId.contains(String.valueOf(sr.Id)) && sr.ServiceAppointments.size()>0){
                listSRId.add(String.valueOf(sr.Id));
                
                System.debug('tratando -> ' + sr);
            }else{
                System.debug('Não entrou no tratamento -> ' + sr);
            }
        }
        if(listSRId.size()>0){
            listSa = AssignedResourceTriggerHandler.searchNextAppointment(listSRId);
            System.debug('listSa -> ' + listSa);
        }
        if(listSa.size()>0){
            Database.update(listSa,false);
        }
    }
    
    public void finish(Database.BatchableContext bc){
    }
}