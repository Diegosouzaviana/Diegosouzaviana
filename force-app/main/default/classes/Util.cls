public class Util {
    public static TokenResponseWrapper TokenAuth;

    public static HttpResponse getTokenAuthRequest(String serviceName) {
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String ClientSecret, ClientId, GrandType, EndpointToken;
        Integer timeout=120000;
        String method = 'POST';
        try {
            List<IntegrationData__mdt> integMetadataList = IntegrationData__mdt.getAll().values();
            for (IntegrationData__mdt dataMdt : integMetadataList) {
                if (dataMdt.DeveloperName == serviceName) {
                    ClientSecret = dataMdt.ClientSecret__c;
                    ClientId     = dataMdt.ClientId__c;
                    GrandType    = dataMdt.GrandType__c;
                    EndpointToken= dataMdt.EndpointToken__c;
                }
            }

            String payload = 'client_id='+EncodingUtil.urlEncode(ClientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(ClientSecret,'UTF-8')+'&grant_type='+EncodingUtil.urlEncode(GrandType,'UTF-8');
            System.debug(payload);
    
            req.setEndpoint(EndpointToken);
            req.setMethod(method);
            //req.setTimeout(timeout);
            req.setBody(payload);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    
            res = http.send(req);
            System.debug('response-> '+ JSON.serialize(res.getBody()));
            TokenResponseWrapper token = TokenResponseWrapper.parse(res.getBody());
            TokenAuth = token;
            System.debug('access_token >>> '+TokenAuth.access_token);
            System.debug('status code '+res.getStatusCode());
            return res;
            
        } catch (Exception e) {
            System.debug('Erro ao obter token de acesso '+ e.getMessage() + ' - '+e.getStackTraceString());
            throw e;
        }
    }
    /**
     * Realiza uma requisição HTTP Request
     *
     * @param   serviceName  - nome do serviço a ser chamado
     * @param   method  - método HTTP
     * @param   headers  - cabeçalhos da chamada 
     * @param   body  - corpo da requisição
     * @param   timeout  - tempo de timeout

    * @return  HttpResponse - Objeto HTTP Response
    */
    public static HttpResponse executarHttpRequest(String serviceName, String method, String body, Integer timeout, String queryParameters, String correlationId){
        HttpResponse response;
        HttpRequest request;
        String Endpoint = null;
        List<IntegrationData__mdt> integMetadataList = IntegrationData__mdt.getAll().values();
        for (IntegrationData__mdt dataMdt : integMetadataList) {
            if (dataMdt.DeveloperName == serviceName) {
                Endpoint = dataMdt.Endpoint__c;
            }
        }
        HttpResponse res = getTokenAuthRequest(serviceName);

        if (res.getStatusCode() == 200) {
            try {
                if ( queryParameters != null )
                    Endpoint +=queryParameters;
                System.debug('Endpoint '+Endpoint);
                request = new HttpRequest();
                request.setEndpoint(Endpoint);
                request.setMethod(method);
                request.setTimeout(timeout);

                if(method == 'POST' || method == 'PUT')
                    request.setBody(body != null ? body : '');
                else if(body != null)
                    request.setBody(body);
                request.setHeader('Content-Type','application/json');

                request.setHeader('Authorization', 'Bearer ' + TokenAuth.access_token);
                system.debug('access_token: '+ TokenAuth.access_token);
                system.debug('Body: '+ body);
                //insertLogValidation(body, 'Desktop Service', 'Erro ao enviar dados', 'Erro', 'Outbound');
                response = new Http().send(request);
                //System.debug('response: '+serviceName + ' ' + JSON.serialize(response?.getBody()));
                System.debug('response -> '+ response);
                return response;

            } catch ( Exception e )   {
                System.debug('API Request Error: '+e.getMessage()+' - '+e.getStackTraceString());
                try {
                    IntegrationLog__c log    = new IntegrationLog__c();
                    log.ExecutionDate__c 	 = System.now();
                    log.LogDescription__c    = 'endPoint='+method + ' ' + Endpoint+' query='+queryParameters+'\nRequest:'+(request?.getBody().length() < 128000?  request?.getBody():request?.getBody().substring(1,12800));    
                    log.LogResult__c         = 'response:'+ e.getMessage()+ ' ' + e.getStackTraceString();
                    log.Integration__c 	     = serviceName.replace('_', ' ');
                    log.Flow__c		 	     = 'Outbound';
                    log.LogStatus__c         = 'Erro';
                    log.Name                 = 'Integração de Aprovisionamento';
                    log.CorrelationId__c     = correlationId;
                    insert log;
                } catch ( Exception ee ) {
                    System.debug('Erro criando log de integracao 1 '+ee.getMessage() + ' ' + ee.getStackTraceString());
                }
                throw e;     
                    
            } finally {
                System.debug('registrando no integrationLog ');
                try {
                    IntegrationLog__c log   = new IntegrationLog__c();
                    log.ExecutionDate__c 	= System.now();
                    log.LogDescription__c   = 'endPoint='+method + ' ' + endPoint+' query='+queryParameters+'\nRequest:'+(request?.getBody().length() < 128000?  request?.getBody():request?.getBody().substring(1,128000));
                    log.LogResult__c        = 'response:'+ (response?.getBody().length() < 128000 ? response.getBody():response.getBody().substring(response.getBody().length()-128000,response.getBody().length()));
                    log.Integration__c 	    = serviceName.replace('_', ' ');
                    log.Flow__c		 	    = 'Outbound';
                    log.LogStatus__c        = 'Erro';
                    log.Name                = 'Integração de Aprovisionamento';
                    log.CorrelationId__c    = correlationId;
                    if ( (response?.getStatusCode() == 200 || response?.getStatusCode() == 202)  ) {
                        log.LogStatus__c    =  'Sucesso';
                    }
                    insert log;
                    System.debug('status '+response?.getStatusCode());
                } catch ( Exception ee ) {
                    System.debug('Erro criando log de integracao 2'+ee.getMessage() + ' ' +ee.getStackTraceString());
                }
            }
        }else{
            String msg='Erro Token:Desktop Service não retornou 200. Retornou='+res.getStatusCode()+ res.getBody();
            System.debug(msg);
            throw new DesktopException ( msg );
        }
    }
    
    public static HttpResponse executarHttpRequest(String serviceName, String method, String body, Integer timeout, String queryParameters){
        return executarHttpRequest(serviceName, method, body, timeout, queryParameters, null);
    }


    public static void insertLogValidation(String msg, String integrationName, String logDesc, String logStatus, String flow) {
        try {
            String logResult = msg;


            IntegrationLog__c log        = new IntegrationLog__c();
            log.ExecutionDate__c    = System.now();
            log.LogDescription__c   = logDesc;
            log.Integration__c      = integrationName.replace('_', ' ');
            log.LogResult__c        = logResult;
            log.Flow__c             = flow;
            log.LogStatus__c        = logStatus;
            log.Name                = logDesc;
            insert log;
            
        } catch (Exception e) {
            System.debug('Erro ao inserir log de validação: '+e.getMessage() + ' - '+e.getStackTraceString());
        }
    }

    public static String generateRandomString() {
        Boolean finded = false;
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        do {
            finded = false;
            while (randStr.length() < 10) {
               Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
               randStr += chars.substring(idx, idx+1);
            }
            system.debug('value-> '+randStr);
    
            List<ServiceAppointment> saList = [SELECT id, CorrelationId__c FROM ServiceAppointment WHERE CorrelationId__c = :randStr];
            if (saList.size()>0) {
                finded=true;
            }
            
        } while (finded);
        return randStr;
    }

    class DesktopException extends Exception {}
}