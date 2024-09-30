@isTest
private class ResolutividadeMetadataSelectorTest {
    @testSetup static void setup() {  
        Case mr = new Case(  
            Area_de_atendimento__c ='SAC', 
            motive__c ='Ativo NPS', 
            solution__c ='Sem Retorno', 
            submotive__c ='Faturamento', 
            Tema__c ='Ativo', 
            Tipo__c ='Informação'
        );  
        insert mr;  
     }  
    
     @isTest static void testGetMotivosResolutividadeMap() {  
        Map<String, MotivosResolutividade__mdt> mapMR = ResolutividadeMetadataSelector.getMotivosResolutividadeMap();  
        System.assert(mapMR.size() == 1);  
        System.assertEquals(mapMR.get('Tema Teste_Motivo Teste_Tipo Teste_Submotivo Teste').Id, [SELECT Id FROM MotivosResolutividade__mdt WHERE Tema__c = 'Tema Teste'].get(0).Id);  
     }  
    
     @isTest static void testGetMotivosResolutividade() {  
        List<MotivosResolutividade__mdt> motivos = ResolutividadeMetadataSelector.getMotivosResolutividade();  
        System.assert(motivos.size() == 1);  
        System.assertEquals(motivos[0].Id, [SELECT Id FROM MotivosResolutividade__mdt WHERE Tema__c = 'Tema Teste'].get(0).Id);  
     } 
}