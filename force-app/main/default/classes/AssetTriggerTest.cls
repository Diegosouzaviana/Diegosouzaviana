@isTest
public class AssetTriggerTest {
    
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        vlocity_cmt__ObjectClass__c productType = new vlocity_cmt__ObjectClass__c(
            Name = 'Plano Desktop',
            vlocity_cmt__ObjectApiName__c = 'Product2'
        );
        insert productType;

        Product2 product = new Product2(
            Name = 'Asset Teste',
            Family = 'Internet',
            vlocity_cmt__ObjectTypeId__c = productType.Id
        );
        insert product;

        Asset oldAsset = new Asset(
            Name = 'Asset Teste',
            Status = 'B',
            LegacyId__c = '123456',
            AccountId = testAccount.Id,
            Product2Id = product.Id
        );
        insert oldAsset;

        Case caseRecord = new Case(
            Subject = 'Test Case',
            Status = 'Em Atendimento',
            AssetId = oldAsset.Id
        );
        insert caseRecord;

        WorkOrder workOrderRecord = new WorkOrder(
            Subject = 'Test WorkOrder',
            AssetId = oldAsset.Id,
            AccountId = testAccount.Id,
            Street = 'Rua teste',
            City = 'Cidade teste',
            State = 'SP',
            PostalCode = '13.860-000'
        );
        insert workOrderRecord;
    }

    @isTest
    static void testUpdateCaseAndWorkOrderWithNewAsset() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Asset newAsset = new Asset(
            Name = 'Asset Teste',
            Status = 'A',
            LegacyId__c = '123456',
            AccountId = testAccount.Id 
        );
        insert newAsset;

        Case updatedCase = [SELECT Id, AssetId FROM Case WHERE AssetId = :newAsset.Id];
        System.assertEquals(newAsset.Id, updatedCase.AssetId, 'O Case deve ser atualizado com o novo AssetId');

        WorkOrder updatedWorkOrder = [SELECT Id, AssetId FROM WorkOrder WHERE AssetId = :newAsset.Id];
        System.assertEquals(newAsset.Id, updatedWorkOrder.AssetId, 'O WorkOrder deve ser atualizado com o novo AssetId');
    }

    @isTest
    static void testUpdateCaseAndWorkOrderWhenStatusChangedToB() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Asset oldAsset = new Asset(
            Name = 'Asset Teste',
            Status = 'A',
            LegacyId__c = '789101',
            AccountId = testAccount.Id 
        );
        insert oldAsset;

        Case caseRecord = new Case(
            Subject = 'Test Case Update',
            Status = 'Em Atendimento',
            AssetId = oldAsset.Id
        );
        insert caseRecord;

        WorkOrder workOrderRecord = new WorkOrder(
            Subject = 'Test WorkOrder Update',
            AssetId = oldAsset.Id,
            AccountId = testAccount.Id,
            Street = 'Rua teste',
            City = 'Cidade teste',
            State = 'SP',
            PostalCode = '13.860-000'
        );
        insert workOrderRecord;

        Asset newAsset = new Asset(
            Name = 'Asset Teste',
            Status = 'A',
            LegacyId__c = '789101',
            AccountId = testAccount.Id
        );
        insert newAsset;

        oldAsset.Status = 'B';
        update oldAsset;

        Case updatedCase = [SELECT Id, AssetId FROM Case WHERE Id = :caseRecord.Id];
        System.assertEquals(newAsset.Id, updatedCase.AssetId, 'O Case deve ser atualizado com o novo AssetId após a alteração do Status para "B"');

        WorkOrder updatedWorkOrder = [SELECT Id, AssetId FROM WorkOrder WHERE Id = :workOrderRecord.Id];
        System.assertEquals(newAsset.Id, updatedWorkOrder.AssetId, 'O WorkOrder deve ser atualizado com o novo AssetId após a alteração do Status para "B"');
    }

    @isTest
    static void testNoUpdateWhenStatusNotA() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Asset oldAsset = new Asset(
            Name = 'Asset Teste',
            Status = 'B',
            LegacyId__c = '123456',
            AccountId = testAccount.Id
        );
        insert oldAsset;

        Asset newAsset = new Asset(
            Name = 'Asset Teste',
            Status = 'B',
            LegacyId__c = '123456',
            AccountId = testAccount.Id
        );
        insert newAsset;

        Case relatedCase = [SELECT Id, AssetId FROM Case WHERE AssetId != :newAsset.Id LIMIT 1];
        System.assertNotEquals(newAsset.Id, relatedCase.AssetId, 'O Case não deve ser atualizado quando o Status do Asset não é "A"');

        WorkOrder relatedWorkOrder = [SELECT Id, AssetId FROM WorkOrder WHERE AssetId != :newAsset.Id LIMIT 1];
        System.assertNotEquals(newAsset.Id, relatedWorkOrder.AssetId, 'O WorkOrder não deve ser atualizado quando o Status do Asset não é "A"');
    }

    @isTest
    static void testNoUpdateWhenLegacyIdIsNull() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Asset newAsset = new Asset(
            Name = 'Asset Teste',
            Status = 'A',
            LegacyId__c = null,
            AccountId = testAccount.Id
        );
        insert newAsset;

        Asset existingAsset = [SELECT Id FROM Asset WHERE Status = 'A' LIMIT 1];
        existingAsset.Status = 'B';
        update existingAsset;

        Case relatedCase = [SELECT Id, AssetId FROM Case WHERE AssetId != :newAsset.Id LIMIT 1];
        System.assertNotEquals(newAsset.Id, relatedCase.AssetId, 'O Case não deve ser atualizado quando o LegacyId__c é nulo');

        WorkOrder relatedWorkOrder = [SELECT Id, AssetId FROM WorkOrder WHERE AssetId != :newAsset.Id LIMIT 1];
        System.assertNotEquals(newAsset.Id, relatedWorkOrder.AssetId, 'O WorkOrder não deve ser atualizado quando o LegacyId__c é nulo');
    }
}