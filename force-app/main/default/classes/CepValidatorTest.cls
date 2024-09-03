@isTest
public class CepValidatorTest {
    @isTest
    public static void testValidCep() {
        // Criação do mapa de entrada com um CEP válido
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('CEP', '12345-678');

        // Criação do mapa de saída
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Instanciação da classe CepValidator
        CepValidator validator = new CepValidator();
        
        // Invocação do método
        Boolean result = validator.invokeMethod('validadorcep', inputMap, outMap, options);
        
        // Verificação dos resultados
        System.assert(result == true);
        System.assert(outMap.containsKey('isValidCep'));
        System.assert(outMap.get('isValidCep') == true);
    }

    @isTest
    public static void testInvalidCep() {
        // Criação do mapa de entrada com um CEP inválido
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('CEP', '1234-678');

        // Criação do mapa de saída
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Instanciação da classe CepValidator
        CepValidator validator = new CepValidator();
        
        // Invocação do método
        Boolean result = validator.invokeMethod('validadorcep', inputMap, outMap, options);
        
        // Verificação dos resultados
        System.assert(result == true);
        System.assert(outMap.containsKey('isValidCep'));
        System.assert(outMap.get('isValidCep') == false);
    }
}