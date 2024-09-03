@isTest
private class CancelamentoCompulsorioRestResourceTest{
	@TestSetup
	static void makeData(){
		Id recordTypeCustomer = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
		Id recordTypeService = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        Id recordTypeBilling = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
		Id recordTypeProduct = Schema.sObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();

		WorkType wt = new WorkType(Name = 'Retirada de Equipamento - Cancelamento Compulsório', EstimatedDuration = 10, DurationType = 'Minutes', ExpirationDateServiceOrder__c = 90);
		insert wt;

		Account acc = new Account (Name = 'Teste', LXD_CPF__c = '412.024.458-02', RecordTypeId = recordTypeCustomer, LegacyId__c = '1');
        insert acc;

		Account acc2 = new Account (Name = 'Teste2', LXD_Email__c = 'teste2@teste.com', RecordTypeId = recordTypeService, LegacyId__c = '1', IdPlanoUsuario__c = '1', ParentId = acc.Id, ShippingStreet = 'Rua Jamil Calil', ShippingCity = 'Americana', ShippingState = 'SP', ShippingPostalCode = '13468-875', LXD_AddressNumber__c = '10');
        insert acc2;

        Account acc3 = new Account (Name = 'Teste2', LXD_Email__c = 'teste2@teste.com', LegacyId__c = '12345', RecordTypeId = recordTypeBilling, ParentId = acc.Id);
        insert acc3;

		Contact cont2 = new Contact(FirstName = 'Teste2', LastName = 'Teste2',  LegacyId__c = '1', AccountId = acc3.Id);
        insert cont2;

		vlocity_cmt__ObjectClass__c ObjectType = new vlocity_cmt__ObjectClass__c(Name = 'Plano Desktop', vlocity_cmt__IsActive__c = true, vlocity_cmt__ObjectApiName__c = 'Product2');
		insert ObjectType;
		
        Product2 produto = new Product2(Name = 'Teste', ProductCode = 'Teste', RecordTypeId = recordTypeProduct, vlocity_cmt__ObjectTypeId__c = ObjectType.Id);
        insert produto;

        Asset ativo = new Asset(Name = 'GloboPlay', IdPlanoUsuario__c = 01, AccountId = acc.Id, vlocity_cmt__ServiceAccountId__c = acc2.Id, vlocity_cmt__BillingAccountId__c = acc3.Id, ContactId = cont2.Id, NomeOLT__c = 'Teste', Product2Id = produto.Id, PortaCTO__c = '1');
        insert ativo;
	}

	@isTest
	static void testHttpPost() {

		//As Per Best Practice it is important to instantiate the Rest Context
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/CancelamentoCompulsorio'; 
		req.httpMethod = 'POST';

		List<CancelamentoCompulsorioRestResource.AccountIdWrapper> requestList = new List<CancelamentoCompulsorioRestResource.AccountIdWrapper>();
		CancelamentoCompulsorioRestResource.AccountIdWrapper request = new CancelamentoCompulsorioRestResource.AccountIdWrapper();
		request.legacyId = '12345';
		requestList.add(request);

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
		List<CancelamentoCompulsorioRestResource.ResponseWrapper> actual = CancelamentoCompulsorioRestResource.doPost(requestList);
		Test.stopTest();

	}
}