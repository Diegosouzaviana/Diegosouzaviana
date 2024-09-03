@isTest
public with sharing class Every_CaseBatchTest {
    static testMethod void testEvery_CaseBatch() {
        Case testCase = new Case(Status = 'Em Andamento', StatusSLAPicklist__c = 'Estourado', SLAEstourado__c = true);
        insert testCase;

        Test.startTest();
            Every_CaseBatch batch = new Every_CaseBatch();
            Database.executeBatch(batch);
        Test.stopTest();

        testCase = [SELECT Id, Status, StatusSLAPicklist__c, SLAEstourado__c FROM Case WHERE Id = :testCase.Id];
    }
}