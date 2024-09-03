public with sharing class WorkOrderController {
    public static void checkSteps(Map<String, WorkOrder> mapWo) {

        List<WorkStep> listWS = new List<WorkStep>();
        listWS = [SELECT id, WorkOrderId FROM WorkStep WHERE WorkOrderId IN: mapWo.keySet() AND Status = 'New'];

        List<WorkOrder> listErrors = new List<WorkOrder>();

        for(WorkStep ws : listWS){
            WorkOrder wo = new WorkOrder();
            wo.id = ws.WorkOrderId;
            if(!listErrors.contains(wo)){
                listErrors.add(wo);
            }
        }
        for(WorkOrder wo : listErrors){
            mapWo.get(String.valueOf(wo.Id)).addError('Favor finalizar as etapas corretamente na ordem solicitada.');
        }

    }
}