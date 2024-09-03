public with sharing class AccountHandler {
    public static void matchAccounts(List<Account> lstAccount){
        List<Account> lstAccBilling = [SELECT Id, LXD_CPF__c, ParentId, RecordType.Name, RecordTypeId FROM Account WHERE ParentId = null AND (RecordType.Name = 'Billing' OR RecordType.Name = 'Service') LIMIT 200];
        Set<String> setCPFAccount = new Set<String>();
        for(Account acc : lstAccBilling){
            setCPFAccount.add(acc.LXD_CPF__c);
            System.debug('CPF: ' + acc.LXD_CPF__c);
        }
        
        List<Account> lstAccCostumer = [SELECT ID, LXD_CPF__c, RecordTypeId FROM Account WHERE RecordType.Name = 'Customer' AND LXD_CPF__c =: setCPFAccount];
        List<Account> lstToUpdate = new List<Account>();
        for(Account acc : lstAccBilling){
            for(Account acc2 : lstAccCostumer){
                if(acc.LXD_CPF__c == acc2.LXD_CPF__c){
                    acc.ParentId = acc2.Id;
                    lstToUpdate.add(acc);
                    System.debug('ID: ' + acc2.Id);
                }
            }
        }
        update lstToUpdate;
    }
}