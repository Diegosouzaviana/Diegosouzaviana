public class VoluntaryCancellationBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name FROM CancelamentoVoluntario__c ' +
            'WHERE Data_hora_do_Cancelamento__c = TODAY AND ' +
            '(Status__c != \'Cancelado\' AND Status__c != \'Retido\')'
        );
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<CancelamentoVoluntario__c> cancelamentos = (List<CancelamentoVoluntario__c>) scope;

        for (CancelamentoVoluntario__c cancelamento : cancelamentos) {
            System.debug('Processando: ' + cancelamento.Name);
        }

        if (!cancelamentos.isEmpty()) {
            update cancelamentos;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Processo de Batch concluído.');
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new VoluntaryCancellationBatch(), 200);
    }

    public static void scheduleBatch() {
        String cronExpression = '0 50 23 * * ?'; 
        VoluntaryCancellationBatch batchJob = new VoluntaryCancellationBatch();
        System.schedule('Daily Voluntary Cancellation Batch', cronExpression, batchJob);
    }
}