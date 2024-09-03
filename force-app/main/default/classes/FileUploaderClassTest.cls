@isTest
public class FileUploaderClassTest {
    	@TestSetup()
        static void setup(){
            
         Account acc = new Account(
                Name = 'New Account Name',
                CNPJ__c = '49401667000195',
                LXD_CPF__c = '40094880000',
                LXD_Email__c='teste@gmail.com',
                BillingStreet = 'R. Dr. Marcos Antonio Samartine, 99',
                LXD_NewAddressComplement__c = null,
                BillingPostalCode = '13.067-450',
                LXD_AddressNeighborhood__c = 'Nucleo Habitacional Boa Vista',
                BillingCity = 'Campinas',
                BillingState = 'SP',
                ShippingStreet = 'Rua Carioba',
                LXD_AddressNumber__c = '99', 
                ShippingPostalCode = '13472560',
                ShippingCity = 'Americana',
                ShippingState = 'SP'
          );
          insert acc;
        
        // Criação de registros fictícios de WorkOrder e WorkStep
        WorkOrder workOrder = new WorkOrder(
            Status = 'Open',
            AccountId = acc.Id, 

            Street = 'Kerkstraat 2 Test',
            PostalCode = '3581 RD',
            City = 'Utrecht',
            Country = 'NL',
            State = 'AM'
        );
        insert workOrder;

        // Criação de um plano de trabalho (WorkPlan)
        List<WorkPlan> listPlans = new List<WorkPlan>();
        WorkPlan workPlan = new WorkPlan(
                        Name = 'Manutenção Corretiva',
                        WorkOrderId = workOrder.Id
        ); 
        WorkPlan workPlan2 = new WorkPlan(
            Name = 'Auto Inspeção',
            WorkOrderId = workOrder.Id
        );
        listPlans.add(workPlan);
        listPlans.add(workPlan2);
        insert listPlans;
        
        List<WorkStep> listSteps = new List<WorkStep>();
        
        // Criação de registros fictícios de WorkStep
        WorkStep workStep1 = new WorkStep(
                        Name                    = workPlan.Name,
                        Status                  = 'New',
                        WorkPlanId              = workPlan.Id
                    );
                    listSteps.add(workStep1);
        // Criação de registros fictícios de WorkStep
        WorkStep workStep2 = new WorkStep(
                        Name                    = workPlan.Name,
                        Status                  = 'Completed',
                        WorkPlanId              = workPlan.Id
                    );
            
        listSteps.add(workStep2);

        WorkStep workStep3 = new WorkStep(
            Name                    = workPlan.Name,
            Status                  = 'New',
            WorkPlanId              = workPlan2.Id
        );
        listSteps.add(workStep3);
        
        WorkStep workStep4 = new WorkStep(
            Name                    = workPlan.Name,
            Status                  = 'New',
            WorkPlanId              = workPlan2.Id
        );
        listSteps.add(workStep4);

        insert listSteps;
    }
        
    
    @isTest
    public static void testVerifySteps() {
        WorkOrder workOrder = [SELECT id FROM WorkOrder WHERE Street =: 'Kerkstraat 2 Test' LIMIT 1];
        WorkPlan workPlan = [SELECT id FROM WorkPlan WHERE WorkOrderId =: workOrder.Id LIMIT 1];
        WorkStep workStep = [SELECT id FROM WorkStep WHERE WorkPlanId =: workPlan.Id LIMIT 1];
        // Chamada ao método verifySteps
        Test.StartTest();
        FileUploaderClass.verifySteps(workOrder.Id, workPlan.Id, workStep.id);
        Test.StopTest();
        
    }
    
    @isTest
    public static void testException() {
        WorkOrder workOrder = [SELECT id FROM WorkOrder WHERE Street =: 'Kerkstraat 2 Test' LIMIT 1];
        WorkPlan workPlan = [SELECT id FROM WorkPlan WHERE WorkOrderId =: workOrder.Id LIMIT 1];
        WorkStep workStep = [SELECT id FROM WorkStep WHERE WorkPlanID =: workPlan.Id LIMIT 1];
        // Chamada ao método verifySteps
        Test.StartTest();
        try{
        	FileUploaderClass.verifySteps('', workPlan.Id, workStep.id);
        }catch (Exception e) {
            
        }
        Test.StopTest();
        
    }
}