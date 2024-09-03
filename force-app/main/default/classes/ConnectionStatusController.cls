public with sharing class ConnectionStatusController {
    
    @AuraEnabled
    public static List<ConnectionHistory__c> getHistory(String workOrderId){
        try {
            List<ConnectionHistory__c> connectionList = [ Select 
                        Id, Name, WorkOrder__c, Start__c, End__c, Duration__c, 
                        IP__c, MAC__c, NAS__c, DownloadTraffic__c, UploadedTraffic__c, 
                        Status__c,DurationForm__c
                    From  
                        ConnectionHistory__c
                    Where
                        WorkOrder__c = :workOrderId And Start__c = THIS_MONTH 
            ];
            return connectionList;
        } catch (Exception e) {
            throw new AuraException('Ocorreu um erro ao buscar o histórico ' + e.getMessage() + ' ' +e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static ConnectionResponse getConnections(String workOrderId){
        ConnectionResponse response = new ConnectionResponse();
        try {
            HttpResponse res = integrate(workOrderId);
            String bodyContent = res.getBody();
            if (res == null) {
                throw new AuraException('Ocorreu um erro ao buscar as conexões');
            }
            response.raw = bodyContent;
            if (res.getStatusCode()==200) {
                response.connection = (ConnectionStatusResponseWrapper.SuccessResponse) JSON.deserialize(bodyContent, ConnectionStatusResponseWrapper.SuccessResponse.class);
                response.success = true;
            } else {
                if (!String.isNotBlank(bodyContent))
                    throw new AuraException('Ocorreu um erro ao buscar as conexões');
                try {
                    
                    response.error = (ConnectionStatusResponseWrapper.ErrorResponse) JSON.deserialize(bodyContent, ConnectionStatusResponseWrapper.ErrorResponse.class);
                } catch (Exception e) {
                    response.raw = 'Ocorreu um erro ao buscar as conexões ' + res.getBody();
                }
            }
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    @TestVisible
    private static HttpResponse integrate(Id workOrderId) {
        WorkOrder wo = [Select Asset.PlanLogin__c From WorkOrder Where Id = :workOrderId Limit 1];
        String pppoeUser = wo.Asset.PlanLogin__c;

        String serviceName='Desktop_Service';
        String msg = '';
        String queryParams = '/cx/v1/service/technical-tests/current-connection?ppoeUser='+pppoeUser;
        HttpResponse res;
        try {
            res = Util.executarHttpRequest(serviceName,  'GET',  null,  120000,queryParams);
            
            return res; 
            
        } catch ( Exception e ) {
            
            msg = 'ConnectionStatusController Integrate Error '+e.getMessage() + ' '+  e.getStackTraceString();
            try {
                IntegrationLog__c log   = new IntegrationLog__c();
                log.ExecutionDate__c    = System.now();
                log.LogDescription__c   = res?.getBody().length() < 128000 ? res?.getBody():res?.getBody().substring(1,128000);
                log.Integration__c      = serviceName.replace('_', ' ');
                log.LogResult__c        = msg.length() < 128000 ? msg:msg.substring(1,128000);
                log.Flow__c             = 'Outbound';
                log.LogStatus__c        = 'Erro';
                log.Name                = 'Erro ao receber/salvar dados de integração';
                insert log;
                return null;
            } catch (Exception e2) {
                String error = 'Erro ao inserir log de validação: '+e2.getMessage() + ' - '+e2.getStackTraceString();
                System.debug(error);
                return null;
            }  
        } 
    }

    @future(callout=true)
    public static void consultConnections(Id workOrderId) {
        try {
            System.debug('consultConnections..');
            HttpResponse res = integrate(workOrderId);
            if (res == null) {
                System.debug('Erro. Retornou null');
            } else {
                String bodyContent = res.getBody();
                if (res.getStatusCode()==200) {
                    ConnectionStatusResponseWrapper.SuccessResponse response = (ConnectionStatusResponseWrapper.SuccessResponse) JSON.deserialize(bodyContent, ConnectionStatusResponseWrapper.SuccessResponse.class);
                    delete [Select Id From ConnectionHistory__c Where WorkOrder__c = :workOrderId];
                    String endString = response.stopTime == null ? String.valueOf(Datetime.now()) : response.stopTime;
                    System.debug('response.startTime '+response.startTime);
                    System.debug('response.stopTime '+response.stopTime);
                    System.debug('response.received '+response.received);
                    System.debug('response.sent '+response.sent);
                    System.debug(response.ipAddress +' response.ipAddress');
                    List<ConnectionHistory__c> connectionList = new List<ConnectionHistory__c>();
                    ConnectionHistory__c connection = new ConnectionHistory__c();
                    connection.IP__C = response.ipAddress;
                    connection.MAC__c = response.macAddress;
                    connection.NAS__c = response.nasAddress;
                    connection.StartText__c = getDateTimeBR(response.startTime);
                    connection.EndText__c = response.stopTime == null ? getDateTimeBR(String.valueOf(Datetime.now())) : getDateTimeBR(response.stopTime);
                    connection.Start__c = getDateTime(response.startTime);
                    connection.End__c = response.stopTime == null ? Datetime.now() : getDateTime(response.stopTime);
                    connection.Duration__c = getDifferenceDateString(getDateTime(response.startTime), getDateTime(endString));
                    
                    connection.Status__c = String.isNotBlank(response.terminateCause) ? 'Desconectado' : 'Conectado';
                    connection.DownloadTraffic__c = convertTraffic(Long.valueOf(String.valueOf(response.received)));
                    connection.UploadedTraffic__c = convertTraffic(Long.valueOf(String.valueOf(response.sent)));
                    connection.WorkOrder__c = workOrderId;
                    if (connection.Start__c!=null && connection.Start__c.month() == System.today().month())
                        connectionList.add(connection);
    
                    if (response.logs!=null && response.logs.size()>0) {
                        for (ConnectionStatusResponseWrapper.LogsConnection conn : response.logs) {

                            ConnectionHistory__c connection2 = new ConnectionHistory__c();
                            connection2.Start__c = getDateTime(response.startTime);
                            if (connection2.Start__c == null || connection2.Start__c.month() != System.today().month())
                                continue;
                            connection2.IP__C = conn.ipAddress;
                            connection2.MAC__c = conn.macAddress;
                            connection2.NAS__c = conn.nasAddress;
                            System.debug('conn.startTime '+conn.startTime);
                            System.debug('conn.stopTime '+conn.stopTime);
                            System.debug('conn.startTime datetime '+getDateTime(conn.startTime));
                            System.debug('conn.stopTime datetime '+getDateTime(conn.stopTime));
                            System.debug('conn.received '+conn.received + ' converted '+ convertTraffic(Long.valueOf(String.valueOf(conn.received))));
                            System.debug('conn.sent '+conn.sent + ' converted ' + convertTraffic(Long.valueOf(String.valueOf(conn.received))));
                            connection2.Start__c = getDateTime(conn.startTime);
                            connection2.End__c = getDateTime(conn.stopTime);
                            connection2.StartText__c = getDateTimeBR(conn.startTime);
                            connection2.EndText__c = getDateTimeBR(conn.stopTime);
                            connection2.Duration__c = getDifferenceDateString(getDateTime(conn.startTime), getDateTime(conn.stopTime));
                            connection2.Status__c = String.isNotBlank(conn.terminateCause) ? 'Desconectado' : 'Conectado';
                            connection2.DownloadTraffic__c = convertTraffic(Long.valueOf(String.valueOf(conn.received)));
                            connection2.UploadedTraffic__c = convertTraffic(Long.valueOf(String.valueOf(conn.sent)));
                            connection2.WorkOrder__c = workOrderId;

                            connectionList.add(connection2);  
                        }
                    }

                    if (connectionList.size()>0)    
                        insert connectionList;
                } else {
                    if (!String.isNotBlank(bodyContent))
                        System.debug('Erro. Retornou vazio');
                    else 
                        System.debug('Ocorreu um erro: '+bodyContent);
                } 
            }
        } catch (Exception e) {
            System.debug('erro ao inserir conexões '+e.getMessage()+ ' '+e.getStackTraceString());
        }
                   
    }

    private static String convertTraffic(Long trafficValue) {
        try {
            Double convertedValue = trafficValue;
            Integer cont = 0;
            String s;
            if (trafficValue > 1024) {
                do {
                    System.debug('convertedValue1 '+convertedValue);
                    convertedValue = convertedValue / 1024;
                    System.debug('convertedValue2 '+convertedValue);
                    cont++;
                } while (convertedValue > 1024);
                System.debug('cont'+cont);
            }
            Decimal n = Decimal.valueOf(convertedValue);
            
            Switch on cont {
                when 1 {s = 'KB';}
                when 2 {s = 'MB';}
                when 3 {s = 'GB';}
                when 4 {s = 'TB';}
                when else {s = '';}
            }
            System.debug('a-|>'+n.setScale(2, RoundingMode.DOWN));
            s = n.setScale(2, RoundingMode.DOWN)+s;
            return s;
        } catch (Exception e) {
            System.debug('erro ao converter tráfico '+e.getMessage()+ ' '+e.getStackTraceString());
            return null;
        }
    }

    public static Long getWaitingSeconds(DateTime requestDateTime, Datetime dt2){
        Long waitingSeconds = 0;
        Long requestSeconds = requestDateTime.getTime();
        Long currentSeconds = dt2.getTime();
        waitingSeconds = (currentSeconds/1000)-(requestSeconds/1000);
        return waitingSeconds;
    }

    public static String getDifferenceDateString(Datetime dt1, Datetime dt2) {
        //DateTime dt = DateTime.newInstance(2023, 12, 04, 18, 30, 10);
        String durationString = '';
        Long waitingSecond = getWaitingSeconds(dt1, dt2);
        Long sec = Math.mod(waitingSecond, 60);
        Long min = Math.mod(waitingSecond, 3600) / 60;
        Long hour = Math.mod(waitingSecond, 86400) / 3600;
        Long days = Math.mod(waitingSecond, 2628000) / 86400;
        Long month = Math.mod(waitingSecond, 31536000) / 2628000;
        Long year = waitingSecond / 31536000;

        if (year > 0)
            durationString = String.valueOf(year)+'Ano ';

        if (month > 0)
            durationString += String.valueOf(month)+'Mês ';

        if (days > 0)
            durationString += String.valueOf(days) == '1' ? String.valueOf(days)+' Dia ': String.valueOf(days)+' Dias ';
        
        if (hour > 0)
            durationString += String.valueOf(hour) == '1' ? String.valueOf(hour)+ ' Hora ' : String.valueOf(hour)+' Horas ';
            
        if (min > 0 || (hour > 0 && sec > 0))
            durationString += String.valueOf(min) == '1' ? String.valueOf(min)+' Minuto ' : String.valueOf(min)+' Minutos ';

        if (sec > 0)
            durationString += String.valueOf(sec) == '1' ? String.valueOf(sec)+' Segundo ' : String.valueOf(sec)+' Segundos ';

        return durationString;
    }

    private static DateTime getDateTime(String dateTimeStr){
        try {
            System.debug('getDateTime function '+dateTimeStr);
            String dateStr = dateTimeStr.substring(0,10);
            String timeStr = dateTimeStr.substring(11,19);
            List<String> dateList = dateStr.split('-');
            List<String> timeList = timeStr.split(':');
            return DateTime.newInstanceGmt(Integer.valueOf(dateList[0]),
                                        Integer.valueOf(dateList[1]),
                                        Integer.valueOf(dateList[2]),
                                        Integer.valueOf(timeList[0]),
                                        Integer.valueOf(timeList[1]),
                                        Integer.valueOf(timeList[2])
            );
        } catch (Exception e) {
            System.debug('Erro on getDateTime '+ e.getMessage() + ' ' +e.getStackTraceString());
            return null;      
        }
    }


    private static String getDateTimeBR(String dt) {
        try {
            System.debug('getDateTime function BR'+dt);
        
            String dateStr = dt.substring(0,10);
            String timeStr = dt.substring(11,19);
            List<String> dateList = dateStr.split('-');
            List<String> timeList = timeStr.split(':');
            String newDt = Integer.valueOf(dateList[2])+'/'+
                            Integer.valueOf(dateList[1])+'/'+
                            Integer.valueOf(dateList[0])+' '+
                            Integer.valueOf(timeList[0])+':'+
                            Integer.valueOf(timeList[1])+':'+
                            Integer.valueOf(timeList[2]);
            System.debug('newDt '+newDt);
            return newDt;
        } catch (Exception e) {
            System.debug('Erro on getDateTime '+ e.getMessage() + ' ' +e.getStackTraceString());
            return null;   
        }
        
    }

//2023-12-03 12:44:41
    public class ConnectionResponse {
        @AuraEnabled public Boolean success {get;set;}
        @AuraEnabled public ConnectionStatusResponseWrapper.SuccessResponse connection {get;set;}
        @AuraEnabled public ConnectionStatusResponseWrapper.ErrorResponse error {get;set;}
        @AuraEnabled public String raw {get;set;}
    }
}