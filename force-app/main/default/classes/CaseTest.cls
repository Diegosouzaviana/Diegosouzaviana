@isTest
public with sharing class CaseTest {

    @TestSetup
    static void setupTestData() {

        Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User usuario = new User(
            Alias = '20f93478',
            Email='usuario-teste@gmail.com', 
            EmailEncodingKey='UTF-8',
            LastName='20f934785yf2039476f502934f650h293487fh56',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = perfil.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='usuario-teste@gmail.com'
        );
        insert usuario;

        System.runAs([SELECT Id FROM User WHERE Id =: UserInfo.getUserId()][0]) {
            EmailTemplate emailTemplate = new EmailTemplate(
                isActive = true,
                Name = 'Email template teste',
                DeveloperName = 'EmailTemplateTeste',
                FolderId = usuario.Id,
                TemplateType = 'custom',
                Subject = 'Teste Subject',
                Body = 'Teste Body',
                HtmlValue = '<html style="overflow-y: hidden;"><head><title></title></head><body style="height: auto; min-height: auto;">Teste Body</body></html>'
            );
            insert emailTemplate;

            Account conta = new Account(
                Name = 'Conta Test'
            );
            insert conta;

            Case caso = new Case(
                Subject = 'Test Case',
                AccountId = conta.Id
            );
            insert caso;
        }
    }

    @isTest 
    static void testListEmailsTemplate() {
        Test.startTest();
            List<EmailTemplate> emails = CaseController.listEmailsTemplate();
            System.assertNotEquals(null, emails);
        Test.stopTest();
    }

    @isTest 
    static void testEmailTemplates() {
        EmailTemplate template = [SELECT Id FROM EmailTemplate LIMIT 1];
        Case caso = [SELECT Id, AccountId FROM Case  LIMIT 1];

        Test.startTest();
            Map<String, String> result = CaseController.emailTemplates(template.Id, caso.Id);
        Test.stopTest();

    }

    @isTest 
    static void testFormatarTemplate() {
        String templateTeste = 'Teste de template com tag {ACCOUNT.NAME}.';
        Case caso = [SELECT Id, AccountId FROM Case  LIMIT 1];

        Test.startTest();
            String formattedTemplate = CaseController.formatarTemplate(templateTeste, caso.Id);
        Test.stopTest();
    }

    @isTest 
    static void testSendEmail() {
        Test.startTest();
            List<String> customerEmails = new List<String>{'test@example.com'};
            String subject = 'Teste de Email';
            String body = 'Este é um teste de email';
            List<Map<String, String>> files = new List<Map<String, String>>{
                new Map<String, String>{'fileName' => 'teste.txt', 'fileBody' => 'dGVzdGU='}
            };
            
            String result = CaseController.sendEmail(customerEmails, subject, body, files);
        Test.stopTest();
    }
}