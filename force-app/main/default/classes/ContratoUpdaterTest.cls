@isTest
public with sharing class ContratoUpdaterTest {
    @isTest
    static void makeData(){
        Id recordTypeCustomer = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id recordTypeService = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        Id recordTypeBilling = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();

        User syncUser = [SELECT Id FROM User WHERE Name = 'Sync de Dados'];

        System.runAs(syncUser){
            Account acc = new Account (Name = 'Teste', LXD_CPF__c = '411.024.458-02', RecordTypeId = recordTypeCustomer, LegacyId__c = '1');
        insert acc;
        
        Account acc2 = new Account (Name = 'Teste2', LXD_Email__c = 'teste2@teste.com', LXD_CPF__c = '412.024.458-02', RecordTypeId = recordTypeService, LegacyId__c = '1', IdPlanoUsuario__c = '1');
        insert acc2;

        Account acc3 = new Account (Name = 'Teste2', LXD_Email__c = 'teste2@teste.com', LXD_CPF__c = '413.024.458-02', RecordTypeId = recordTypeBilling, LegacyId__c = '1');
        insert acc3;
        
        Contact cont = new Contact(FirstName = 'Teste', LastName = 'Teste',  LegacyId__c = '1');
        insert cont;

        Contract contrato = new Contract(vlocity_cmt__ContractReferenceNumber__c = '1',Status = 'Pre-Ativo', AccountId = acc2.Id, IdPlanoUsuario__c = '01');
        insert contrato;

        Contract contrato2 = new Contract(vlocity_cmt__ContractReferenceNumber__c = '1',Status = 'Pre-Bloqueado', AccountId = acc2.Id, IdPlanoUsuario__c = '01');
        insert contrato2;

        Contract contrato3 = new Contract(vlocity_cmt__ContractReferenceNumber__c = '1',Status = 'Pre-Cancelado', AccountId = acc2.Id, IdPlanoUsuario__c = '01');
        insert contrato3;

        Product2 produto = new Product2(Name = 'Teste', ProductCode = 'Teste');
        insert produto;

        vlocity_cmt__ContractLineItem__c itemContrato = new vlocity_cmt__ContractLineItem__c(LegacyId__c = '1', vlocity_cmt__ContractId__c = contrato.Id, ProdutoAuxiliar__c = 'Teste', NomeOLT__c = 'Teste');
        insert itemContrato;

        Contact cont2 = new Contact(FirstName = 'Teste2', LastName = 'Teste2',  LegacyId__c = '1', AccountId = acc.Id);
        insert cont2;

        Asset ativoComercial = new Asset(Name = 'GloboPlay', IdPlanoUsuario__c = 01, AccountId = acc.Id, ContactId = cont2.Id, NomeOLT__c = 'Teste');
        insert ativoComercial;

        OLT__c olt = new OLT__c (Name = 'Teste', CodeOLT__c = 'Teste');
        insert olt;

        vlocity_cmt__PriceList__c priceList = new vlocity_cmt__PriceList__c (Name = 'Preços Desktop', vlocity_cmt__Code__c = 'Teste');
        insert priceList;
        }
        
    }


    //@isTest
    //public static void testContractInsert(){

        //List<User> lstUser = [SELECT Id FROM User];
        //System.debug('User: ' + lstUser.size());
        //List<Id> lstContratoIds = new List<Id>();

        //Test.startTest();
        //for (Contract contrato : [SELECT Id FROM Contract]) {
            //lstContratoIds.add(contrato.Id);
        //}
        //ContratoUpdater.updateContractStatus(lstContratoIds);
        //Test.stopTest();
    //}
}