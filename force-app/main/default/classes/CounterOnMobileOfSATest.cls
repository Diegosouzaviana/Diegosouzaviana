@isTest
public with sharing class CounterOnMobileOfSATest {
    @TestSetup
    static void makeData(){
        DesktopServiceFactoryTest.setup();
        DataFactoryTest.makeData();
        FSL.GlobalAPIS.addStatusTransition('Nenhuma', 'Agendado');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Despachado');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Nenhuma');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Concluída');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Cancelado');
        FSL.GlobalAPIS.addStatusTransition('Despachado', 'Concluída');
        FSL.GlobalAPIS.addStatusTransition('Despachado', 'Cancelado');
    }

    @isTest
    static void GetCounterMobileTest(){
        
        ServiceResource sr = new ServiceResource();
        sr = [SELECT id,RelatedRecordId FROM ServiceResource WHERE email__c = 'tsttech1@ftech.demo' LIMIT 1];
        
        User us = [SELECT id FROM User WHERE id =: sr.RelatedRecordId LIMIT 1];
        
        Id stId = [SELECT id FROM ServiceTerritory WHERE Name = 'Test Service Territory' LIMIT 1].Id;

        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        ServiceAppointment sa = [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];

        ServiceAppointment sa1 = [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, ServiceTerritoryId, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Alteração de Plano - Adição de Serviço' LIMIT 1];

        ServiceAppointment sa2 = [SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, ServiceTerritoryId, Status,SchedStartTime,SchedEndTime, ParentRecordId FROM ServiceAppointment WHERE WorkType.Name = 'Alteração de Plano - Alteração de Velocidade' LIMIT 1];

        sa.SchedStartTime = DateTime.now().addHours(1);
        sa.ArrivalWindowStartTime = DateTime.now().addHours(1);
        sa.SchedEndTime = DateTime.now().addHours(2);
        sa.ArrivalWindowEndTime = DateTime.now().addHours(2);
        sa.status = 'Agendado';
        sa.ServiceTerritoryId = stId;
        listSa.add(sa);

        sa1.SchedStartTime = DateTime.now().addHours(3);
        sa1.ArrivalWindowStartTime = DateTime.now().addHours(3);
        sa1.SchedEndTime = DateTime.now().addHours(4);
        sa1.ArrivalWindowEndTime = DateTime.now().addHours(4);
        sa1.status = 'Agendado';
        sa1.ServiceTerritoryId = stId;
        listSa.add(sa1);
        
        sa2.SchedStartTime = DateTime.now().addHours(5);
        sa2.ArrivalWindowStartTime = DateTime.now().addHours(5);
        sa2.SchedEndTime = DateTime.now().addHours(6);
        sa2.ArrivalWindowEndTime = DateTime.now().addHours(6);
        sa2.status = 'Agendado';
        sa2.ServiceTerritoryId = stId;
        listSa.add(sa2);
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

        AssignedResource ar2 = new AssignedResource();
        ar2.ServiceAppointmentId = sa2.Id;
        ar2.ServiceResourceId = sr.id;
        listAr.add(ar2);
        insert listAr;

        /*sa1.status = 'Cancelado';
        sa1.MotivoDoCancelamento__c = 'Acesso normalizado';
        sa1.CompletedWork__c = 'Sem sucesso';*/
        /*List<WorkPlan> wpList = new List<WorkPlan>();
        wpList = [SELECT id FROM WorkPlan WHERE WorkOrderId = :sa2.ParentRecordId];

        if(wpList.size()>0){
            delete wpList;
        }

        sa2.status = 'Concluída';
        sa2.ReasonForConclusion__c = 'Retirada Completa';
        sa2.CompletedWork__c = 'Com sucesso';
        List<ServiceAppointment> listSa1 = new List<ServiceAppointment>();
        //listSa1.add(sa1);
        listSa1.add(sa2);
        update listSa1;*/
        System.runAs(us){
            Test.startTest();

            CounterOnMobileOfSA.GetCounterMobile();
            Test.stopTest();
        }
    }
}