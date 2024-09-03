public with sharing class WorkStepTriggerHandler {
    
    public static void relatedStep(Map<Id,WorkStep> nMap) {

        //Map<WorkPlanId, Map<OrdemDeExecução, WorkStep>>
        Map<String, Map<Integer, WorkStep>> mapStep = new Map<String, Map<Integer, WorkStep>>();

        //WorkPlanIDs
        List<String> wpIds = new List<String>();

        List<WorkStep> updateWs = new List<WorkStep>();

        for(WorkStep ws : nMap.values()){
            if(!wpIds.contains(String.valueof(ws.WorkPlanId))){
                wpIds.add(String.valueof(ws.WorkPlanId));
            }
        }

        List<WorkStep> listStep = new List<WorkStep>();
        listStep = [SELECT id, PreviousStep__c, WorkPlan.Name, ExecutionOrder, ParentRecordId, WorkPlanId FROM WorkStep WHERE WorkPlanID IN :wpIds];

        for(WorkStep ws : listStep){
            if(ws.WorkPlan.Name != 'Auto Inspeção'){
                Map<Integer, WorkStep> mapStp = new Map<Integer, WorkStep>();
                if (mapStep.containsKey(String.valueOf(ws.WorkPlanId))){
                    mapStp = mapStep.get(String.valueOf(ws.WorkPlanId));
                }
                mapStp.put(ws.ExecutionOrder, ws);
                mapStep.put(String.valueOf(ws.WorkPlanId), mapStp);
            }
        }

        for(String planID : mapStep.KeySet()){
            for(WorkStep ws : mapStep.get(planId).values()){
                Integer i = 0;
                if(ws.ExecutionOrder!= null){
                    i = ws.ExecutionOrder - 1;
                }
                if(mapStep.get(planId).containsKey(i)){
                    ws.PreviousStep__c = mapStep.get(planId).get(i).Id;
                    updateWs.add(ws);
                }
            }
        }

        if(updateWs.size()>0){
            //Pro teste forçar a quebra
            //Database.update(updateWs, true);

            //Pra Prod para não impedir o processo
            Database.update(updateWs, false);
        }
    }

    public static void filterStep(Map<Id, WorkStep> newMap, Map<Id, WorkStep> oldMap){
        List<WorkStep> listSteps = new List<WorkStep>();
        for(WorkStep ws : newMap.values()){
            if(oldMap.containsKey(ws.Id) && ws.status != oldMap.get(ws.Id).status){
                listSteps.add(ws);
            }
        }
        if(listSteps.size()>0){
            validateStep(listSteps);
        }

    }
    public static void validateStep(List<WorkStep> listSteps){
        List<String> relatedStepsIds = new List<String>();
        List<WorkStep> relatedSteps = new List<WorkStep>();
        List<WorkStep> listErrors = new List<WorkStep>();
        Map<Id, WorkStep> mapRelatedSteps = new Map<Id, WorkStep>();
        for(WorkStep ws : listSteps){
            if(ws.PreviousStep__c != null){
                relatedStepsIds.add(String.valueOf(ws.PreviousStep__c));
            }
        }
        if(relatedStepsIds.size()>0){
            relatedSteps = [SELECT id, status, WorkPlan.Name, ExecutionOrder, name FROM WorkStep WHERE id IN: relatedStepsIds];
        }
        if(relatedSteps.size()>0){
            for(WorkStep ws : relatedSteps){
                mapRelatedSteps.put(ws.Id, ws);
            }
        }
        for(WorkStep ws : listSteps){
            if(ws.PreviousStep__c == null || mapRelatedSteps.get(ws.PreviousStep__c).WorkPlan.Name == 'Auto Inspeção' || mapRelatedSteps.get(ws.PreviousStep__c).Status == 'Concluído' || mapRelatedSteps.get(ws.PreviousStep__c).Status == 'Não aplicável' || mapRelatedSteps.get(ws.PreviousStep__c).Status == 'Completed' || mapRelatedSteps.get(ws.PreviousStep__c).Status == 'Not Applicable'){
                System.debug('Etapa pode ser concluída com sucesso.');
            }else{
                listErrors.add(ws);
            }
        }
        if(listErrors.size()>0){
            for(WorkStep ws : listErrors){
                ws.addError('Não é possível finalizar a etapa ' + ws.ExecutionOrder + ' - ' + ws.Name + ' sem antes finalizar a etapa ' + mapRelatedSteps.get(ws.PreviousStep__c).ExecutionOrder + ' - ' + mapRelatedSteps.get(ws.PreviousStep__c).Name + '.');
            }
        }
    }
}