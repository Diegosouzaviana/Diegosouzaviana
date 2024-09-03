global with sharing class Every_ApiTrafficController implements Vlocity_cmt.VlocityOpenInterface2 {
    global Object invokeMethod(String methodName,Map<String,Object> inputMap,Map<String,Object> outMap, Map<String,Object> options) {

        String assetId;
        String url;
        String response = '';

      System.debug('methodName: '+ methodName);
        for (String key : inputMap.keySet()) {
            if(key == 'AssetId'){
                assetId = String.valueOf(inputMap.get(key));
            } else if(key == 'Url'){
                url = String.valueOf(inputMap.get(key));
            }

        }

          if(methodName == 'callTrafficControllerApi'){
              response = callTrafficControllerApi(url, assetId);
              outMap.put('Response', Json.deserializeUntyped(response));
          }

        return response;
      }

      global static String callTrafficControllerApi(String url, String assetId){

        Asset a = new Asset();
        String responseBody = '';

        try{
            a = AssetSelector.getAssetById(assetId);
        } catch(Exception e) {
            Map<String, Object> responseMap = new Map<String, Object>{
                'error' => 'Não encontramos unidades com o Id informado: "' + assetId + '. Erro: ' + e.getMessage(),
                'statusCode' => '400'
            };
            responseBody = JSON.serialize(responseMap);
        }
        
        Every_IntegrationProcedureInvocable.IntegrationProcedureInput input = new Every_IntegrationProcedureInvocable.IntegrationProcedureInput();
        input.procedureAPIName = 'Get_Token_Api';
        input.input = '';
        
        List<Every_IntegrationProcedureInvocable.IntegrationProcedureOutput> output = new List<Every_IntegrationProcedureInvocable.IntegrationProcedureOutput>();
            
          if(!Test.isRunningTest()){
              	output = Every_IntegrationProcedureInvocable.runIntegrationServiceInvocable(new List<Every_IntegrationProcedureInvocable.IntegrationProcedureInput> {
                        input
                        });
          } else {
              Every_IntegrationProcedureInvocable.IntegrationProcedureOutput ot = new Every_IntegrationProcedureInvocable.IntegrationProcedureOutput();
              ot.output = JSON.serialize(new Map<String, String>{
                                              'Token' => 'Bearer asd46a5sd4as5d4as8d4as64d4a8sda8s4d'
                                      });
              output.add(ot);
          }
            

        Object obj = JSON.deserializeUntyped(output[0].output);

        // Cast the Object to a Map<String, String>
        Map<String, Object> resultMap = (Map<String, Object>)obj;
        String token = String.valueOf(resultMap.get('Token'));
        
        System.debug('Token -> ' + token);
        System.debug('Url -> ' + url);

        url = url.replace('<planlogin>', a.PlanLogin__c);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setHeader('Authorization', token);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        
        try {

            if(!Test.isRunningTest()){
                response = http.send(request);
            	responseBody = response.getBody();
            } else {
                response.setStatusCode(200);
                responseBody = '{"Response":{"brasLast":{"input":0.0,"output":0.0,"ping":"0.0","Tentativa":"#3"},"bras":[{"input":0.0,"output":0.0,"ping":"","Tentativa":"#1"},{"input":0.0,"output":0.0,"ping":"","Tentativa":"#2"},{"input":0.0,"output":0.0,"ping":"","Tentativa":"#3"}],"statusCode":200},"errorCode":"INVOKE-200","error":"OK"}';
            }
            
            System.debug(responseBody);
            List<Object> brasList = new List<Object>();
            Map<String, Object> resultMap2 = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

            if (resultMap2.containsKey('bras')) {
                brasList = (List<Object>) resultMap2.get('bras');
            }
            Integer counter = 1;
            for (Object bra : brasList) {
                Map<String, Object> braMap = (Map<String, Object>) bra;
                braMap.put('Tentativa', '#' + counter);
                counter++;
            }

            Map<String, Object> responseMap = new Map<String, Object>{
                'brasLast' => brasList[brasList.size() - 1],
                'bras' => brasList,
                'statusCode' => response.getStatusCode()
            };

            responseBody = JSON.serialize(responseMap);
            

        } catch (Exception e) {
            Map<String, Object> responseMap = new Map<String, Object>{
                'error' => responseBody,
                'statusCode' => response.getStatusCode()
            };
            responseBody = JSON.serialize(responseMap);

        }

        return responseBody;
      }
}