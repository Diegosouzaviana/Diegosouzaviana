@IsTest
public class AssignedResourceTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        DesktopServiceFactoryTest.setup();
        DataFactoryTest.makeData();
        FSL.GlobalAPIS.addStatusTransition('Nenhuma', 'Agendado');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Despachado');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Nenhuma');

    }
    

    @IsTest
    static void testAfterInsert(){
        ServiceResource sr = new ServiceResource();
        sr = [SELECT id FROM ServiceResource WHERE email__c = 'tsttech1@ftech.demo' LIMIT 1];
        
        Id stId = [SELECT id FROM ServiceTerritory WHERE Name = 'Test Service Territory' LIMIT 1].Id;

        ServiceAppointment sa = [SELECT Id,  ArrivalWindowStartTime, ArrivalWindowEndTime, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];

        ServiceAppointment sa1 = [SELECT Id,  ArrivalWindowStartTime, ArrivalWindowEndTime, ServiceTerritoryId, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Alteração de Plano - Adição de Serviço' LIMIT 1];

        Test.startTest();
        sa.SchedStartTime = DateTime.now().addHours(1);
        sa.ArrivalWindowStartTime = DateTime.now().addHours(1);
        sa.SchedEndTime = DateTime.now().addHours(2);
        sa.ArrivalWindowEndTime = DateTime.now().addHours(2);
        sa.status = 'Agendado';
        sa.ServiceTerritoryId = stId;

        update sa;
        AssignedResource ar = new AssignedResource();
        ar.ServiceAppointmentId = sa.Id;
        ar.ServiceResourceId = sr.id;
        insert ar;
        sa1.SchedStartTime = DateTime.now().addHours(3);
        sa1.ArrivalWindowStartTime = DateTime.now().addHours(3);
        sa1.SchedEndTime = DateTime.now().addHours(4);
        sa1.ArrivalWindowEndTime = DateTime.now().addHours(4);
        sa1.status = 'Agendado';
        sa1.ServiceTerritoryId = stId;

        update sa1;
        AssignedResource ar1 = new AssignedResource();
        ar1.ServiceAppointmentId = sa1.Id;
        ar1.ServiceResourceId = sr.id;
        insert ar1;
        Test.stopTest();
    }

    
    

    @IsTest
    static void testAfterDelete(){
        ServiceResource sr = new ServiceResource();
        sr = [SELECT id FROM ServiceResource WHERE email__c = 'tsttech1@ftech.demo' LIMIT 1];
        
        Id wtId = [SELECT Id FROM WorkType WHERE Name = 'Maintenance' LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account WHERE Name = 'New Account Name' LIMIT 1].Id;
        Id stId = [SELECT id FROM ServiceTerritory WHERE Name = 'Test Service Territory' LIMIT 1].Id;

        ServiceAppointment sa = [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];
        sa.SchedStartTime = DateTime.now().addHours(1);
        sa.ArrivalWindowStartTime = DateTime.now().addHours(1);
        sa.SchedEndTime = DateTime.now().addHours(2);
        sa.ArrivalWindowEndTime = DateTime.now().addHours(2);
        sa.status = 'Agendado';
        sa.ServiceTerritoryId = stId;
        update sa;
        AssignedResource ar = new AssignedResource();
        ar.ServiceAppointmentId = sa.Id;
        ar.ServiceResourceId = sr.id;
        insert ar;

        Test.startTest();
        delete ar;
        Test.stopTest();
    }

    
    @IsTest
    static void testSched(){
        ServiceResource sr = new ServiceResource();
        sr = [SELECT id FROM ServiceResource WHERE email__c = 'tsttech1@ftech.demo' LIMIT 1];
        
        Id stId = [SELECT id FROM ServiceTerritory WHERE Name = 'Test Service Territory' LIMIT 1].Id;

        ServiceAppointment sa = [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];

        sa.SchedStartTime = DateTime.now().addHours(1);
        sa.ArrivalWindowStartTime = DateTime.now().addHours(1);
        sa.SchedEndTime = DateTime.now().addHours(2);
        sa.ArrivalWindowEndTime = DateTime.now().addHours(1);
        sa.status = 'Agendado';
        sa.ServiceTerritoryId = stId;
        update sa;
        AssignedResource ar = new AssignedResource();
        ar.ServiceAppointmentId = sa.Id;
        ar.ServiceResourceId = sr.id;
        insert ar;

        Test.startTest();
        SchUpdateAssignedResource schedClass = new SchUpdateAssignedResource ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, schedClass);
        Test.stopTest();
    }

    @IsTest
    static void updateAppointmentTimeTest(){
        ServiceResource sr = new ServiceResource();
        sr = [SELECT id FROM ServiceResource WHERE email__c = 'tsttech1@ftech.demo' LIMIT 1];
        
        Id stId = [SELECT id FROM ServiceTerritory WHERE Name = 'Test Service Territory' LIMIT 1].Id;

        ServiceAppointment sa = [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];

        Test.startTest();
        sa.SchedStartTime = DateTime.now().addHours(1);
        sa.ArrivalWindowStartTime = DateTime.now().addHours(1);
        sa.SchedEndTime = DateTime.now().addHours(2);
        sa.ArrivalWindowEndTime = DateTime.now().addHours(2);
        sa.status = 'Agendado';
        sa.ServiceTerritoryId = stId;
        update sa;
        AssignedResource ar = new AssignedResource();
        ar.ServiceAppointmentId = sa.Id;
        ar.ServiceResourceId = sr.id;
        insert ar;
        Test.stopTest();
    }

    
    @IsTest
    static void updateAppointmentTimeTest2(){
        ServiceResource sr = new ServiceResource();
        sr = [SELECT id FROM ServiceResource WHERE email__c = 'tsttech1@ftech.demo' LIMIT 1];
        
        Id stId = [SELECT id FROM ServiceTerritory WHERE Name = 'Test Service Territory' LIMIT 1].Id;

        ServiceAppointment sa = [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];

        Test.startTest();
        sa.SchedStartTime = DateTime.now().addHours(1);
        sa.ArrivalWindowStartTime = DateTime.now().addHours(1);
        sa.SchedEndTime = DateTime.now().addHours(2);
        sa.ArrivalWindowEndTime = DateTime.now().addHours(2);
        sa.status = 'Agendado';
        sa.ServiceTerritoryId = stId;
        update sa;
        AssignedResource ar = new AssignedResource();
        ar.ServiceAppointmentId = sa.Id;
        ar.ServiceResourceId = sr.id;
        insert ar;
        UpdateAppointmentTime.updatetime(new List<String>{String.valueOf(sa.id)});
        Test.stopTest();
    }
}