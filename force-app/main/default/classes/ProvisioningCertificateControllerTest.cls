/**
**************************************************************************************************************
* @company          Sys4b
* @author           Guilherme
* @project          DesktopSA
* @name             ProvisioningCertificateControllerTest
* @description      Test class of  ProvisioningCertificateController
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2023-09-02   Guilherme                     Initial version. 
******
**/

@isTest
public with sharing class ProvisioningCertificateControllerTest {

    @TestSetup
    static void setup(){
        DataFactoryTest.makeData();

        Id accountId = [Select id From Account Limit 1].Id;

        Contract contract = new Contract();
        contract.vlocity_cmt__ContractReferenceNumber__c = '236598856758';  
        contract.IdPromocao__c = 1230;
        contract.AccountId = accountId;
        insert contract;

        
        Case case1 = new Case();
        case1.accountId = accountId;
        case1.Contrato__c = contract.Id;
        insert case1;

        WorkType wt = new WorkType(
                Name = 'Alteração de Plano - Alteração de Velocidade',
                ShouldAutoCreateSvcAppt = true,
                FSL__Due_Date_Offset__c = 60*24*7, 
                DurationType = 'Minutes',
                EstimatedDuration = 60
        );
        insert wt;

        WorkOrder wo = new WorkOrder(
            AccountId = accountId,
            WorkTypeId = wt.Id,
            Subject = 'Test 2',
            Street = 'Kerkstraat 2',
            PostalCode = '3581 RD',
            City = 'Utrecht',
            Country = 'NL',
            State = 'CL',
            CaseId = case1.Id
        );
        insert wo;

        WorkPlan wp = new WorkPlan(
            Name                    = 'Auto Inspeção',
            WorkOrderId             = wo.Id
        );
        insert wp;

        WorkStep ws = new WorkStep(
            Name                    = 'Certidão de Nascimento',
            Status                  = 'New',
            WorkPlanId              = wp.Id
        );
        insert ws;

        vlocity_cmt__ContractLineItem__c contractLI = new vlocity_cmt__ContractLineItem__c();
        contractLI.vlocity_cmt__ContractId__c = contract.Id;
        contractLI.IdPlanoUsuario__c = 1581297;
        insert contractLI;

        ServiceAppointment sa = [SELECT WorkOrder__c From ServiceAppointment Limit 1];
        sa.WorkOrder__c = wo.Id;
        update sa;
    }

    @isTest
    static void testMethod_ProvisioningCertificate() {
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        
        ServiceAppointment sa = [SELECT WorkOrder__r.Case.Contrato__c 
                                FROM ServiceAppointment
                                WHERE ParentRecordId = :workOrderId
                                Limit 1
        ];
        Test.startTest();
        ProvisioningCertificateWrapper response = ProvisioningCertificateController.ProvisioningCertificate(sa.WorkOrder__r.Case.Contrato__c);
        System.assert(response!=null);
        Test.stopTest();
    }

    @isTest
    static void testMethod_Integrate() {
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        WorkStep wo = [SELECT Id 
                    FROM WorkStep
                    WHERE WorkOrderId = :workOrderId
                    Limit 1
        ];
        Test.setMock(HttpCalloutMock.class,new ProvisioningCertificateCalloutMock(200));
        Test.startTest();
        ProvisioningCertificateController.ResponseWrapper response = ProvisioningCertificateController.integrate(wo.Id,true);
        Test.stopTest();
        System.assert(response!=null);
        System.assert(response.success==true);
        System.assertEquals('Processing ...',response.message);
        System.assertEquals(1,[Select COUNT() From IntegrationLog__c]);
        System.assertEquals('Sucesso',[Select LogStatus__c From IntegrationLog__c Limit 1].LogStatus__c);
    }

    @isTest
    static void testMethod_Integrate_Error() {
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        
        WorkStep wo = [SELECT Id 
                    FROM WorkStep
                    WHERE WorkOrderId = :workOrderId
                    Limit 1
        ];
        Test.setMock(HttpCalloutMock.class,new ProvisioningCertificateCalloutMock(500));
        Test.startTest();
        ProvisioningCertificateController.ResponseWrapper response = ProvisioningCertificateController.integrate(wo.Id,true);
        Test.stopTest();
        System.assert(response!=null);
        System.assertEquals(false,response.success);
        System.assertEquals(1,[Select COUNT() From IntegrationLog__c]);
        System.assertEquals('Erro',[Select LogStatus__c From IntegrationLog__c Limit 1].LogStatus__c);
    }

    @isTest
    static void testMethod_checkCallback(){
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        
        WorkStep wo = [SELECT Id 
                    FROM WorkStep
                    WHERE WorkOrderId = :workOrderId
                    Limit 1
        ];
        Test.startTest();
        ProvisioningCertificateController.ResponseWrapper response = ProvisioningCertificateController.checkCallback(wo.Id, true);
        System.assert(response!=null);
        System.assert(response.success==false);
        Test.stopTest();
    }

    @isTest
    static void testMethod_checkCallback_success(){
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        
        WorkStep wo = [SELECT Id 
                    FROM WorkStep
                    WHERE WorkOrderId = :workOrderId
                    Limit 1
        ];


        ServiceAppointment serviceAppointment = [Select 
                    Certificated__c,message_certificate__c,ONU_Signal__c,CTO_Avg_Signal__c
                    From ServiceAppointment 
                    Where WorkOrder__c = :workOrderId Limit 1
        ];
        serviceAppointment.Certificated__c = true;
        serviceAppointment.message_certificate__c = 'Equipamento certificado';
        serviceAppointment.ONU_Signal__c = -17.1;
        update serviceAppointment;

        Test.startTest();
        ProvisioningCertificateController.ResponseWrapper response = ProvisioningCertificateController.checkCallback(wo.Id,true);
        System.assert(response!=null);
        System.assert(response.success==true);
        System.assertEquals('Equipamento Certificado. Sinal Medido: -17.1 dBm',response.message);
        Test.stopTest();
    }

    @isTest
    static void testMethod_checkCallback_fail(){
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        
        WorkStep wo = [SELECT Id 
                    FROM WorkStep
                    WHERE WorkOrderId = :workOrderId
                    Limit 1
        ];


        ServiceAppointment serviceAppointment = [Select 
                    Certificated__c,message_certificate__c,ONU_Signal__c,CTO_Avg_Signal__c
                    From ServiceAppointment 
                    Where WorkOrder__c = :workOrderId Limit 1
        ];
        serviceAppointment.Certificated__c = false;
        serviceAppointment.message_certificate__c = 'Nível de sinal fora dos parâmetros técnico';
        serviceAppointment.ONU_Signal__c = -17.1;
        serviceAppointment.CTO_Avg_Signal__c = -20.1;
        update serviceAppointment;

        Test.startTest();
        ProvisioningCertificateController.ResponseWrapper response = ProvisioningCertificateController.checkCallback(wo.Id, true);
        System.assert(response!=null);
        System.assert(response.success==false);
        System.assertEquals('Nível de sinal fora dos parâmetros técnico. Sinal Medido: ' + serviceAppointment.ONU_Signal__c+'.Média de ONUs Conectadas na CTO '+serviceAppointment.CTO_Avg_Signal__c,response.message);
        Test.stopTest();
    }

    @isTest
    static void testMethod_clearCallbackMessages(){
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        
        WorkStep wo = [SELECT Id 
                    FROM WorkStep
                    WHERE WorkOrderId = :workOrderId
                    Limit 1
        ];
        Test.startTest();
        Boolean response = ProvisioningCertificateController.clearCallbackMessages(wo.Id);
        System.assert(response!=null);
        System.assert(response==true);
        Test.stopTest();
    }

     
}