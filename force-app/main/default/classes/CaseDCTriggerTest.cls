@isTest
private class CaseDCTriggerTest {

    @isTest
    static void testTriggerLogic() {

        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User testUser = new User(
            FirstName = 'Dupla',
            LastName = 'Convivencia',
            Email = 'testuser@example.com',
            Username = 'testuserdesktopcasedctriggertest@desktop.com',
            Alias = 'testDUP',
            ProfileId = profile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;

        // Criar a conta Customer
        Account parentAccount = new Account(
            Name = 'Customer Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LXD_Customer').getRecordTypeId()
        );
        insert parentAccount;

        // Criar a conta Billing associada à conta Customer
        Account billingAccount = new Account(
            Name = 'Billing Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId(),
            ParentId = parentAccount.Id
        );
        insert billingAccount;

        // Criar a conta Service associada à conta Customer
        Account serviceAccount = new Account(
            Name = 'Service Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId(),
            ParentId = parentAccount.Id
        );
        insert serviceAccount;

        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = billingAccount.Id // Associar o caso à conta Billing para teste
        );
        


        Test.startTest();

        // Simulando o contexto do usuário Dupla Convivencia
        System.runAs(testUser) {
            insert testCase;
        }

        Test.stopTest();

        Case updatedCase = [SELECT Id, AccountId FROM Case WHERE Id = :testCase.Id];
        System.assertNotEquals(billingAccount.Id, updatedCase.AccountId, 'O ID da conta do caso não foi atualizado corretamente');
        System.assertEquals(parentAccount.Id, updatedCase.AccountId, 'O ID da conta do caso não foi atualizado corretamente para o ID do Pai da Conta');
    }
}