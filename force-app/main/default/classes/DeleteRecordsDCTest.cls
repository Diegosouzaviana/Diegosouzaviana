@isTest
public class DeleteRecordsDCTest {
    @TestSetup
    static void makedata(){
        Id rtCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id rtBilling = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id rtPlanChange = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Alteração de plano').getRecordTypeId();

        Date starDate = System.today().addDays(-3);
        Datetime dueDate = Datetime.now().addDays(-2);
        Datetime yesterday = Datetime.now().addDays(-1);

        List<Account> accList = new List<Account>();
        List<Account> billingList = new List<Account>();
        List<Contract> contractList = new List<Contract>();
        List<Asset> assetList = new List<Asset>();
        List<Case> caseList = new List<Case>();
        List<WorkOrder> woList = new List<WorkOrder>();
        List<ServiceAppointment> saList = new List<ServiceAppointment>();

        for(Integer i = 0; i < 10 ; i ++){
            Account acc = new Account();
            acc.Name = 'Customer'+i;
            acc.LXD_CPF__c = i+'.806.158-02';
            acc.RecordTypeId = rtCustomer;
            accList.add(acc);
        }

        insert accList;

        for(Integer i = 0; i < 10 ; i ++){
            Account acc = new Account();
            acc.Name = 'Billing'+i;
            acc.LegacyId__c = String.valueOf(i);
            acc.RecordTypeId = rtBilling;
            acc.ParentId = accList[i].Id;
            billingList.add(acc);
        }

        insert billingList;

        for(Integer i = 0; i < 10 ; i ++){
            Contract ct = new Contract();
            ct.StartDate = starDate;
            ct.AccountId = accList[i].Id;
            contractList.add(ct);
        }

        insert contractList;

        for(Integer i = 0; i < 10 ; i ++){
            Asset ass = new Asset();
            ass.Name = 'Asset'+i;
            ass.AccountId = accList[i].Id;
            ass.vlocity_cmt__BillingAccountId__c = billingList[i].Id;
            ass.vlocity_cmt__ContractId__c = contractList[i].Id;
            assetList.add(ass);
        }

        insert assetList;

        for(Integer i = 0; i < 10 ; i ++){
            Case cs = new Case();
            cs.AccountId = accList[i].Id;
            cs.Contrato__c = contractList[i].Id;
            caseList.add(cs);
        }

        insert caseList;

        for(Integer i = 0; i < 10 ; i ++){
            WorkOrder wo = new WorkOrder();
            wo.AccountId = accList[i].Id;
            wo.AssetId = assetList[i].Id;
            wo.CaseId = caseList[i].Id;
            wo.State = 'SP';
            wo.City = 'Campinas';
            wo.Street = 'rua Teste';
            wo.PostalCode = '13056500';
            woList.add(wo);
        }

        insert woList;

        for(Integer i = 0; i < 10 ; i ++){
            ServiceAppointment sa = new ServiceAppointment();
            sa.RecordTypeId = rtPlanChange;
            sa.WorkOrder__c = woList[i].Id;
            sa.ParentRecordId = woList[i].Id;
            sa.EarliestStartTime = dueDate;
            sa.DueDate = dueDate;
            sa.CodeGroup__c = null;
            sa.Work_Type_SA__c = 'Ativação';
            sa.Status = 'Nenhuma';
            saList.add(sa);
        }

        insert saList;

        for(ServiceAppointment sa : saList){
            Test.setCreatedDate(sa.Id, yesterday);
        }
    }

    @isTest
    static void testDeleteRecordsDCBatchSchedule(){
        test.startTest();
        DeleteRecordsDCBatchSchedule sc = new DeleteRecordsDCBatchSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sc);
        test.stopTest();

	}   
}