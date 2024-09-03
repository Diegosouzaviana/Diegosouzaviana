/*---------------------------------------------------------------------------------------------------------------
--- Company: LabsXD
--- Author: Team OM
--- Description: Clase Test Alteración de servicio
--- CreateDate:  15/12/2022
--- Update for: 
--- UpdateDate: 
--- Update Description: 
---------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class dsk_ChangeSuscription_Test {
   /* @TestSetup
    static void makeData(){
        dsk_CreateDataTest.generateMakeData();
    }*/
    
    @isTest
    static void executeItemSuccess(){
        
        vlocity_cmt__OrchestrationItem__c OrchItem =new vlocity_cmt__OrchestrationItem__c();
        OrchItem.Name = 'Test';
        
        List<vlocity_cmt__OrchestrationItem__c> itemsLst = new List<vlocity_cmt__OrchestrationItem__c>();
		itemsLst.add(OrchItem);
        dsk_ChangeSuscription sto_classTest = new dsk_ChangeSuscription();
		System.debug(sto_classTest);
        Test.startTest(); 
        sto_classTest.executeItem('','',itemsLst[0]);
        Test.stopTest();
    }
    
    @isTest
    static void startBatchSuccess(){
        dsk_ChangeSuscription sto_classTest = new dsk_ChangeSuscription();

        Test.startTest(); 
        sto_classTest.startBatch('','');
        Test.stopTest();
    }
    
    @isTest
    static void endBatchSuccess(){
        dsk_ChangeSuscription sto_classTest = new dsk_ChangeSuscription();

        Test.startTest(); 
        sto_classTest.endBatch('','');
        Test.stopTest();
    }
}