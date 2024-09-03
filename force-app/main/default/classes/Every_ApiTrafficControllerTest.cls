@isTest
public class Every_ApiTrafficControllerTest {
    
    @isTest
    static void testInvokeMethodSuccess() {
        
        
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
            ass.PlanLogin__c = 'classedetestes' + i;
            assetList.add(ass);
        }

        insert assetList;
        
        Asset testAsset = assetList[0];

        // Mock para a classe AssetSelector
        Test.startTest();

        // Define os parâmetros de entrada
        Map<String, Object> inputMap = new Map<String, Object>{
            'AssetId' => testAsset.Id,
            'Url' => '/test-url/<planlogin>'
        };
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Chama o método invokeMethod
        Every_ApiTrafficController controller = new Every_ApiTrafficController();
        String response = (String)controller.invokeMethod('callTrafficControllerApi', inputMap, outMap, options);
        
        Test.stopTest();

        // Verifica a resposta e o mapa de saída
        System.assert(outMap.containsKey('Response'), 'O mapa de saída deve conter a chave "Response".');
        Map<String, Object> responseMap = (Map<String, Object>)outMap.get('Response');
        
    }

   
}