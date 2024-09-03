@IsTest
public with sharing class GetSlotsServiceAppointmentBatchTest {
    @TestSetup
    static void makeData(){
        DesktopServiceFactoryTest.setup();
        DataFactoryTest.makeData();
        FSL.GlobalAPIS.addStatusTransition('Nenhuma', 'Agendado');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Despachado');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Nenhuma');
    }

    @isTest
    static void testGetAppointment(){
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

        FSL__Scheduling_Policy__c policy = new FSL__Scheduling_Policy__c();
        policy = [SELECT id FROM FSL__Scheduling_Policy__c WHERE Name =: 'Policy For Testing' LIMIT 1];

        
        OperatingHours ohAvailability = new OperatingHours();
        ohAvailability = [SELECT id FROM OperatingHours WHERE Name =: 'Availability Hours' LIMIT 1];

        Test.startTest();
        Database.executebatch(new GetSlotsServiceAppointmentBatch(sa.id, policy.id, ohAvailability.id), 200);

        Test.stopTest();
    }

    
    @isTest
    static void testGetAppointment2(){
        
        Id stId = [SELECT id FROM ServiceTerritory WHERE Name = 'Test Service Territory' LIMIT 1].Id;

        ServiceAppointment sa = [SELECT Id, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];

        FSL__Scheduling_Policy__c policy = new FSL__Scheduling_Policy__c();
        policy = [SELECT id FROM FSL__Scheduling_Policy__c WHERE Name =: 'Policy For Testing' LIMIT 1];

        
        OperatingHours ohAvailability = new OperatingHours();
        ohAvailability = [SELECT id FROM OperatingHours WHERE Name =: 'Availability Hours' LIMIT 1];

        Test.startTest();
        Database.executebatch(new UpdateServiceAppointmetBatch(sa.id, policy.id, ohAvailability.id), 200);

        Test.stopTest();
    }
}