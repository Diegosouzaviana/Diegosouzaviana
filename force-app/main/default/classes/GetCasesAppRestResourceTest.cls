// Classe: GetCasesAppRestResource
@IsTest
private class GetCasesAppRestResourceTest {
    
    @TestSetup
    static void setupTestData() {
        
        Account billingAccount = new Account(
            Name = 'Conta ADM', 
            LegacyId__c = 'ADM123');
    	insert billingAccount;
        
        Account testAccount = new Account(
            Name = 'Teste Account',
            LXD_CPF__c = '12345678900'
        );
        insert testAccount;
        
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
        	StartDate = Date.today()
        );
        insert testContract;
        
        Asset testAsset = new Asset(
        	Name = 'Produto Teste',
        	vlocity_cmt__BillingAccountId__c = billingAccount.Id,
            vlocity_cmt__ContractId__c = testContract.Id,
            AccountId = testAccount.Id
    	);
    	insert testAsset;
        
        

        List<Case> testCases = new List<Case>{
            new Case(
                Status = 'Em Atendimento',
                Area_de_atendimento__c = 'SAC',
                Tema__c = 'Ativo',
                Tipo__c = 'Informação',
                Motive__c = 'AtivoNPS',
                Submotive__c = 'Ativo NPS',
                Solution__c = 'Em andamento',
                AccountId = testAccount.Id,
                AssetId = testAsset.Id
            ),
            new Case(
                Status = 'Finalizado',
                Area_de_atendimento__c = 'SAC',
                Tema__c = 'Ativo',
                Tipo__c = 'Informação',
                Motive__c = 'AtivoNPS',
                Submotive__c = 'Ativo NPS',
                Solution__c = 'Encerrado por operações',
                AccountId = testAccount.Id,
                AssetId = testAsset.Id
            )
        };
        insert testCases;
    }

    @IsTest
    static void testGetCasesByDocument() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CasesApp/12345678900/ADM123';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<Case> resultCases = GetCasesAppRestResource.getCasesByDocument();
        Test.stopTest();

        System.assertNotEquals(null, resultCases, 'A resposta não deve ser nula');
        System.assertEquals(2, resultCases.size(), 'Deve retornar exatamente 2 casos');
    }

    @IsTest
    static void testGetCasesByDocumentInvalidCPF() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CasesApp/00000000000/ADM123';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<Case> resultCases = GetCasesAppRestResource.getCasesByDocument();
        Test.stopTest();

        System.assertEquals(0, resultCases.size(), 'Deve retornar uma lista vazia para CPF inexistente');
    }

    @IsTest
    static void testGetCasesByDocumentWithoutParams() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CasesApp/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<Case> resultCases = GetCasesAppRestResource.getCasesByDocument();
        Test.stopTest();

        System.assertEquals(null, resultCases, 'Deve retornar null para requisição inválida');
        System.assertEquals(400, RestContext.response.statusCode, 'Deve retornar erro 400 para parâmetros ausentes');
    }

    @IsTest
    static void testGetCasesByDocumentWithLimitParam() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CasesApp/12345678900/ADM123';
        req.httpMethod = 'GET';
        req.params.put('limit', '1');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        List<Case> resultCases = GetCasesAppRestResource.getCasesByDocument();
        Test.stopTest();

        System.assertEquals(1, resultCases.size(), 'Deve respeitar o parâmetro de limite');
    }
}