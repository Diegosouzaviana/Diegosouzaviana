@IsTest
public with sharing class dsk_batchApexAccountBlockedTest {
	@TestSetup 
    static void MakeData(){
            Account newAcc = new Account(
                Name = 'Account-Prueba',
                LXD_Status__c = 'Ativo'
            );
        	Account newAcc2 = new Account(
                Name = 'Account-Prueba2',
                LXD_Status__c = 'Ativo'
            );
            insert newAcc;
        	insert newAcc2;
            Account acc1=[Select Id, LXD_Status__c FROM Account Where Name = 'Account-Prueba' Limit 1];
        	Account acc2=[Select Id, LXD_Status__c FROM Account Where Name = 'Account-Prueba2' Limit 1];
            Contract newCtr1 = new Contract(
                Name= 'Contract-Prueba1',
                Status = 'RASCUNHO',
                StartDate = Date.newInstance(2023, 02, 12) ,
                ContractTerm = 12,
                AccountId = acc1.Id
            );
            Contract newCtr2 = new Contract(
                Name= 'Contract-Prueba2',
                Status = 'RASCUNHO',
                StartDate = Date.newInstance(2023, 02, 12),
                ContractTerm = 12,
                AccountId = acc1.Id
            );
        	Contract newCtr3 = new Contract(
                Name= 'Contract-Prueba3',
                Status = 'RASCUNHO',
                StartDate = Date.newInstance(2023, 02, 12),
                ContractTerm = 12,
                AccountId = acc2.Id
            );
            insert newCtr1;
            insert newCtr2;
            insert newCtr3;

            Contract ctr1=[Select Id, Status,ContractNumber FROM Contract Where Name = 'Contract-Prueba1' Limit 1];  
            Contract ctr2=[Select Id, Status,ContractNumber FROM Contract Where Name = 'Contract-Prueba2' Limit 1];
        	Contract ctr3=[Select Id, Status,ContractNumber FROM Contract Where Name = 'Contract-Prueba3' Limit 1];
        	ctr1.Status = 'BLOQUEADO';
        	ctr2.Status = 'ATIVO';
        	ctr3.Status='ATIVO';
            acc1.LXD_ContractNumber__c = ctr1.Id;
            acc1.LXD_ContractNumber__c = ctr2.Id;
        	acc2.LXD_ContractNumber__c = ctr3.Id;
            ctr1.AccountId = acc1.Id;
            ctr2.AccountId = acc1.Id;
        	ctr3.AccountId = acc2.Id;
 			Update acc1;
        	Update ctr1;
            Update ctr2;
        	Update ctr3;
    }
    @IsTest 
    static void AccountToBlocked(){
        Account acc1=[Select Id, LXD_Status__c FROM Account Where Name = 'Account-Prueba' Limit 1];  
        acc1.LXD_Status__c = 'Ativo';
        String expectedErrorMessage = 'El status de la cuenta es: ';
        Contract ctr=[Select Id, Status,ContractNumber FROM Contract Where Name = 'Contract-Prueba2' Limit 1];
        ctr.Status = 'BLOQUEADO';
        update ctr;
        update acc1;
        
        Test.startTest();
        	dsk_batchApexAccountBlocked batch = new dsk_batchApexAccountBlocked();
        	Database.executeBatch(batch);
        Test.stopTest();
        

        Account acc=[Select Id, LXD_Status__c FROM Account Where Name = 'Account-Prueba' Limit 1];  
        System.assertEquals('Bloqueado',acc.LXD_Status__c, expectedErrorMessage + acc.LXD_Status__c);
    }
    @IsTest 
    static void AccountToActive(){
        
        String expectedErrorMessage = 'El status de la cuenta es: ';
        Account acc1=[Select Id, LXD_Status__c FROM Account Where Name = 'Account-Prueba' Limit 1];  

        acc1.LXD_Status__c = 'Bloqueado';
        update acc1;
        Test.startTest();
        dsk_batchApexAccountBlocked batch = new dsk_batchApexAccountBlocked();
        Database.executeBatch(batch);
        Test.stopTest();
        

        Account acc=[Select Id, LXD_Status__c FROM Account Where Name = 'Account-Prueba' Limit 1];  
        System.assertEquals('Ativo',acc.LXD_Status__c, expectedErrorMessage + acc.LXD_Status__c);


    }
}