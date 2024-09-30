public with sharing class ResolutividadeMetadataSelector {
    
    public static Map<String, MotivosResolutividade__mdt> getMotivosResolutividadeMap(){
        Map<String, MotivosResolutividade__mdt> mapMR = new Map<String, MotivosResolutividade__mdt>();

        for(MotivosResolutividade__mdt mr : getMotivosResolutividade()){
            mapMR.put(mr.Tema__c + '_' + mr.Motivo__c + '_' + mr.Tipo__c + '_' + mr.Submotivo__c, mr);
        }

        return mapMR;
    }

    public static List<MotivosResolutividade__mdt> getMotivosResolutividade(){
        return [SELECT  Id, 
                        Tema__c, 
                        Motivo__c, 
                        Tipo__c, 
                        Submotivo__c, 
                        Motivo_Resolutividade__c, 
                        Submotivo_Resolutividade__c 
                FROM    MotivosResolutividade__mdt];
    }
}