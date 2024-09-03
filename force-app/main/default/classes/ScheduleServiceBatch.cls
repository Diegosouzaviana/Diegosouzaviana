public with sharing class ScheduleServiceBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {

    private Id scPId;
    private Id saID;
    public ScheduleServiceBatch(Id schedulingPolicyId, Id sAppointmentID ) {
        this.saID   = sAppointmentID;
        this.scPId  = schedulingPolicyId;
    }
    
    public void execute(Database.BatchableContext BC, List<ServiceAppointment> saLst) {
        System.debug('ScheduleServiceBatch.execute');
        FSL.ScheduleResult myResult = new FSL.ScheduleResult();
        myResult = FSL.ScheduleService.schedule(this.scPId, saLst[0].Id);
        System.debug('myResult '+myResult);
    } 

    public  Database.QueryLocator start(Database.BatchableContext BC) {

       
        return Database.getQueryLocator([SELECT Id, description, EarliestStartTime, AppointmentNumber, SchedStartTime, SchedEndTime, DueDate, ArrivalWindowStartTime, ArrivalWindowEndTime, 
        AccountId, ServiceTerritoryId, WorkTypeId, FSL__Scheduling_Policy_Used__c, Reschedule_Reason_SA__c
        FROM ServiceAppointment WHERE Id= :this.saID]);

    }

    public  void finish(Database.BatchableContext BC) {
        System.debug('finish ');
    }
    
}