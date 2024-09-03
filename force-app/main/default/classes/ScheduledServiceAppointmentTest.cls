@IsTest
public class ScheduledServiceAppointmentTest {

    @TestSetup
    static void makeData(){
        DataFactoryTest.makeData();
    }

    @IsTest
    static void scheduleServiceApp(){
        Id wtId = [select Id from WorkType where Name = 'Maintenance'].Id;
        Id accId = [select Id from Account where Name = 'New Account Name'].Id;

        // Create Work Order. Service Appointment is created via the Work Type
        WorkOrder wo = new WorkOrder(
            AccountId = accId,
            WorkTypeId = wtId,
            Subject = 'Test',
            Street = 'Kerkstraat 2',
            PostalCode = '3581 RD',
            City = 'Utrecht',
            Country = 'NL',
            State = 'CL'
        );
        insert wo;

        List<ServiceAppointment> saList = [select ArrivalWindowEndTime, NotificacaoEnviada__c, Est_Atrasado__c, ServiceTerritoryId, Status, Id from ServiceAppointment where ParentRecordId = :wo.Id limit 1];
        if (saList.size() > 0) {
            for (ServiceAppointment sa : saList) {
                DateTime dt = System.now();
                DateTime earlierDT = dt.addMinutes(-5);
                System.debug(dt + ' -- '+earlierDT);
        
                System.debug('sa->> '+sa.Status+' - '+sa.ArrivalWindowEndTime + ' - '+ sa.NotificacaoEnviada__c+ '-'+ sa.Est_Atrasado__c+ '-'+sa.ServiceTerritoryId);
                sa.ArrivalWindowEndTime = earlierDT;
                sa.NotificacaoEnviada__c = false;
                update sa;
                System.debug('sa2->> '+sa.Status+' - '+sa.ArrivalWindowEndTime + ' - '+ sa.NotificacaoEnviada__c+ '-'+ sa.Est_Atrasado__c+ '-'+sa.ServiceTerritoryId);  
            }
        }
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule( 'testBasicScheduledApex',
                                        ScheduledServiceAppointment.CRON_EXP, 
                                        new ScheduledServiceAppointment()
                                        );

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(ScheduledServiceAppointment.CRON_EXP, ct.CronExpression);

        // Verify the expressions are the same
        System.assertEquals(ScheduledServiceAppointment.CRON_EXP, ct.CronExpression);
        ScheduledServiceAppointmentClass schSA = new ScheduledServiceAppointmentClass();
        schSA.schedule();
        Test.stopTest();
    }
}