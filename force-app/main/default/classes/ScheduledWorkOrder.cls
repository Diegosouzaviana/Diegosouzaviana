global class ScheduledWorkOrder implements Schedulable {
    Id WorkOrderId;
    Double HowManyTimes;
    public ScheduledWorkOrder(Id woId, Double HMT){
        System.debug('ScheduledWorkOrder '+woId);
        this.WorkOrderId = woId;
        HowManyTimes = HMT;
    }
    global void execute(SchedulableContext sc) {
        try {
            Id woId = this.WorkOrderId;
            Double OrderHowManyTimes;
            System.debug('execute function in ScheduledWorkOrder Schedulable '+this.WorkOrderId);
            System.debug('HowManyTimes '+HowManyTimes);
            System.debug('triggerId->> '+sc.getTriggerId());
            Id CronJobId = [SELECT CronJobDetailId, CronJobDetail.JobType,  CronJobDetail.Name FROM CronTrigger WHERE Id = :sc.getTriggerId()].CronJobDetailId;
            System.debug('CronJobId->> '+CronJobId);
            
            WorkOrder wo = [SELECT HowManyTimesWo__c, SchedulingManagement__c FROM WorkOrder WHERE ID = :woId];
            wo.SchedulingManagement__c = false;
            update wo;
            OrderHowManyTimes = wo.HowManyTimesWo__c;
            System.debug('HowManyTimes '+HowManyTimes+ ' -- OrderHowManyTimes '+OrderHowManyTimes);
            if (HowManyTimes == OrderHowManyTimes) {//se não fez o book appointment
                ServiceAppointment sa = [SELECT Id, Reschedule_Reason_SA__c, RescheduleReasonSAHistory__c FROM ServiceAppointment WHERE WorkOrder__c = :woId];
                if (sa.Reschedule_Reason_SA__c != sa.RescheduleReasonSAHistory__c) { 
                    sa.Reschedule_Reason_SA__c = sa.RescheduleReasonSAHistory__c;
                    System.debug('atualizando campo sa '+sa.Reschedule_Reason_SA__c);
                    update sa;
                }
                WorkOrderSchedulingEvent__e ev = new WorkOrderSchedulingEvent__e(Agendamento__c = CronJobId);
                EventBus.publish(ev);
                
            }

        } catch (Exception w) {
            System.debug('Error-> '+w.getMessage()+' '+w.getStackTraceString());
        }
    }

    // global void finish(Database.BatchableContext BC) {
    //     try {
    //         // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
    //         // Query the AsyncApexJob object to retrieve the current job's information.
            
    //         AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
    //         System.debug('Id in finish function'+BC.getJobId());
    //         //then use the active job id and abort it
    //         system.abortJob(a.id);
    //     } catch (Exception e) {
    //         System.debug('Error abortJob--> '+e.getMessage()+' '+e.getStackTraceString());
    //     }
    // }
}