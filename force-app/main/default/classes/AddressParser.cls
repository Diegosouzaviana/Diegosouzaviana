global without sharing class AddressParser implements Vlocity_cmt.VlocityOpenInterface2{
    
    global Object invokeMethod(String methodName,Map<String,Object> inputMap,Map<String,Object> outMap, Map<String,Object> options){
        Boolean success = true;
        String errors = 'OK';
        try {
            if (methodName == 'getCityFromJson') {
                getCityFromJson(inputMap, outMap, options);
            }
        } catch (Exception e) {
            errors = e.getMessage();
            success = false;
        }
        outMap.put('success', success);
        outMap.put('error', errors);
        return success;
    }
    
    public void getCityFromJson(Map<String,Object> inputMap, Map<String,Object> outputMap, Map<String,Object> options) {
        System.debug('Key Set: '+inputMap.keySet());
        System.debug('Values: '+inputMap.values());
        //String jsonStringList = (String) inputMap.get('jsonStringList');
        // Desserializa o JSON recebido em um mapa
        Map<String, Object> jsonData = (Map<String, Object>) inputMap.get('jsonStringList');
        
        // Acessa a lista de resultados
        List<Object> results = (List<Object>) jsonData.get('results');
        
        if (results != null && !results.isEmpty()) {
            // Acessa o primeiro resultado
            Map<String, Object> firstResult = (Map<String, Object>) results.get(0);
            
            // Acessa os componentes de endereço
            List<Object> addressComponents = (List<Object>) firstResult.get('address_components');
            
            if (addressComponents != null) {
                for (Object component : addressComponents) {
                    Map<String, Object> addressComponent = (Map<String, Object>) component;
                    List<Object> types = (List<Object>) addressComponent.get('types');
                    
                    // Verifica se o componente é do tipo 'administrative_area_level_2'
                    if (types != null && types.contains('administrative_area_level_2')) {
                        // Adiciona o nome longo da cidade ao outputMap
                        outputMap.put('city', (String) addressComponent.get('long_name'));
                        return;
                    }
                }
            }
        }
        
        // Retorna null se a cidade não for encontrada
        // Adiciona null ao outputMap se a cidade não for encontrada
        outputMap.put('city', null);
    }
}