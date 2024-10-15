@IsTest
private class AddressParserTest {

    @IsTest
    static void testGetCityFromJson() {
        // Criação do mapa de entrada que simula os dados JSON
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        // Simulando uma estrutura de JSON
        Map<String, Object> addressComponent1 = new Map<String, Object>{
            'long_name' => 'São Paulo',
            'types' => new List<Object>{ 'administrative_area_level_2' }
        };
        
        Map<String, Object> addressComponent2 = new Map<String, Object>{
            'long_name' => 'Brazil',
            'types' => new List<Object>{ 'country' }
        };
        
        List<Object> addressComponents = new List<Object>{ addressComponent1, addressComponent2 };
        
        Map<String, Object> firstResult = new Map<String, Object>{
            'address_components' => addressComponents
        };
        
        List<Object> results = new List<Object>{ firstResult };
        
        Map<String, Object> jsonData = new Map<String, Object>{
            'results' => results
        };
        
        inputMap.put('jsonStringList', jsonData);
        
        // Instancia a classe AddressParser
        AddressParser parser = new AddressParser();
        
        // Executa o método de teste
        parser.getCityFromJson(inputMap, outputMap, options);
        
        // Valida se a cidade foi extraída corretamente
        System.assertEquals('São Paulo', outputMap.get('city'), 'A cidade extraída deve ser São Paulo');
    }
    
    @IsTest
    static void testGetCityFromJsonCityNotFound() {
        // Criação do mapa de entrada que simula os dados JSON sem a cidade
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        // Simulando uma estrutura de JSON sem "administrative_area_level_2"
        Map<String, Object> addressComponent = new Map<String, Object>{
            'long_name' => 'Brazil',
            'types' => new List<Object>{ 'country' }
        };
        
        List<Object> addressComponents = new List<Object>{ addressComponent };
        
        Map<String, Object> firstResult = new Map<String, Object>{
            'address_components' => addressComponents
        };
        
        List<Object> results = new List<Object>{ firstResult };
        
        Map<String, Object> jsonData = new Map<String, Object>{
            'results' => results
        };
        
        inputMap.put('jsonStringList', jsonData);
        
        // Instancia a classe AddressParser
        AddressParser parser = new AddressParser();
        
        // Executa o método de teste
        parser.getCityFromJson(inputMap, outputMap, options);
        
        // Valida que a cidade não foi encontrada (outputMap contém null)
        System.assertEquals(null, outputMap.get('city'), 'A cidade não deve ser encontrada');
    }

    @IsTest
    static void testInvokeMethodGetCityFromJson() {
        // Testa o método invokeMethod
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        // Simulando uma estrutura de JSON
        Map<String, Object> addressComponent = new Map<String, Object>{
            'long_name' => 'São Paulo',
            'types' => new List<Object>{ 'administrative_area_level_2' }
        };
        
        List<Object> addressComponents = new List<Object>{ addressComponent };
        
        Map<String, Object> firstResult = new Map<String, Object>{
            'address_components' => addressComponents
        };
        
        List<Object> results = new List<Object>{ firstResult };
        
        Map<String, Object> jsonData = new Map<String, Object>{
            'results' => results
        };
        
        inputMap.put('jsonStringList', jsonData);
        
        // Instancia a classe AddressParser
        AddressParser parser = new AddressParser();
        
        // Invoca o método via invokeMethod
        parser.invokeMethod('getCityFromJson', inputMap, outputMap, options);
        
        // Valida se a cidade foi extraída corretamente
        System.assertEquals('São Paulo', outputMap.get('city'), 'A cidade extraída deve ser São Paulo');
        System.assertEquals(true, outputMap.get('success'), 'A operação deve ter sido bem-sucedida');
        System.assertEquals('OK', outputMap.get('error'), 'Nenhum erro deve ter ocorrido');
    }

    @IsTest
    static void testInvokeMethodWithInvalidMethod() {
        // Testa o invokeMethod com um método inválido
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        // Instancia a classe AddressParser
        AddressParser parser = new AddressParser();
        
        // Invoca um método inválido
        parser.invokeMethod('invalidMethod', inputMap, outputMap, options);
        
        // Valida se a operação falhou
        System.assertEquals(true, outputMap.get('success'), 'A operação deve ter falhado');
        System.assertEquals('OK', outputMap.get('error'), 'Deve haver uma mensagem de erro');
    }
}
