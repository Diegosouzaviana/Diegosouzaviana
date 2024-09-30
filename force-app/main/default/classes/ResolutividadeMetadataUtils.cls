public with sharing class ResolutividadeMetadataUtils {
    
    public static List<Case> updateCaseMotivoSubmotivoByMetadataValues(List<Case> cases){
        List<Case> newCases = new List<Case>();

        Map<String, MotivosResolutividade__mdt> mapMR = ResolutividadeMetadataSelector.getMotivosResolutividadeMap();

        for(Case c : cases){
            if(mapMR.containsKey(c.Tema__c + '_' + c.motive__c + '_' + c.Tipo__c + '_' + c.submotive__c)){
                MotivosResolutividade__mdt currentMetadata = mapMR.get(c.Tema__c + '_' + c.motive__c + '_' + c.Tipo__c + '_' + c.submotive__c);
                c.motive__c = currentMetadata.Motivo_Resolutividade__c;
                c.submotive__c = currentMetadata.Submotivo_Resolutividade__c;

                newCases.add(c);
            }
        }

        return newCases;
    }

}