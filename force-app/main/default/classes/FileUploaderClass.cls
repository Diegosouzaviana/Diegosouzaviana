public with sharing class FileUploaderClass {
    
    @AuraEnabled
    public static integer verifySteps(String idWorkOrder, String WorkPlanId, String recordId){
            System.debug('VerifyStep');
            System.debug('workOrderId -> ' + idWorkOrder);
            System.debug('WorkPlanId -> ' + WorkPlanId);
            List<WorkStep> listWStep = new List<WorkStep>();
            listWStep = [SELECT Id FROM WorkStep WHERE WorkOrderId =: idWorkOrder AND Status != 'Completed' AND WorkPlan.Name =: 'Auto Inspeção' AND id !=: recordId];
           
            System.debug('listWStep -> ' + listWStep);
            return listWStep.size();
    }

}