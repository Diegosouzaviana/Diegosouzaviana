@isTest
public class UtilServiceTest {
        @isTest
    static void testInvokeMethod() {
        // Crie uma instância de UtilService
        UtilService utilService = new UtilService();

        // Defina os parâmetros para o método invokeMethod
        String methodName = 'GenerateRandomString';
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Chame o método invokeMethod
        String result = utilService.invokeMethod(methodName, inputMap, outMap, options);

        // Verifique se o resultado não é nulo ou vazio
        System.assertNotEquals(null, result);
        System.assertNotEquals('', result);

        // Verifique se o método colocou o resultado no outMap com a chave "CorrelationId"
        System.assertEquals(result, outMap.get('CorrelationId'));
    }
 @isTest
    static void testGenerateRandomString() {
        // Chame o método generateRandomString da classe UtilService
        String randomString = UtilService.generateRandomString();

        // Verifique se o valor retornado não está vazio
        System.assertNotEquals(null, randomString);
        System.assertNotEquals('', randomString);

        // Verifique se o tamanho da string gerada é 10
        System.assertEquals(10, randomString.length());

        // Verifique se a string gerada contém apenas caracteres válidos
        for (Integer i = 0; i < randomString.length(); i++) {
            String character = randomString.substring(i, i + 1);
            System.assert(character.isAlphaNumeric(), 'String contém caracteres inválidos.');
        }

        // Verifique se não há ServiceAppointment com o mesmo CorrelationId__c na base de dados
        List<ServiceAppointment> saList = [SELECT id, CorrelationId__c FROM ServiceAppointment WHERE CorrelationId__c = :randomString];
        System.assertEquals(0, saList.size(), 'ServiceAppointment com o mesmo CorrelationId__c encontrado na base de dados.');
    }
    
}