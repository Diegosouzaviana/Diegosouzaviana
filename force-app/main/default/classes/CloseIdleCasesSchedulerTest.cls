// 
// Cobertura na(s) classe(s):
// ** CloseIdleCasesDailyScheduler
// 
@isTest
private class CloseIdleCasesSchedulerTest {
    
    @isTest
    static void testSchedulerExecution() {
        Test.startTest();
        
        CloseIdleCasesDailyScheduler.scheduleJob();
        
        Test.stopTest();
        
        CronTrigger scheduledJob = [SELECT Id, CronExpression, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'CloseIdleCasesBatchJob'];
        
        System.assertEquals('0 0 0 * * ?', scheduledJob.CronExpression);
        System.assertEquals(System.now().addDays(1).dateGMT(), scheduledJob.NextFireTime.dateGMT());
    }
}