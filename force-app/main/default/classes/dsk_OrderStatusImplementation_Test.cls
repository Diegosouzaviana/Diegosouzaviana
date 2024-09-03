/*---------------------------------------------------------------------------------------------------------------
--- Company: LabsXD
--- Author: Victor Pacheco
--- Description: Clases test para  dsk_OrderStatusImplementation
--- CreateDate:  17/11/2022
--- Update for: -
--- UpdateDate: -
--- Update Description: -
---------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class dsk_OrderStatusImplementation_Test {
	@TestSetup
    static void makeData(){
        dsk_CreateDataTest.generateMakeData();
    }
    
    @isTest
    static void setOrderStatusOpen(){
    	List<vlocity_cmt__OrchestrationItem__c> itemLst = [SELECT id, vlocity_cmt__AutoTaskParameters__c, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c 
                                                           FROM vlocity_cmt__OrchestrationItem__c]; 

        for (vlocity_cmt__OrchestrationItem__c item : itemLst) {
            item.vlocity_cmt__AutoTaskParameters__c = '	{"status":"aberto"}';
            update item;           
        }

        List<vlocity_cmt__OrchestrationItem__c> itemsLst = [SELECT id, vlocity_cmt__AutoTaskParameters__c  
                                                            FROM vlocity_cmt__OrchestrationItem__c];
		system.debug('itemsLst->' + itemsLst);
        
        dsk_OrderStatusImplementation sto_classTest = new dsk_OrderStatusImplementation();

        Test.startTest(); 
        sto_classTest.executeBatch(itemsLst);
        Test.stopTest();

        vlocity_cmt__OrchestrationPlan__c orchestrationPlan = [SELECT Id, vlocity_cmt__OrderId__c 
                                                                FROM vlocity_cmt__OrchestrationPlan__c LIMIT 1];

        Order orderResult = [SELECT id, Status 
                            FROM Order
                            WHERE Id =: orchestrationPlan.vlocity_cmt__OrderId__c];


        System.assertEquals('Open', orderResult.Status);
    }

    @isTest
    static void setOrderStatusCompleted(){
    	List<vlocity_cmt__OrchestrationItem__c> itemLst = [SELECT id, vlocity_cmt__AutoTaskParameters__c, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c 
                                                           FROM vlocity_cmt__OrchestrationItem__c]; 

        for (vlocity_cmt__OrchestrationItem__c item : itemLst) {
            item.vlocity_cmt__AutoTaskParameters__c = '	{"status":"concluído"}';
            update item;           
        }

        List<vlocity_cmt__OrchestrationItem__c> itemsLst = [SELECT id, vlocity_cmt__AutoTaskParameters__c  
                                                            FROM vlocity_cmt__OrchestrationItem__c];

        dsk_OrderStatusImplementation sto_classTest = new dsk_OrderStatusImplementation();

        Test.startTest(); 
        sto_classTest.executeBatch(itemsLst);
        Test.stopTest();

        vlocity_cmt__OrchestrationPlan__c orchestrationPlan = [SELECT Id, vlocity_cmt__OrderId__c 
                                                                FROM vlocity_cmt__OrchestrationPlan__c LIMIT 1];

        Order orderResult = [SELECT id, Status 
                            FROM Order
                            WHERE Id =: orchestrationPlan.vlocity_cmt__OrderId__c];


        System.assertEquals('Activated', orderResult.Status);
    }
    
}