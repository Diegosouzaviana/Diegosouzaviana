global class toggleServiceAppointmentJeopardy implements FSL.CustomGanttServiceAppointmentAction {
 
    global String action(List<Id> serviceAppointmentsIds, Datetime ganttStartDate, Datetime ganttEndDate, Map<String, Object> additionalParameters) {
       
        List<ServiceAppointment> saList = [SELECT FSL__InJeopardy__c, AppointmentNumber FROM ServiceAppointment WHERE Id in : serviceAppointmentsIds];
        String reply = '';
        List<String> saNames = new List<String>();

        for (ServiceAppointment s : saList) {
            System.debug(s.AppointmentNumber);
        }
       

        return 'Service Appointments successfully processed: ' + reply;
    }
   
}