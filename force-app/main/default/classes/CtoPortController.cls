public with sharing class CtoPortController {
    static final String CTO_PORT = '/field/v1/infrastructure/salesforce/cto_client_onu';


    public static Boolean isSeachInProgress(ServiceAppointment sa){
        List<IntegrationLog__c> log = [
            SELECT Id, CreatedDate
            FROM IntegrationLog__c
            WHERE correlationId__c = :sa.correlationId__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        // ServiceAppointmentHistory saHistory = [
        //     SELECT Id, Field, OldValue, NewValue
        //     FROM ServiceAppointmentHistory
        //     WHERE ServiceAppointmentId = :sa.Id
        //     ORDER BY CreatedDate DESC
        // ];


        if(log.isEmpty()){
            return false;
        }

        // Validar Usuario
        if(log[0].CreatedDate >= sa.LastModifiedDate && log[0].CreatedDate >= System.now().addMinutes(-3)){
            return true;
        }

        return false;
    }

    @AuraEnabled
    public static DataWrapper catchInformations(String saId){
        System.debug('saId: ' + saId);

        DataWrapper data = new DataWrapper();

        try{
            ServiceAppointment sa = [
                SELECT Id,
                    Status,
                    WorkOrder__r.Case.Asset.SiglaCto__c,
                    CorrelationId__c,
                    LastModifiedDate
                FROM ServiceAppointment
                WHERE id = :saId
                LIMIT 1
            ];
            System.debug('sa: ' + sa);

            AssignedResource ar = [
                SELECT Id,
                    ServiceResource.LastKnownLocation,
                    ServiceResource.LastKnownLatitude,
                    ServiceResource.LastKnownLongitude
                FROM AssignedResource
                WHERE ServiceAppointmentId = :saId
                LIMIT 1
            ];
            System.debug('ar: ' + ar);

            if(ar.ServiceResource.LastKnownLatitude == null || ar.ServiceResource.LastKnownLongitude == null){
                data.success = false;
                data.message = 'Não foi possível realizar a busca de CTO e porta.';
            }
            else{
                data.success = true;
                data.callback = sa;
                data.lat = String.valueOf(ar.ServiceResource.LastKnownLatitude);
                data.lon = String.valueOf(ar.ServiceResource.LastKnownLongitude);
                data.siglaCto = sa.WorkOrder__r.Case.Asset.SiglaCto__c;
                data.searchInProgress = isSeachInProgress(sa);
            }

            System.debug('data: ' + data);

            return data;
        }
        catch(Exception e) {
            data.success = false;
            data.message = 'Não foi possível realizar a busca de CTO e porta. Falta de acesso';

            System.debug('data: ' + data);
            System.debug('CtoPortController Message: ' + e.getMessage());
            System.debug('CtoPortController StackTrace: ' + e.getStackTraceString());

            return data;
        }
    }

    @AuraEnabled
    public static DataWrapper sendRequest(Decimal lat, Decimal lon, String ativoOnu, String sigProjeto, String correlationId){
        DataWrapper dat = new DataWrapper();
        try{
            //Request sem validação de primeiro envio
            HttpResponse res = new HttpResponse();
            String serviceName = 'Desktop_Service';
            //String body=null;
            String method = 'GET';
            Integer timeout = 120000;

            String queryParameters = '';
            if(sigProjeto == null || sigProjeto == ''){
                queryParameters = CTO_PORT +'/' + String.valueOf(lat) + '/' +String.valueOf(lon) +'/' +ativoOnu.toUpperCase() + '?correlation_id='+ correlationId;
            }else{
                queryParameters = CTO_PORT +'/' + String.valueOf(lat) + '/' +String.valueOf(lon) +'/' +ativoOnu.toUpperCase()+ '?sigla_projeto='+sigProjeto +'&correlation_id='+ correlationId;
            }
            
            res = Util.executarHttpRequest(serviceName,  method,  null,  timeout, queryParameters, correlationId);
                  
            System.debug('Res ->' + res);
            System.debug('ResBody ->' + res.getBody());
            String msg = '';
            if(res.getStatusCode() == 504){
                msg= 'Serviço indisponível, entre em contato com o suporte ao campo.';
            }else if ( res.getStatusCode() != 200  && res.getStatusCode() != 202 && res.getStatusCode()!=504) {
                msg= 'Serviço indisponível, entre em contato com o suporte ao campo.';
            }
            if(msg != ''){
                dat.success = false;
                dat.message = msg;
            }else{
                dat.success = true;
                dat.message = res.getBody();
            }
            //return dat;
            //Fim Request sem validação de primeiro envio
        
            return dat;

        } catch (Exception e) {
            dat.success = false;
            dat.message = 'Não foi possível realizar a busca de CTO e porta.';
            return dat;
            //throw new AuraHandledException('Não foi possível realizar a busca de CTO e porta.');
        }
    }
    
    @AuraEnabled
    public static DataWrapper catchCallback(String saId){
        DataWrapper dt = new DataWrapper();
        try {
            System.debug('SAID => '+ saId);
            ServiceAppointment sa = new ServiceAppointment();
            sa = [SELECT id,Cto__c,Projeto__c,PortasLivres__c,Sucesso__c,Mensagem__c FROM ServiceAppointment WHERE id =: saId LIMIT 1];
            if(sa.Cto__c != '' && sa.Sucesso__c == true && sa.PortasLivres__c!= ''){
                dt.success = true;
                dt.callback = sa;

            }else if(sa.Sucesso__c == false && sa.Mensagem__c != null){
                dt.success = false;
                dt.message = sa.Mensagem__c;
            }
            return dt;
            
        } catch (Exception e) {
            dt.success = false;
            dt.message = 'Não foi possível realizar a busca de CTO e porta.';
            return dt;
            //throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateCorrelation(String saId){
        try{
            ServiceAppointment sa = new ServiceAppointment();
            sa.Id = saId;
            sa.CorrelationId__c = Util.generateRandomString();

            update sa;

            return sa.CorrelationId__c;
        }
        catch(Exception e){
            throw new AuraHandledException('Não foi possível gerar um identificador externo.');
        }
    }

    public class DataWrapper {
        @AuraEnabled
        public Boolean success {get;set;}

        @AuraEnabled
        public String message {get;set;}

        @AuraEnabled
        public ServiceAppointment callback {get;set;}

        @AuraEnabled
        public String lat {get;set;}

        @AuraEnabled
        public String lon {get;set;}

        @AuraEnabled
        public String siglaCto {get;set;}

        @AuraEnabled
        public Boolean searchInProgress {get;set;}
    }
}