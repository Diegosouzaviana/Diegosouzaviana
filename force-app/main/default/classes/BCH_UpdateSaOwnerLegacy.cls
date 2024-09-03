public with sharing class BCH_UpdateSaOwnerLegacy implements Database.Batchable<sObject> {
    private List<ServiceAppointment> serviceAppointments{get; set;}

    public Database.queryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ServiceResource.RelatedRecordId, ServiceAppointment.Owner.Id FROM AssignedResource'
        );
    }
    
    public void execute(Database.BatchableContext bc, List<AssignedResource> assignedResources) {
        this.serviceAppointments = new List<ServiceAppointment>();
        
        System.debug('Executing batch');

        for(AssignedResource assignedResource : assignedResources) {
            assignedResource.ServiceAppointment.OwnerId = assignedResource.ServiceResource.RelatedRecordId;
            this.serviceAppointments.add(assignedResource.ServiceAppointment);
        }

        List<Database.SaveResult> results = Database.update(this.serviceAppointments, false);
        for(Database.SaveResult result : results) {
            if(!result.isSuccess()) {
                for(Database.Error error : result.getErrors()) {
                    System.debug('Error ' + error.getStatusCode() + ' ' + error.getMessage());
                }
            }
        }

        System.debug('ServiceAppointments updated');
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch finished');
    }
}