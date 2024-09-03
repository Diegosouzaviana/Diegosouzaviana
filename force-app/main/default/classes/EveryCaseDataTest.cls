@isTest
private class EveryCaseDataTest {

    @isTest
    static void testGetCaseData() {
        List<Case> testCases = new List<Case>();
        
        Account testAccount = new Account(Name = 'Conta de Teste');
        insert testAccount;

        List<Schema.PicklistEntry> motivoPicklistValues = Case.motive__c.getDescribe().getPicklistValues();
        String validMotivoPicklistValue = null;
        if (!motivoPicklistValues.isEmpty()) {
            validMotivoPicklistValue = motivoPicklistValues[0].getValue();
        }

        List<Schema.PicklistEntry> submotivePicklistValues = Case.submotive__c.getDescribe().getPicklistValues();
        String validSubmotivePicklistValue = null;
        if (!submotivePicklistValues.isEmpty()) {
            validSubmotivePicklistValue = submotivePicklistValues[0].getValue();
        }

        List<Schema.PicklistEntry> areaAtendimentoPicklistValues = Case.Area_de_atendimento__c.getDescribe().getPicklistValues();
        String validAreaAtendimentoPicklistValue = null;
        if (!areaAtendimentoPicklistValues.isEmpty()) {
            validAreaAtendimentoPicklistValue = areaAtendimentoPicklistValues[0].getValue();
        }

        List<Schema.PicklistEntry> solutionPicklistValues = Case.solution__c.getDescribe().getPicklistValues();
        String validSolutionPicklistValue = null;
        if (!solutionPicklistValues.isEmpty()) {
            validSolutionPicklistValue = solutionPicklistValues[0].getValue();
        }

        Case testCase = new Case(
            Endereco_de_Atendimento__Street__s = 'Rua Teste, 123',
            Endereco_de_Atendimento__City__s = 'City',
            motive__c = validMotivoPicklistValue,
            submotive__c = validSubmotivePicklistValue,
            solution__c = validSolutionPicklistValue,
            Area_de_atendimento__c = validAreaAtendimentoPicklistValue,
            AccountId = testAccount.Id
        );
        insert testCase;
        testCases.add(testCase);

        List<String> caseIds = new List<String>{testCase.Id};
        List<Case> result = EveryCaseData.getCaseData(String.join(caseIds, ';'));

        System.assertEquals(1, result.size(), 'Deveria ter retornado um caso');
        System.assertEquals(testCase.Id, result[0].Id, 'O ID do caso retornado não corresponde');

        List<Case> emptyResult = EveryCaseData.getCaseData('');
        System.assertEquals(0, emptyResult.size(), 'Deveria retornar uma lista vazia');

        List<Case> noCaseResult = EveryCaseData.getCaseData('invalidCaseId');
        System.assertEquals(0, noCaseResult.size(), 'Deveria retornar uma lista vazia quando nenhum caso é encontrado');
    }

    @isTest
    static void testCreateCSVFile() {
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Conteúdo do arquivo CSV'));
        String fileName = 'TestFile.csv';

        Test.startTest();
        Id contentVersionId = EveryCaseData.createCSVFile(base64Data, fileName);
        Test.stopTest();

        System.assertNotEquals(null, contentVersionId, 'O ID do ContentVersion não deveria ser nulo');
    }
}