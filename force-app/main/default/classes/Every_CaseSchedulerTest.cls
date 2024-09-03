@isTest
public with sharing class Every_CaseSchedulerTest {

    @isTest static void testEveryCaseScheduler() {

        Test.startTest();	
            Every_CaseScheduler.executeSchedule();
            String jobId = System.schedule('Teste schedulable', '0 0 * * * ?', new Every_CaseScheduler());
        Test.stopTest();

        CronTrigger cronTrigger = [SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(jobId, cronTrigger.Id);
    }
}