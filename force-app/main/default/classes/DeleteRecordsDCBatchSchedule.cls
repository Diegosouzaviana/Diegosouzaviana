global without sharing class DeleteRecordsDCBatchSchedule implements Schedulable { 
    
    global void execute(SchedulableContext ctx){
        DeleteRecordsDCBatch b = new DeleteRecordsDCBatch();
        database.executeBatch(b, 10);
    }
}