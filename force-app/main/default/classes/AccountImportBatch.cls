global with sharing class AccountImportBatch implements Database.Batchable<sObject>{
    
        global Database.QueryLocator start(Database.BatchableContext bc) {
            return Database.getQueryLocator([SELECT Id, LXD_CPF__c, ParentId, RecordType.Name, RecordTypeId FROM Account WHERE ParentId = null AND (RecordType.Name = 'Billing' OR RecordType.Name = 'Service')]);
        }
        global void execute(Database.BatchableContext bc, List<Account> lstAccount){
            AccountHandler.matchAccounts(lstAccount);
        }   
        global void finish(Database.BatchableContext bc){
            // execute any post-processing operations
        } 
}