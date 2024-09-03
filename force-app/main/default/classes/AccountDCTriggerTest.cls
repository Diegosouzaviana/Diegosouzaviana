@isTest
private class AccountDCTriggerTest {

    // @isTest
    // static void testTriggerLogic() {
        
    //     Id recordTypeCustomer = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    //     Id recordTypeService = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId();
    //     Id recordTypeBilling = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
    //     Account acc = new Account (Name = 'Teste', LXD_CPF__c = '412.024.458-02', RecordTypeId = recordTypeCustomer, LegacyId__c = '1');
        
    //     Account acc2 = new Account (Name = 'Teste2', LXD_Email__c = 'teste2@teste.com', LXD_CPF__c = '412.024.458-08', RecordTypeId = recordTypeService, LegacyId__c = '1', IdPlanoUsuario__c = '1', ParentId = acc.Id);

    //     Account acc3 = new Account (Name = 'Teste2', LXD_Email__c = 'teste2@teste.com', LXD_CPF__c = '412.024.458-05', RecordTypeId = recordTypeBilling, ParentId = acc.Id);

    //     Contact cont = new Contact(FirstName = 'Teste', LastName = 'Teste',  LegacyId__c = '1', AccountId = acc2.Id);

    //     Case caso = new Case(AccountId = acc2.Id);
       
        
        
    //     Test.startTest();
    //     System.runAs(new User(Id = UserInfo.getUserId(), Username = 'Dupla Convivencia')) {
    //         insert new List<Account>{ acc };
    //         insert new List<Account>{ acc2, acc3 };
    //         insert new List<Contact> { cont };
    //         System.debug('acc2: ' + acc2.ParentId);
    //         Account conta = [SELECT Id, ParentId FROM Account WHERE RecordType.Name = 'Service' LIMIT 1];
    //         Account contaCustomer = [SELECT Id FROM Account WHERE RecordType.Name = 'Customer' LIMIT 1];
    //         conta.ParentId = contaCustomer.Id;
    //         update conta;
    //         System.debug('Conta: ' + conta.ParentId);
    //         Contract contrato = new Contract(vlocity_cmt__ContractReferenceNumber__c = '1',Status = 'PROSPECT', AccountId = conta.Id, IdPlanoUsuario__c = '01');
    //         System.debug('contrato: ' + contrato.Account.ParentId);
    //         insert new List<Contract> { contrato };
    //         insert new List<Case> { caso };
    //         WorkOrder wo = new WorkOrder(AccountId = conta.Id, Street = 'Rua Gregório Allegri 250', City = 'São Paulo', State = 'SP', PostalCode = '05842-070',  Country = 'Brazil');
    //         insert new List<WorkOrder> { wo };
    //     }
    //     Test.stopTest();
    // }

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

        List<String> cpfs = new List<String>{'454.337.700-10', '470.782.940-68', '748.181.530-52','973.544.010-56','576.947.560-98'};

        // Criar contas Customer
        List<Account> customerAccs = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            customerAccs.add( new Account(
                Name = 'Customer Account ' + i,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LXD_Customer').getRecordTypeId(),
                LXD_CPF__c = cpfs[i]
            ));
        }
        insert customerAccs;

        List<Account> childAccs = new List<Account>();
    Integer i = 0;
        // Criar as contas Billing e Service associadas à conta Customer
        for(Account a : customerAccs) {
            childAccs.add( new Account(
                Name = 'Billing Account',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId(),
                ParentId = a.Id
            ));
        
        
            childAccs.add(new Account(
                Name = 'Service Account ',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId(),
                ParentId = a.Id
               
            ));
            
            i++;
        }


        Test.startTest();

        // Simulando o contexto do usuário Dupla Convivencia
        System.runAs(testUser) {
            insert childAccs;
        }

        Test.stopTest();

        // Verificar se os registros foram atualizados corretamente
        List<Account> updatedAccounts = [SELECT Id, LXD_CPF__c FROM Account WHERE Id IN :childAccs];
        for(Account acc : updatedAccounts) {
            System.assertEquals(null, acc.LXD_CPF__c, 'O CPF não foi removido corretamente para Service/Billing Records');
        }
    }
}