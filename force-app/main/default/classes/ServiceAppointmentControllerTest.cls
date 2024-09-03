@isTest
public with sharing class ServiceAppointmentControllerTest {
    @TestSetup
    static void makeData(){
        DesktopServiceFactoryTest.setup();
        DataFactoryTest.makeData();
        FSL.GlobalAPIS.addStatusTransition('Nenhuma', 'Agendado');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Despachado');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Nenhuma');
        FSL.GlobalAPIS.addStatusTransition('Agendado', 'Concluída');

    }

    @IsTest
    static void testAfterInsert(){
        ServiceResource sr = new ServiceResource();
        sr = [SELECT id,RelatedRecordID FROM ServiceResource WHERE email__c = 'tsttech1@ftech.demo' LIMIT 1];
        
        Id stId = [SELECT id FROM ServiceTerritory WHERE Name = 'Test Service Territory' LIMIT 1].Id;

        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        ServiceAppointment sa = [SELECT Id, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];

        ServiceAppointment sa1 = [SELECT Id, ServiceTerritoryId, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Alteração de Plano - Adição de Serviço' LIMIT 1];

        sa.SchedStartTime = DateTime.now().addHours(1);
        sa.SchedEndTime = DateTime.now().addHours(2);
        sa.ArrivalWindowStartTime = DateTime.now().addHours(1);
        sa.ArrivalWindowEndTime = DateTime.now().addHours(2);
        sa.status = 'Agendado';
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
        ServiceAppointmentController.getTechniciansTodayAppointments(String.valueOf(sr.RelatedRecordID));
        Test.stopTest();
    }

    @isTest
    static void testAfterInsert2(){
        ServiceResource sr = new ServiceResource();
        sr = [SELECT id,RelatedRecordID FROM ServiceResource WHERE email__c = 'tsttech1@ftech.demo' LIMIT 1];
        
        Id stId = [SELECT id FROM ServiceTerritory WHERE Name = 'Test Service Territory' LIMIT 1].Id;

        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        ServiceAppointment sa = [SELECT Id, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];

        //ServiceAppointment sa1 = [SELECT Id, ServiceTerritoryId, Status,SchedStartTime,SchedEndTime FROM ServiceAppointment WHERE WorkType.Name = 'Alteração de Plano - Adição de Serviço' LIMIT 1];

        sa.SchedStartTime = DateTime.now().addHours(1);
        sa.SchedEndTime = DateTime.now().addHours(2);
        sa.ArrivalWindowStartTime = DateTime.now().addHours(1);
        sa.ArrivalWindowEndTime = DateTime.now().addHours(2);
        sa.status = 'Agendado';
        sa.ServiceTerritoryId = stId;
        listSa.add(sa);
        update listSa;
        
        List<AssignedResource> listAr = new List<AssignedResource>();
        AssignedResource ar = new AssignedResource();
        ar.ServiceAppointmentId = sa.Id;
        ar.ServiceResourceId = sr.id;
        listAr.add(ar);
        insert listAr;

        Test.startTest();
        try{
            
            sa.Status = 'Concluída';
            update sa;
        }catch(Exception ex){
            
        }
        Test.stopTest();
    }

    @isTest
    static void testBeforeUpdate(){
        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        ServiceAppointment sa = [SELECT Id, Status,SchedStartTime,SchedEndTime,sac_login__c,sac_password__c,wifi_ssid__c,wifi_password__c,StringPPoeUser__c,LongUserPlanId__c,Old_Pu_Id__c,Old_PPPOE_User__c FROM ServiceAppointment WHERE WorkType.Name = 'Manutenção' LIMIT 1];
        Test.startTest();

        sa.sac_login__c = '12345';
        sa.sac_password__c = '12345';
        sa.wifi_ssid__c = '12345';
        sa.wifi_password__c = '12345';
        sa.StringPPoeUser__c = '12345';
        sa.LongUserPlanId__c = '12345';
        update sa;

        sa.StringPPoeUser__c = '';
        update sa;

        Test.stopTest();
    }

}