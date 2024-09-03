@isTest
private class ContactDCTriggerTest {

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

        // Criar um contato associado à conta Billing
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = billingAccount.Id,
            Id = null
        );
        insert testContact;

        // Execução do teste
        Test.startTest();

        // Simulando o contexto do usuário Dupla Convivencia
        System.runAs(testUser) {
            insert testContact;
        }

        Test.stopTest();

        // Verificar se o contato foi atualizado corretamente
        Contact updatedContact = [SELECT Id, AccountId FROM Contact WHERE Id = :testContact.Id];
        System.assertNotEquals(billingAccount.Id, updatedContact.AccountId, 'O ID da conta do contato não foi atualizado corretamente');
        System.assertEquals(parentAccount.Id, updatedContact.AccountId, 'O ID da conta do contato não foi atualizado corretamente para o ID do Pai da Conta');
    }
}