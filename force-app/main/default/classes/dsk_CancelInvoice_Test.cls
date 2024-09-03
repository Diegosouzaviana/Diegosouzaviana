/*---------------------------------------------------------------------------------------------------------------
--- Company: LabsXD
--- Author: Victor Pacheco
--- Description: Clases test para  dsk_CancelInvoice
--- CreateDate:  16/11/2022
--- Update for: -
--- UpdateDate: -
--- Update Description: -
---------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class dsk_CancelInvoice_Test {
	@TestSetup
    static void makeData(){
        dsk_CreateDataTest.generateMakeData();
    }
    
    @isTest
    static void executeItemSuccess(){
        List<vlocity_cmt__OrchestrationItem__c> itemsLst = [SELECT id, vlocity_cmt__AutoTaskParameters__c  
                                                            FROM vlocity_cmt__OrchestrationItem__c];

        dsk_CancelInvoice sto_classTest = new dsk_CancelInvoice();

        Test.startTest(); 
        sto_classTest.executeItem('','',itemsLst[0]);
        Test.stopTest();
    }
    
    @isTest
    static void startBatchSuccess(){
        dsk_CancelInvoice sto_classTest = new dsk_CancelInvoice();

        Test.startTest(); 
        sto_classTest.startBatch('','');
        Test.stopTest();
    }
    
    @isTest
    static void endBatchSuccess(){
        dsk_CancelInvoice sto_classTest = new dsk_CancelInvoice();

        Test.startTest(); 
        sto_classTest.endBatch('','');
        Test.stopTest();
    }
}