global with sharing class DeleteRecordsDCBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime safetyTime = System.now().addHours(-1);
        return Database.getQueryLocator([
            SELECT Id, AccountId, WorkOrder__c, WorkOrder__r.CaseId, ParentRecordId, ContactId,
            CaseNumberSA__c FROM ServiceAppointment WHERE Status =
                'Nenhuma' AND Work_Type_SA__c = 'Ativação' AND WorkOrder__r.Prospect__c = null AND CreatedDate < :safetyTime
        ]);
    }
    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {
        DeleteRecordsDC.DeleteRecords(scope);
    }

    global void finish(Database.BatchableContext bc) {}
}