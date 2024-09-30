/*
*   Classe de testes: BatchCancelamentoVoluntarioIndiretoTest
*/

global class BatchCancelamentoVoluntarioIndireto implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, Status__c, Codigo_ADM__c, Data_Calculada_Cancelamento__c ' +
                       'FROM CancelamentoVoluntario__c ' +
                       'WHERE Data_Calculada_Cancelamento__c = TODAY';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CancelamentoVoluntario__c> scope) {
       
        List<CancelamentoVoluntario__c> cvUpdt = new List<CancelamentoVoluntario__c>();

        // Irá chamar o IP com a API Desktop para cancelamento em massa
        // .....

        // Após status code de sucesso, processa os registros a atualizar status para 'Cancelado'
        if(true){
            for (CancelamentoVoluntario__c cancelamento : scope) {
                
                System.debug('Processando Cancelamento ID: ' + cancelamento.Id);
                
                cvUpdt.add(new CancelamentoVoluntario__c(Id = cancelamento.Id, Status__c = 'Cancelado'));

            }
        
            try{
                Database.update(cvUpdt);
            } catch(Exception e){
                System.debug('Erro ao realizar update -> ' + e.getMessage());
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        
        System.debug('Batch finalizado.');

    }
}