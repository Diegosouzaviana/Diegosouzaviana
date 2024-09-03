@isTest
public with sharing class CancelamentoCompulsorioServiceTest {
    
    @isTest
    static void testTriggerLogic() {
        
        Id recordTypeCustomer = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id recordTypeService = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        Id recordTypeBilling = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        Id recordTypeProduct = Schema.sObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();

        Account acc = new Account (Name = 'Teste', LXD_CPF__c = '412.024.458-02', RecordTypeId = recordTypeCustomer, LegacyId__c = '1');
        insert acc;
        Account acc2 = new Account (Name = 'Teste2', LXD_Email__c = 'teste2@teste.com', RecordTypeId = recordTypeService, LegacyId__c = '1', IdPlanoUsuario__c = '1', ParentId = acc.Id, ShippingStreet = 'Rua Jamil Calil', ShippingCity = 'Americana', ShippingState = 'SP', ShippingPostalCode = '13468-875', LXD_AddressNumber__c = '10');
        insert acc2;
        Account acc3 = new Account (Name = 'Teste2', LXD_Email__c = 'teste2@teste.com', RecordTypeId = recordTypeBilling, ParentId = acc.Id);
        insert acc3;
        Contact cont2 = new Contact(FirstName = 'Teste2', LastName = 'Teste2',  LegacyId__c = '1', AccountId = acc3.Id);
        insert cont2;
        Product2 produto = new Product2(Name = 'Teste', ProductCode = 'Teste', RecordTypeId = recordTypeProduct);
        insert produto;
        Asset ativo = new Asset(Name = 'GloboPlay', IdPlanoUsuario__c = 01, AccountId = acc.Id, vlocity_cmt__ServiceAccountId__c = acc2.Id, vlocity_cmt__BillingAccountId__c = acc3.Id, ContactId = cont2.Id, NomeOLT__c = 'Teste', Product2Id = produto.Id);
        insert ativo;

        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId(), Username = 'Victor Santos')) {
            Account contaBilling = [SELECT Id FROM Account WHERE RecordType.Name = 'Billing' LIMIT 1];
            contaBilling.CancelamentoCompulsorio__c = true;
            update contaBilling;
        }
        Test.stopTest();
    }
}