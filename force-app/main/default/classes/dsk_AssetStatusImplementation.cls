/*---------------------------------------------------------------------------------------------------------------
--- Company: LabsXD
--- Author: Team OM
--- Description: Clase para manejo de los estatus de los asset
--- CreateDate:  14/11/2022
--- Update for: Team OM
--- UpdateDate: 24/01/2023
--- Update Description: Agregamos Asset Status Inactive 
---------------------------------------------------------------------------------------------------------------*/
global with sharing class dsk_AssetStatusImplementation implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
    global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items){
        vlocity_cmt__OrchestrationItem__c orchestItem = [SELECT Id, vlocity_cmt__AutoTaskParameters__c, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c 
                                                         FROM vlocity_cmt__OrchestrationItem__c WHERE Id =: items[0].Id];
        
        Map<string, Object> input = (Map<string, Object>)JSON.deserializeUntyped(orchestItem.vlocity_cmt__AutoTaskParameters__c);
        string status = (string)input.get('status');
        string orderId= orchestItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c;
        
        SetStatusAsset(orderId, status);        
    }
    
    public static void SetStatusAsset(string orderId, string status){
        List<OrderItem> orderItemLst = [SELECT vlocity_cmt__AssetId__c, vlocity_cmt__Action__c, vlocity_cmt__SubAction__c  FROM OrderItem WHERE OrderId =: orderId];
        Order ord =[SELECT id, Type FROM Order WHERE Id =: orderId LIMIT 1];
        List<Id> idAsset = new List<Id>();
        for(OrderItem oi: orderItemLst){
            idAsset.add(oi.vlocity_cmt__AssetId__c);
        }
        List<Asset> assetLst = [SELECT Id, Status FROM Asset WHERE Id IN : idAsset];
                    
        for(Asset asset:assetLst){
            if(status.toLowerCase() == 'cancelado'){
                asset.Status = 'Cancelled';
            } else if(status.toLowerCase() == 'activo'){
                asset.Status = 'Active';
            }else if(status.toLowerCase() == 'suspendido'){
                asset.Status = 'Suspended';                
            }else if(status.toLowerCase() == 'inactivo'){
                /*if(ord.Type=='PlanChange'){
                    for(OrderItem ordIt:orderItemLst){
                        Asset ass=[SELECT Id FROM Asset WHERE Id = : ordIt.vlocity_cmt__AssetId__c];
                        if(ordIt.vlocity_cmt__Action__c=='Change' && ordIt.vlocity_cmt__SubAction__c=='Replace'){
                            ass.Status='Inactive';
                        }else{
                            ass.Status='Active';
                        }
                    } 
                }*/
                asset.Status='Inactive';
            }
        }
        
        Update assetLst;        
    }
}