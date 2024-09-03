@IsTest
public class WorkOrderHandlerTest {
    @TestSetup
    static void makeData(){
        DataFactoryTest.makeData();
    }
    
    @IsTest
    static void WorkOrderHandlerTest() {
        List<List<String>> wOrderList = new List<List<String>>();
        List<String> oWList = new List<String>();
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
            State = 'AM'
        );
        insert wo;

        WorkPlanTemplate wpt = new WorkPlanTemplate(
            Name                    = 'Auto Inspeção',
            RelativeExecutionOrder  = 2,
            Description             = 'Alteração de Plano, Manutenção e Serviços adicionais'
        );
        insert wpt;

        WorkPlan wp = new WorkPlan(
            Name                    = 'Auto Inspeção',
            WorkOrderId             = wo.Id
            //WorkPlanTemplateId      = wpt.Id
        );
        insert wp;

        Id WorkOederId = [SELECT id FROM WorkOrder LIMIT 1].ID;
        System.debug('WorkOederId '+WorkOederId);

        WorkStep ws = new WorkStep(
            Name                    = 'CTO fechada com o número da CTO',
            Status                  = 'New',
            WorkPlanId              = wp.Id
        );
        insert ws;
        WorkStep ws2 = [SELECT Name, WorkOrder.WorkOrderNumber, id FROM WorkStep WHERE WorkOrderId = :WorkOederId];
        oWList.add(wo.Id);
        wOrderList.add(oWList);
        System.debug('workstep name '+ws2.Name+' order '+ws2.WorkOrder.WorkOrderNumber);
        WorkOrderHandler.WorkOrderHandler(wOrderList);
    }

    
    @IsTest
    static void WorkOrderSchedTest() {
        List<List<String>> wOrderList = new List<List<String>>();
        List<String> oWList = new List<String>();
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
            State = 'AM',
            SchedulingManagement__c = false
        );
        insert wo;

        WorkPlanTemplate wpt = new WorkPlanTemplate(
            Name                    = 'Auto Inspeção',
            RelativeExecutionOrder  = 2,
            Description             = 'Alteração de Plano, Manutenção e Serviços adicionais'
        );
        insert wpt;

        WorkPlan wp = new WorkPlan(
            Name                    = 'Auto Inspeção',
            WorkOrderId             = wo.Id
            //WorkPlanTemplateId      = wpt.Id
        );
        insert wp;

        Id WorkOederId = [SELECT id FROM WorkOrder LIMIT 1].ID;
        System.debug('WorkOederId '+WorkOederId);

        WorkStep ws = new WorkStep(
            Name                    = 'CTO fechada com o número da CTO',
            Status                  = 'New',
            WorkPlanId              = wp.Id
        );
        insert ws;
        WorkStep ws2 = [SELECT Name, WorkOrder.WorkOrderNumber, id FROM WorkStep WHERE WorkOrderId = :WorkOederId];
        oWList.add(wo.Id);
        wOrderList.add(oWList);
        System.debug('workstep name '+ws2.Name+' order '+ws2.WorkOrder.WorkOrderNumber);

        Test.StartTest();
        wo.SchedulingManagement__c = true;
        update wo;
        Test.StopTest();

    }

    @IsTest
    static void WorkOrderCheckStepsTest() {
        List<List<String>> wOrderList = new List<List<String>>();
        List<String> oWList = new List<String>();
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
            State = 'AM',
            SchedulingManagement__c = false,
            ValidationCompletedSteps__c = false
        );
        insert wo;

        WorkPlanTemplate wpt = new WorkPlanTemplate(
            Name                    = 'Teste 123',
            RelativeExecutionOrder  = 2,
            Description             = 'Alteração de Plano, Manutenção e Serviços adicionais'
        );
        insert wpt;

        WorkPlan wp = new WorkPlan(
            Name                    = 'Teste 123',
            WorkOrderId             = wo.Id
            //WorkPlanTemplateId      = wpt.Id
        );
        insert wp;

        Id WorkOederId = [SELECT id FROM WorkOrder LIMIT 1].ID;
        System.debug('WorkOederId '+WorkOederId);

        List<WorkStep> listWs = new List<WorkStep>();
        WorkStep ws = new WorkStep(
            Name                    = 'CTO fechada com o número da CTO',
            Status                  = 'New',
            WorkPlanId              = wp.Id
        );
        listWs.add(ws);
        
        WorkStep ws1 = new WorkStep(
            Name                    = 'CTO fechada com o número da CTO2',
            Status                  = 'New',
            WorkPlanId              = wp.Id
        );
        listWs.add(ws1);
        insert listWs;

        ws.Status = 'Concluído';
        update ws;
        Test.StartTest();
        String msg;
        try{
            wo.ValidationCompletedSteps__c = true;
            update wo;
        }catch(Exception ex){
            msg = ex.getMessage();
        }
        Test.StopTest();

    }
}