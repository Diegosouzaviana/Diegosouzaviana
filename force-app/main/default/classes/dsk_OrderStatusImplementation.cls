/*---------------------------------------------------------------------------------------------------------------
--- Company: LabsXD
--- Author: Team OM
--- Description: Clase para manejo de los estatus de la orden
--- CreateDate:  14/11/2022
--- Update for: 
--- UpdateDate: 
--- Update Description: 
---------------------------------------------------------------------------------------------------------------*/
global with sharing class dsk_OrderStatusImplementation implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
    global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items){
        
        vlocity_cmt__OrchestrationItem__c orchestItem = [SELECT Id, vlocity_cmt__AutoTaskParameters__c, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c WHERE Id =: items[0].Id];
        
        Map<string, Object> input = (Map<string, Object>)JSON.deserializeUntyped(orchestItem.vlocity_cmt__AutoTaskParameters__c);
        string status = (string)input.get('status');
        
        string orderId= orchestItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c;
        
        SetStatusOrder(orderId, status);        
    }
    
    public static void SetStatusOrder(string orderId, string status){
        Order ord = [SELECT Id, Status FROM Order WHERE Id =: orderId];
        
        if(status.toLowerCase() == 'aberto'){
            ord.Status = 'Open';
        }
        else if(status.toLowerCase() == 'concluído'){
            ord.Status = 'Activated';
        }        
        
        Update ord;
        
    }
    
    
}