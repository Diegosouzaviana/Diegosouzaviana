public with sharing class DeleteRecordsDC {
  public static void DeleteRecords(List<ServiceAppointment> saScope) {
        List<String> caseNumberList = new List<String>();
        List<Id> assetIdList = new List<Id>();
        List<Id> contractIdList = new List<Id>();
        List<Id> billingIdList = new List<Id>();
        List<Id> serviceIdList = new List<Id>();
        List<Id> contactIdList = new List<Id>();
        List<Id> workOrderIdList = new List<Id>();
        List<Case> caseList = new List<Case>();

        for (ServiceAppointment sa : saScope) {
            caseNumberList.add(sa.CaseNumberSA__c);
            if(sa.ContactId != null){
                contactIdList.add(sa.ContactId);
            }
            if(sa.WorkOrder__c != null){
                workOrderIdList.add(sa.WorkOrder__c);
            }
        }

        caseList =
            [ SELECT Id, AssetId, Contrato__c,
              Asset.vlocity_cmt__BillingAccountId__c,
              Asset.vlocity_cmt__ServiceAccountId__c FROM Case WHERE CaseNumber
              IN:caseNumberList ];

        for (Case cs : caseList) {
            if(cs.AssetId != null){
                assetIdList.add(cs.AssetId);
            }
            if(cs.Contrato__c != null){
                contractIdList.add(cs.Contrato__c);
            }
            if(cs.Asset.vlocity_cmt__BillingAccountId__c != null){
                billingIdList.add(cs.Asset.vlocity_cmt__BillingAccountId__c);
            }
            if(cs.Asset.vlocity_cmt__ServiceAccountId__c != null){
                serviceIdList.add(cs.Asset.vlocity_cmt__ServiceAccountId__c);
            }
        }

        Database.delete(caseList, false);
        Database.delete(contactIdList, false);
        Database.delete(serviceIdList, false);
        Database.delete(billingIdList, false);
        Database.delete(contractIdList, false);
        Database.delete(assetIdList, false);
        Database.delete(saScope, false);
        Database.delete(workOrderIdList, false);
    }
}