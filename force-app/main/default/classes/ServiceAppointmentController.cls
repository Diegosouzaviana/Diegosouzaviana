public with sharing class ServiceAppointmentController {
    @AuraEnabled(Cacheable = true)
    public static List<ServiceAppointment> getTechniciansTodayAppointments(String userId){
        List<ServiceAppointment> serviceAppointments = new List<ServiceAppointment>();
        if(
            Schema.sObjectType.ServiceAppointment.isAccessible()
            && Schema.sObjectType.ServiceResource.isAccessible()
            && Schema.sObjectType.AssignedResource.isAccessible()
        ) {
            ServiceResource serviceResource = new ServiceResource();
            serviceResource = [
                SELECT Id 
                FROM ServiceResource 
                WHERE RelatedRecordId =: userId
            ];
            System.debug('serviceResource.Id ' + serviceResource.Id);
            serviceAppointments = [
                SELECT Id, AppointmentNumber, ParentRecordId, Status 
                FROM ServiceAppointment 
                WHERE Id IN (SELECT ServiceAppointmentId FROM AssignedResource WHERE ServiceResourceId =: serviceResource.Id)
            ];
            System.debug('serviceAppointments ' + serviceAppointments);
            System.debug('serviceAppointments.size() ' + serviceAppointments.size());
        }
        return serviceAppointments;
    }
}