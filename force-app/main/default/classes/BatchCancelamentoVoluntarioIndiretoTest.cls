@isTest
public class BatchCancelamentoVoluntarioIndiretoTest {
    
    @testSetup
    static void setupData() {
        List<CancelamentoVoluntario__c> cancelamentos = new List<CancelamentoVoluntario__c>();
        for (Integer i = 0; i < 10; i++) {
            cancelamentos.add(new CancelamentoVoluntario__c(
                Status__c = 'Em cancelamento', 
                Codigo_ADM__c = Integer.valueOf('123' + i),
                Prazo_para_Cancelamento__c = 0,
                Data_hora_do_Cancelamento__c = System.now()
            ));
        }
        insert cancelamentos;
    }
    
    @isTest
    static void testBatchExecution() {
      
        Test.startTest();
        
        BatchCancelamentoVoluntarioIndireto batch = new BatchCancelamentoVoluntarioIndireto();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        List<CancelamentoVoluntario__c> updatedCancelamentos = [SELECT Id, Status__c 
                                                                FROM CancelamentoVoluntario__c 
                                                                WHERE Status__c = 'Cancelado'];
        System.assertEquals(10, updatedCancelamentos.size(), 'Todos os registros devem estar com status Cancelado.');
    }
    
    @isTest
    static void testEmptyBatch() {
        delete [SELECT Id FROM CancelamentoVoluntario__c];
        
        Test.startTest();
        BatchCancelamentoVoluntarioIndireto batch = new BatchCancelamentoVoluntarioIndireto();
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<CancelamentoVoluntario__c> updatedCancelamentos = [SELECT Id, Status__c 
                                                                FROM CancelamentoVoluntario__c 
                                                                WHERE Status__c = 'Cancelado'];
        System.assertEquals(0, updatedCancelamentos.size(), 'Nenhum registro deve ter sido atualizado.');
    }
}