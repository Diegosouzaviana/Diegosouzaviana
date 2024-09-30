public with sharing class BatchServiceAppointmentCategoryChange implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext bc){
        
        List<String> AvailableStatus = new List<String>{'\'Agendado\'','\'Despachado\'','\'Suspensa\''};
        return Database.getQueryLocator('SELECT id, WorkType.Categoria__c, Categoria__c FROM ServiceAppointment WHERE Status IN '+AvailableStatus +' AND WorkOrder__r.Status != ' + ' \'Concluída\'');
        
    }
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> listSa){
        List<ServiceAppointment> listUpdateSa = new List<ServiceAppointment>();
        for(ServiceAppointment sa : listSa){
            if(sa.Categoria__c!=sa.WorkType.Categoria__c){
                sa.Categoria__c = sa.WorkType.Categoria__c;
                listUpdateSa.add(sa);
            }
        }
        if(listUpdateSa.size()>0){
            Database.update(listUpdateSa, false);
        }
    }
 
    public void finish(Database.BatchableContext bc){
    }
}