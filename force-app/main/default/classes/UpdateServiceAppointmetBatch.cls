public with sharing class UpdateServiceAppointmetBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
    
    private Id saId;
    private Id SchedulingPolicyId;
    private Id OperatingHoursId;
    TimeZone tz = TimeZone.getTimeZone('America/Sao_Paulo');
    List<Object> returnList = new List<Object>();

    public UpdateServiceAppointmetBatch(Id sAppointmentID, Id scPolicyId, Id opHoursId) {
        this.saId = sAppointmentID;
        this.SchedulingPolicyId = scPolicyId;
        this.OperatingHoursId = opHoursId;
    }

    public void execute(Database.BatchableContext BC, List<ServiceAppointment> saLst) {
        try {
            List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.GetSlots(saLst[0].Id, this.SchedulingPolicyId, this.OperatingHoursId, this.tz, false);
            if (slots.size() > 0) {
                for(integer i=0; i<slots.size(); i++){  
                    ResponseWrapper.GetBookingSlot bsRes = new ResponseWrapper.GetBookingSlot(i, slots[i].Interval.Start, slots[i].Interval.Finish, slots[i].Grade);
                    System.debug('-> '+i+' '+ slots[i].Interval.Start+' '+ slots[i].Interval.Finish+' '+slots[i].Grade);
                    returnList.add(bsRes);
                }
            }else{
                ResponseWrapper.BookingSlot bsRes = new ResponseWrapper.BookingSlot(saLst[0].Id, 'ERRO', 'Não encontrado slots disponíveis');
                System.debug('-> '+saLst[0].Id+' Não encontrado slots disponíveis');
                returnList.add(bsRes);
            }
        } catch (Exception e) {
            System.debug('Erro ao atualizar SA '+e.getMessage()+' - '+e.getStackTraceString());
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([SELECT Id, description, EarliestStartTime, AppointmentNumber, SchedStartTime, SchedEndTime, DueDate, ArrivalWindowStartTime, ArrivalWindowEndTime, 
        AccountId, ServiceTerritoryId, WorkTypeId, FSL__Scheduling_Policy_Used__c, Reschedule_Reason_SA__c
        FROM ServiceAppointment WHERE Id= :this.saId]);

    }

    public void finish(Database.BatchableContext BC) {
        System.debug('finish UpdateServiceAppointmetBatch');
        System.debug(returnList.size());
        AppointmentBookingSlot ap = new AppointmentBookingSlot(returnList);
    }
}