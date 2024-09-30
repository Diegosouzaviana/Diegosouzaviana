/**
**************************************************************************************************************
* @company          Sys4b
* @author           Guilherme
* @project          DesktopSA
* @name             UpdatePlanSpeedControllerTest
* @description      Test class of  UpdatePlanSpeedController
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2023-09-02   Guilherme                     Initial version. 
******
**/

@isTest
public with sharing class UpdatePlanSpeedControllerTest {
    @TestSetup
    static void setup(){
        
         Id recordTypeCustomer = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
		Id recordTypeService = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        Id recordTypeBilling = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
		Id recordTypeProduct = Schema.sObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();

		WorkType wt = new WorkType(Name = 'Retirada de Equipamento - Cancelamento Compulsório', EstimatedDuration = 10, DurationType = 'Minutes', ExpirationDateServiceOrder__c = 90);
		insert wt;

		Account acc = new Account (Name = 'Teste', LXD_CPF__c = '412.024.458-02', RecordTypeId = recordTypeCustomer, LegacyId__c = '1');
        insert acc;

		Account acc2 = new Account (Name = 'Teste2', LXD_Email__c = 'teste2@teste.com', RecordTypeId = recordTypeService, LegacyId__c = '1', IdPlanoUsuario__c = '1', ShippingStreet = 'Rua Jamil Calil', ShippingCity = 'Americana', ShippingState = 'SP', ShippingPostalCode = '13468-875', LXD_AddressNumber__c = '10');
        insert acc2;

        Account acc3 = new Account (Name = 'Teste2', LXD_Email__c = 'teste2@teste.com', LegacyId__c = '12345', RecordTypeId = recordTypeBilling);
        insert acc3;

		Contact cont2 = new Contact(FirstName = 'Teste2', LastName = 'Teste2',  LegacyId__c = '1', AccountId = acc3.Id);
        insert cont2;

		vlocity_cmt__ObjectClass__c ObjectType = new vlocity_cmt__ObjectClass__c(Name = 'Plano Desktop', vlocity_cmt__IsActive__c = true, vlocity_cmt__ObjectApiName__c = 'Product2');
		insert ObjectType;
		
        Product2 produto = new Product2(Name = 'Teste', ProductCode = 'Teste', RecordTypeId = recordTypeProduct, vlocity_cmt__ObjectTypeId__c = ObjectType.Id);
        insert produto;

        Asset ativo = new Asset(Name = 'GloboPlay',IdPromocao__c = 12350, IdPlanoUsuario__c = 01, AccountId = acc.Id, vlocity_cmt__ServiceAccountId__c = acc2.Id, vlocity_cmt__BillingAccountId__c = acc3.Id, ContactId = cont2.Id, NomeOLT__c = 'Teste', Product2Id = produto.Id, PortaCTO__c = '1');
        insert ativo;
        
        
      DataFactoryTest.makeData();

        Id accountId = [Select id From Account Limit 1].Id;

        Contract contract = new Contract();
        contract.vlocity_cmt__ContractReferenceNumber__c = '1264017';  
        contract.IdPromocao__c = 1230;
        contract.AccountId = accountId;
        insert contract;

        
        Case case1 = new Case();
        case1.accountId = accountId;
        case1.Contrato__c = contract.Id;
        insert case1;

        WorkType wt2 = new WorkType(
                Name = 'Alteração de Plano - Alteração de Velocidade',
                ShouldAutoCreateSvcAppt = true,
                FSL__Due_Date_Offset__c = 60*24*7, 
                DurationType = 'Minutes',
                EstimatedDuration = 60
        );
        insert wt2;

        WorkOrder wo = new WorkOrder(
            AccountId = accountId,
            WorkTypeId = wt2.Id,
            Subject = 'Test 2',
            Street = 'Kerkstraat 2',
            PostalCode = '3581 RD',
            City = 'Utrecht',
            Country = 'NL',
            State = 'CL',
            assetid=ativo.id,
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
            WorkPlanId              = wp.Id,
            ExecutionOrder          = 1
        );
        insert ws;

        vlocity_cmt__ContractLineItem__c contractLI = new vlocity_cmt__ContractLineItem__c();
        contractLI.vlocity_cmt__ContractId__c = contract.Id;
        contractLI.IdPlanoUsuario__c = 1581297;
        insert contractLI;

        ServiceAppointment sa = [SELECT WorkOrder__c From ServiceAppointment Limit 1];
        sa.WorkOrder__c = wo.Id;
        sa.CorrelationId__c='233';
        update sa;
        
    }

    @isTest
    static void testMethod_UpdatePlanSpeed() {
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        
        ServiceAppointment sa = [SELECT Work_Type_SA__c, Work_Subtype_SA__c,
                                        AppointmentNumber, 
                                        WorkOrder__r.Case.Contrato__r.ContractNumber, 
                                        WorkOrder__r.Case.Contrato__c,  
                                        WorkOrder__r.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 
                                        WorkOrder__r.Case.Contrato__r.Prospect__c, 
                                        CorrelationId__c, RequestNumber__c,
                                        WorkOrder__r.Case.Contrato__r.IdPromocao__c,
                                        Id 
                                    FROM ServiceAppointment
                                    WHERE ParentRecordId = :workOrderId
                                    Limit 1
        ];
        
        Test.startTest();
           WorkStep WorkStep = [select id,WorkOrder.Case.PlanoNovo__r.ProductCode,WorkOrder.Case.Contrato__r.Prospect__c,WorkOrder.Asset.ProductCodeFormula__c,WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c,WorkOrder.Asset.IdPromocao__c,WorkOrder.Asset.IdPlanoUsuario__c,workOrderId from WorkStep   LIMIT 1];

        UpdatePlanSpeedWrapper response = UpdatePlanSpeedController.UpdatePlanSpeed(WorkStep,true);
        // System.assert(response==null);
        Test.stopTest();    
    }
    
    
   
    @isTest
    static void testMethod_UpdatePlanSpeed_Rerun() {
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        
        ServiceAppointment sa = [SELECT Work_Type_SA__c, Work_Subtype_SA__c,
                                        AppointmentNumber, 
                                        WorkOrder__r.Case.Contrato__r.ContractNumber, 
                                        WorkOrder__r.Case.Contrato__c,  
                                        WorkOrder__r.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 
                                        WorkOrder__r.Case.Contrato__r.Prospect__c, 
                                        CorrelationId__c, RequestNumber__c,
                                        WorkOrder__r.Case.Contrato__r.IdPromocao__c,
                                        Id 
                                    FROM ServiceAppointment
                                    WHERE ParentRecordId = :workOrderId
                                    Limit 1
        ];
        sa.CorrelationId__c = Util.generateRandomString();
        
        Test.startTest();
                WorkStep WorkStep = [select id,WorkOrder.Case.PlanoNovo__r.ProductCode,WorkOrder.Case.Contrato__r.Prospect__c,WorkOrder.Asset.ProductCodeFormula__c,WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c,WorkOrder.Asset.IdPromocao__c,WorkOrder.Asset.IdPlanoUsuario__c,workOrderId from WorkStep   LIMIT 1];

        UpdatePlanSpeedWrapper response = UpdatePlanSpeedController.UpdatePlanSpeed(WorkStep,true);
        //System.assert(response==null);
        Test.stopTest();    
    }

     
   
    
    
    @isTest
    static void testMethod_UpdatePlanSpeedf() {
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        
        ServiceAppointment sa = [SELECT Work_Type_SA__c, Work_Subtype_SA__c,
                                        AppointmentNumber, 
                                        WorkOrder__r.Case.Contrato__r.ContractNumber, 
                                        WorkOrder__r.Case.Contrato__c,  
                                        WorkOrder__r.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 
                                        WorkOrder__r.Case.Contrato__r.Prospect__c, 
                                        CorrelationId__c, RequestNumber__c,
                                        WorkOrder__r.Case.Contrato__r.IdPromocao__c,
                                        Id 
                                    FROM ServiceAppointment
                                    WHERE ParentRecordId = :workOrderId
                                    Limit 1
        ];
        
        Test.startTest();
           WorkStep WorkStep = [select id,WorkOrder.Case.PlanoNovo__r.ProductCode,WorkOrder.Case.Contrato__r.Prospect__c,WorkOrder.Asset.ProductCodeFormula__c,WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c,WorkOrder.Asset.IdPromocao__c,WorkOrder.Asset.IdPlanoUsuario__c,workOrderId from WorkStep   LIMIT 1];

        UpdatePlanSpeedWrapper response = UpdatePlanSpeedController.UpdatePlanSpeed(WorkStep,true);
        // System.assert(response==null);
        Test.stopTest();    
    }
     @isTest
    static void testMethod_UpdatePlanSpeedFalse() {
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        
        ServiceAppointment sa = [SELECT Work_Type_SA__c, Work_Subtype_SA__c,
                                        AppointmentNumber, 
                                        WorkOrder__r.Case.Contrato__r.ContractNumber, 
                                        WorkOrder__r.Case.Contrato__c,  
                                        WorkOrder__r.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 
                                        WorkOrder__r.Case.Contrato__r.Prospect__c, 
                                        CorrelationId__c, RequestNumber__c,
                                        WorkOrder__r.Case.Contrato__r.IdPromocao__c,
                                        Id 
                                    FROM ServiceAppointment
                                    WHERE ParentRecordId = :workOrderId
                                    Limit 1
        ];
        
        Test.startTest();
           WorkStep WorkStep = [select id,WorkOrder.Case.PlanoNovo__r.ProductCode,WorkOrder.Case.Contrato__r.Prospect__c,WorkOrder.Asset.ProductCodeFormula__c,WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c,WorkOrder.Asset.IdPromocao__c,WorkOrder.Asset.IdPlanoUsuario__c,workOrderId from WorkStep   LIMIT 1];

        UpdatePlanSpeedWrapper response = UpdatePlanSpeedController.UpdatePlanSpeed(WorkStep,false);
         //System.assert(response!=null);
        Test.stopTest();    
    }
 @isTest
    static void testMethod_UpdatePlanSpeed_RerunFalse() {
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        
        ServiceAppointment sa = [SELECT Work_Type_SA__c, Work_Subtype_SA__c,
                                        AppointmentNumber, 
                                        WorkOrder__r.Case.Contrato__r.ContractNumber, 
                                        WorkOrder__r.Case.Contrato__c,  
                                        WorkOrder__r.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 
                                        WorkOrder__r.Case.Contrato__r.Prospect__c, 
                                        CorrelationId__c, RequestNumber__c,
                                        WorkOrder__r.Case.Contrato__r.IdPromocao__c,
                                        Id 
                                    FROM ServiceAppointment
                                    WHERE ParentRecordId = :workOrderId
                                    Limit 1
        ];
        sa.CorrelationId__c = Util.generateRandomString();
        
        Test.startTest();
                WorkStep WorkStep = [select id,WorkOrder.Case.PlanoNovo__r.ProductCode,WorkOrder.Case.Contrato__r.Prospect__c,WorkOrder.Asset.ProductCodeFormula__c,WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c,WorkOrder.Asset.IdPromocao__c,WorkOrder.Asset.IdPlanoUsuario__c,workOrderId from WorkStep   LIMIT 1];

        UpdatePlanSpeedWrapper response = UpdatePlanSpeedController.UpdatePlanSpeed(WorkStep,false);
        //System.assert(response!=null);
        Test.stopTest();    
    }
     @isTest
    static void testMethod_UpdatePlanSpeedErrorFalse() {
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        ServiceAppointment sa = [SELECT WorkOrder__c From ServiceAppointment Limit 1];
        sa.WorkOrder__c = null;
        update sa;

        sa = [SELECT Work_Type_SA__c, Work_Subtype_SA__c,
                                        AppointmentNumber, 
                                        WorkOrder__r.Case.Contrato__r.ContractNumber, 
                                        WorkOrder__r.Case.Contrato__c,  
                                        WorkOrder__r.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c,
                                        WorkOrder__r.Case.Contrato__r.Prospect__c,  
                                        CorrelationId__c, RequestNumber__c,
                                        WorkOrder__r.Case.Contrato__r.IdPromocao__c,
                                        Id 
                                    FROM ServiceAppointment
                                    WHERE ParentRecordId = :workOrderId
                                    Limit 1
        ];
        
        Test.startTest();
           WorkStep WorkStep = [select id,WorkOrder.Case.PlanoNovo__r.ProductCode,WorkOrder.Case.Contrato__r.Prospect__c,WorkOrder.Asset.ProductCodeFormula__c,WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c,WorkOrder.Asset.IdPromocao__c,WorkOrder.Asset.IdPlanoUsuario__c,workOrderId from WorkStep   LIMIT 1];

        UpdatePlanSpeedWrapper response = UpdatePlanSpeedController.UpdatePlanSpeed(WorkStep,False);
        //System.assert(response==null);
        Test.stopTest();    
    }
 @isTest
    static void testMethod_UpdatePlanSpeedError() {
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
        WorkOrder wosemasset =[SELECT id,assetid From WorkOrder where id =:workOrderId Limit 1];
        wosemasset.assetid = null;
        update wosemasset;
        ServiceAppointment sa = [SELECT WorkOrder__c From ServiceAppointment Limit 1];
        sa.WorkOrder__c = null;
        
        update sa;

        sa = [SELECT Work_Type_SA__c, Work_Subtype_SA__c,
                                        AppointmentNumber, 
                                        WorkOrder__r.Case.Contrato__r.ContractNumber, 
                                        WorkOrder__r.Case.Contrato__c,  
                                        WorkOrder__r.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 
                                        WorkOrder__r.Case.Contrato__r.Prospect__c, 
                                        CorrelationId__c, RequestNumber__c,
                                        WorkOrder__r.Case.Contrato__r.IdPromocao__c,
                                        Id 
                                    FROM ServiceAppointment
                                    WHERE ParentRecordId = :workOrderId
                                    Limit 1
        ];
        
        Test.startTest();
           WorkStep WorkStep = [select id,WorkOrder.Case.PlanoNovo__r.ProductCode,WorkOrder.Asset.ProductCodeFormula__c,WorkOrder.Case.Contrato__r.Prospect__c,WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c,WorkOrder.Asset.IdPromocao__c,WorkOrder.Asset.IdPlanoUsuario__c,workOrderId from WorkStep   LIMIT 1];

        UpdatePlanSpeedWrapper response = UpdatePlanSpeedController.UpdatePlanSpeed(WorkStep,false);
        //System.assert(response==null);
        Test.stopTest();    
    }
    @isTest
    static void testMethod_UpdatePlanSpeedasset() {
        Id workOrderId = [Select Id From WorkOrder Limit 1].Id;
         WorkOrder wosemasset =[SELECT id,assetid From WorkOrder where id =:workOrderId Limit 1];
        wosemasset.assetid = null;
        update wosemasset;
        ServiceAppointment sa = [SELECT Work_Type_SA__c, Work_Subtype_SA__c,
                                        AppointmentNumber, 
                                        WorkOrder__r.Case.Contrato__r.ContractNumber, 
                                        WorkOrder__r.Case.Contrato__c,  
                                        WorkOrder__r.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c, 
                                        WorkOrder__r.Case.Contrato__r.Prospect__c, 
                                        CorrelationId__c, RequestNumber__c,
                                        WorkOrder__r.Case.Contrato__r.IdPromocao__c,
                                        Id 
                                    FROM ServiceAppointment
                                    WHERE ParentRecordId = :workOrderId
                                    Limit 1
        ];
         UpdatePlanSpeedWrapper uPWrapper    = new UpdatePlanSpeedWrapper();
             //UpdatePlanSpeedWrapper('Teste',233,'Teste', '1264017', '1', null, 12350, 1);
        Test.startTest();
           WorkStep WorkStep = [select id,WorkOrder.Case.PlanoNovo__r.ProductCode,WorkOrder.Case.Contrato__r.Prospect__c,WorkOrder.Asset.ProductCodeFormula__c,WorkOrder.Case.Contrato__r.vlocity_cmt__ContractReferenceNumber__c,WorkOrder.Asset.IdPromocao__c,WorkOrder.Asset.IdPlanoUsuario__c,workOrderId from WorkStep   LIMIT 1];

        UpdatePlanSpeedWrapper response = UpdatePlanSpeedController.UpdatePlanSpeed(WorkStep,false);
       //  System.assert(response==null);
        Test.stopTest();    
    }
    
}