public with sharing class ConnectionStatusResponseWrapper {
    
    public class SuccessResponse {
        @AuraEnabled public String ipAddress {get;set;}
        @AuraEnabled public String macAddress {get;set;}
        @AuraEnabled public String nasAddress {get;set;}
        @AuraEnabled public String startTime {get;set;}
        @AuraEnabled public String stopTime {get;set;}
        @AuraEnabled public String terminateCause {get;set;}
        @AuraEnabled public Long received {get;set;}
        @AuraEnabled public Long sent {get;set;}
        @AuraEnabled public List<LogsConnection> logs {get;set;}
    }
    
  
        
    public class LogsConnection {
        @AuraEnabled public String ipAddress {get;set;}
        @AuraEnabled public String macAddress {get;set;}
        @AuraEnabled public String nasAddress {get;set;}
        @AuraEnabled public String startTime {get;set;}
        @AuraEnabled public String stopTime {get;set;}
        @AuraEnabled public String terminateCause {get;set;}
        @AuraEnabled public Long received {get;set;}
        @AuraEnabled public Long sent {get;set;}
    }

    public class ErrorResponse {
        @AuraEnabled public String message {get;set;}
    }
}