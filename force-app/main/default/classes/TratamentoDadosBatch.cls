/**
 * Nome da Classe: TratamentoDadosBatch
 * Descrição: Esta classe representa a execução do Batch que faz o relacionamento dos objetos importados ou não via carga de dados massiva. (Account, Contact, Contract, Contract Line Itens, Asset).
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
global class TratamentoDadosBatch implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext bc){
		return Database.getQueryLocator([SELECT Id FROM Account LIMIT 1]);
	}

	global void execute(Database.BatchableContext bc, List<Account> lstFakeAccount){
        TratamentoDadosService.tratamentoContas(lstFakeAccount);
	}

	global void finish(Database.BatchableContext bc){
		// execute any post-processing operations
	}
}