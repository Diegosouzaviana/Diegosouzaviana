global with sharing class CepValidator implements vlocity_cmt.VlocityOpenInterface  {

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if (methodName.equals('validadorcep')) {
                if (inputMap.containsKey('CEP')) {
                    String cep = (String)inputMap.get('CEP');
                    Boolean isValid = CepValidator.isValidCep(cep);
                    outMap.put('isValidCep', isValid);
                }
            }
        } catch (Exception e) {
            result = false;
            // Adicione a mensagem de erro ao outMap para facilitar a depuração
            //outMap.put('errorMessage', e.getMessage());
        }

        return result;
    }
    public static Boolean isValidCep(String cep) {
        // Regex para validar o formato do CEP (xxxxx-xxx ou xxxxxxxx)
        String cepPattern = '^[0-9]{5}-?[0-9]{3}$';
        return Pattern.matches(cepPattern, cep);
    }
}