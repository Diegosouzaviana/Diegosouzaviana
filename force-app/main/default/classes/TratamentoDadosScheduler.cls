/**
 * Nome da Classe: TratamentoDadosScheduler
 * Descrição: Esta classe representa a execução de forma agendada do Batch que faz o relacionamento dos objetos importados ou não via carga de dados massiva. (Account, Contact, Contract, Contract Line Itens, Asset).
 * Autor: Victor Teodoro
 * Data de Criação: 06-Set-23
 * Última Modificação: 06-Set-23
 * Motivo da Modificação: [Explicação sucinta do motivo da modificação, se aplicável]
 * Version: v1.0
 * Notas: [Outras informações relevantes ou notas especiais sobre a classe]
 *
 * Direitos Autorais (c) 2023 - Victor Teodoro
 * Permissão concedida para uso interno da Desktop apenas.
 */

global with sharing class TratamentoDadosScheduler implements Schedulable{
    private static String nome = 'Realiza link de relacionamento de Objetos importados via carga de dados.';
    //private String CRON_EXP = '0 0/5 * * * ?';
 
    global static void agendar(){
        System.schedule('TratamentoDadosScheduler 1',  '0 00 * * * ?', new TratamentoDadosScheduler());
        System.schedule('TratamentoDadosScheduler 2',  '0 05 * * * ?', new TratamentoDadosScheduler());
        System.schedule('TratamentoDadosScheduler 3',  '0 10 * * * ?', new TratamentoDadosScheduler());
        System.schedule('TratamentoDadosScheduler 4',  '0 15 * * * ?', new TratamentoDadosScheduler());
        System.schedule('TratamentoDadosScheduler 5',  '0 20 * * * ?', new TratamentoDadosScheduler());
        System.schedule('TratamentoDadosScheduler 6',  '0 25 * * * ?', new TratamentoDadosScheduler());
        System.schedule('TratamentoDadosScheduler 7',  '0 30 * * * ?', new TratamentoDadosScheduler());
        System.schedule('TratamentoDadosScheduler 8',  '0 35 * * * ?', new TratamentoDadosScheduler());
        System.schedule('TratamentoDadosScheduler 9',  '0 40 * * * ?', new TratamentoDadosScheduler());
        System.schedule('TratamentoDadosScheduler 10', '0 45 * * * ?', new TratamentoDadosScheduler());
        System.schedule('TratamentoDadosScheduler 11', '0 50 * * * ?', new TratamentoDadosScheduler());
        System.schedule('TratamentoDadosScheduler 12', '0 55 * * * ?', new TratamentoDadosScheduler());
    }

    global void execute(SchedulableContext context) {
        Database.executeBatch(new TratamentoDadosBatch());
    }
}