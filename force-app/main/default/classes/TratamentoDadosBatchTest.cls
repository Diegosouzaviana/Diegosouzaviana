@isTest
public with sharing class TratamentoDadosBatchTest {
    @isTest
    public static void batchTest(){
        Test.startTest();
        Account acc = new Account (Name='Teste', LXD_Email__c='teste@teste.com', LXD_CPF__c='41202445802');
        insert acc;
        Database.executeBatch(new TratamentoDadosBatch());
        Test.stopTest();
    }
}