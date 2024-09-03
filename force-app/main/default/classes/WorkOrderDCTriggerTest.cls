@isTest
private class WorkOrderDCTriggerTest {

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

        // Criar um contrato associado à conta Billing
        Contract testContract = new Contract(
            AccountId = billingAccount.Id
        );
        insert testContract;

        // Criar uma ordem de trabalho associada à conta Billing
        WorkOrder testWorkOrder = new WorkOrder(
            AccountId = billingAccount.Id
        );
        

        // Execução do teste
        Test.startTest();

        // Simulando o contexto do usuário Dupla Convivencia
        System.runAs(testUser) {
            insert testWorkOrder;
        }

        Test.stopTest();

        // Verificar se a ordem de trabalho foi atualizada corretamente
        // WorkOrder updatedWorkOrder = [SELECT Id, AccountId FROM WorkOrder WHERE Id = :testWorkOrder.Id];
        // System.assertNotEquals(billingAccount.Id, updatedWorkOrder.AccountId, 'O ID da conta da ordem de trabalho não foi atualizado corretamente');
        // System.assertEquals(parentAccount.Id, updatedWorkOrder.AccountId, 'O ID da conta da ordem de trabalho não foi atualizado corretamente para o ID do Pai da Conta');
    }
}