global class WorkOrderGantRedirect implements FSL.CustomGanttServiceAppointmentAction {
    global String action(List<Id> serviceAppointmentsIds, Datetime ganttStartDate, Datetime ganttEndDate, Map<String, Object> additionalParameters) {
        try {
            
            List<ServiceAppointment> saList = [SELECT FSL__InJeopardy__c, WorkOrder__c, AppointmentNumber, Id FROM ServiceAppointment WHERE Id in : serviceAppointmentsIds];
            Id WorkOrderId;
            for (ServiceAppointment s : saList) {
                WorkOrderId = s.WorkOrder__c;
            }
            
            RedirectToWorkOrder(WorkOrderId);
            return 'Opening work order '+WorkOrderId;
        } catch (Exception e) {
            System.debug('Error '+e.getMessage()+e.getStackTraceString());
            return null;
        }
    }

    public PageReference RedirectToWorkOrder(Id wo) {
        PageReference pg = new PageReference('/lightning/r/WorkOrder/'+wo+'/view');
        pg.setRedirect(true);
        return pg;
    }
}