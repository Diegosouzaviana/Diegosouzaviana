@IsTest
public with sharing class ServiceResourceVFTest {
    @TestSetup
    static void makeData(){
        DesktopServiceFactoryTest.setup();
        DataFactoryTest.makeData();
        FSL.GlobalAPIS.addStatusTransition('Nenhuma', 'Agendado');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Despachado');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Nenhuma');

    }

    @isTest
    static void testServiceResourceVF(){
        
        ServiceResource sr = new ServiceResource();
        sr = [SELECT id,RelatedRecordID FROM ServiceResource WHERE email__c = 'tsttech1@ftech.demo' LIMIT 1];
        
        Id stId = [SELECT id FROM ServiceTerritory WHERE Name = 'Test Service Territory' LIMIT 1].Id;

        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        ServiceAppointment sa = [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];

        ServiceAppointment sa1 = [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, ServiceTerritoryId, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Alteração de Plano - Adição de Serviço' LIMIT 1];

        sa.SchedStartTime = DateTime.now().addHours(1);
        sa.SchedEndTime = DateTime.now().addHours(2);
        sa.ArrivalWindowStartTime = DateTime.now().addHours(1);
        sa.ArrivalWindowEndTime = DateTime.now().addHours(2);
        sa.status = 'Agendado';
        sa.Work_Type_SA__c = 'Manutenção';
        sa.ServiceTerritoryId = stId;
        listSa.add(sa);

        sa1.SchedStartTime = DateTime.now().addHours(3);
        sa1.SchedEndTime = DateTime.now().addHours(4);
        sa.ArrivalWindowStartTime = DateTime.now().addHours(3);
        sa.ArrivalWindowEndTime = DateTime.now().addHours(4);
        sa1.status = 'Agendado';
        sa1.ServiceTerritoryId = stId;
        listSa.add(sa1);
        update listSa;
        
        List<AssignedResource> listAr = new List<AssignedResource>();
        AssignedResource ar = new AssignedResource();
        ar.ServiceAppointmentId = sa.Id;
        ar.ServiceResourceId = sr.id;
        listAr.add(ar);
        
        AssignedResource ar1 = new AssignedResource();
        ar1.ServiceAppointmentId = sa1.Id;
        ar1.ServiceResourceId = sr.id;
        listAr.add(ar1);
        insert listAr;
        Test.startTest();
            
            Test.setCurrentPageReference(Page.ServiceResourceNotificationVF);
            ApexPages.currentPage().getParameters().put('id', String.valueOf(sa.Id));

            ServiceResourceVF vf = new ServiceResourceVF();
            vf.selectedval = 'Cliente Ausente';
            //ServiceResourceVF.ServiceResourceVF();
            vf.saveRescheduleReasonValue();
        Test.stopTest();


    }

    
    @isTest
    static void testServiceResourceVF2(){
        
        ServiceResource sr = new ServiceResource();
        sr = [SELECT id,RelatedRecordID FROM ServiceResource WHERE email__c = 'tsttech1@ftech.demo' LIMIT 1];
        
        Id stId = [SELECT id FROM ServiceTerritory WHERE Name = 'Test Service Territory' LIMIT 1].Id;

        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        ServiceAppointment sa = [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];

        ServiceAppointment sa1 = [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, ServiceTerritoryId, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Alteração de Plano - Adição de Serviço' LIMIT 1];
        sa.SchedStartTime = DateTime.now().addHours(1);
        sa.ArrivalWindowStartTime = DateTime.now().addHours(-1);
        sa.ArrivalWindowEndTime = DateTime.now().addHours(2);
        sa.SchedEndTime = DateTime.now().addHours(2);
        sa.status = 'Agendado';
        sa.Work_Type_SA__c = 'Manutenção';
        sa.ServiceTerritoryId = stId;
        listSa.add(sa);

        sa1.SchedStartTime = DateTime.now().addHours(3);
        sa1.SchedEndTime = DateTime.now().addHours(4);
        sa1.ArrivalWindowStartTime = DateTime.now().addHours(3);
        sa1.ArrivalWindowEndTime = DateTime.now().addHours(4);
        sa1.status = 'Agendado';
        sa1.ServiceTerritoryId = stId;
        listSa.add(sa1);
        update listSa;
        
        List<AssignedResource> listAr = new List<AssignedResource>();
        AssignedResource ar = new AssignedResource();
        ar.ServiceAppointmentId = sa.Id;
        ar.ServiceResourceId = sr.id;
        listAr.add(ar);
        
        AssignedResource ar1 = new AssignedResource();
        ar1.ServiceAppointmentId = sa1.Id;
        ar1.ServiceResourceId = sr.id;
        listAr.add(ar1);
        insert listAr;
        Test.startTest();
            
            Test.setCurrentPageReference(Page.ServiceResourceNotificationVF);
            ApexPages.currentPage().getParameters().put('id', String.valueOf(sa.Id));

            ServiceResourceVF vf = new ServiceResourceVF();
            //ServiceResourceVF.ServiceResourceVF();
        Test.stopTest();


    }
}