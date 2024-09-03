public with sharing class AssetSelector {
    
    public static Asset getAssetById(String id){
        return [SELECT Id, PlanLogin__c FROM Asset WHERE Id =: id];
    }
}