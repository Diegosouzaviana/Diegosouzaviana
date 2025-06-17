global with sharing class Every_ProductFilterCategoriaCompativel implements callable {
    
    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    private Object invokeMethod(String methodName, Map<String,Object> input,
    Map<String,Object> output, Map<String,Object> options) {
        
        System.debug('Método chamado: ' + methodName);
        System.debug('Input recebido: ' + JSON.serialize(input));
        
        try {
            List<Object> productList = (List<Object>) input.get('productList');
            String categoriaReferencia = (String) input.get('categoria');
            
            if (categoriaReferencia == null) {
                System.debug(LoggingLevel.ERROR, 'Erro: categoria de referência não fornecida no input.');
                output.put('result', 'erro: categoria não informada');
                output.put('quantidade', 0);
                return output;
            }
            
            if (productList == null) {
                System.debug(LoggingLevel.ERROR, 'Erro: productList não fornecido no input.');
                output.put('result', 'erro: productList não informado');
                output.put('quantidade', 0);
                return output;
            }
            
            Integer contadorCompatibilidade = 0;
            
            for (Object prodObj : productList) {
                Map<String, Object> product = (Map<String, Object>) prodObj;
                String categoriaProduto = String.valueOf(product.get('category'));
                System.debug('Comparando categoriaProduto=' + categoriaProduto + ' com categoriaReferencia=' + categoriaReferencia);
                if (categoriaProduto != null && categoriaProduto.trim().equals(categoriaReferencia.trim())) {
                    contadorCompatibilidade++;
                }
                
            }
            
            String resultado = (contadorCompatibilidade > 0) ? 'categoria compativel' : 'categoria nao compativel';
            System.debug('Resultado: ' + resultado + ' | Quantidade: ' + contadorCompatibilidade);
            
            output.put('result', resultado);
            output.put('quantidade', contadorCompatibilidade);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exceção capturada: ' + e.getMessage());
            output.put('result', 'erro inesperado: ' + e.getMessage());
            output.put('quantidade', 0);
        }
        
        return output;
    }
}