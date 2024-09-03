global class dsk_batchApexSchedulableAccountBlocked implements Schedulable {
    global void execute(SchedulableContext SC) {
        dsk_batchApexAccountBlocked batch =new dsk_batchApexAccountBlocked();
Database.executeBatch(batch);
        //System.schedule(jobName, cronExp, miApex);
    }
}
/* Execution
string jobName = 'ScheduleBlockedAccounts';
        string cronExp = '0 0 0 * * ?';
        dsk_batchApexAccountBlocked miApex = new dsk_batchApexAccountBlocked();
        System.scheduleBatch(miApex, jobName, cronExp);
*/