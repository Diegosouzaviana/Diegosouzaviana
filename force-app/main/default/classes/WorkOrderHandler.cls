public class WorkOrderHandler {
    public static Double HowManyTimes = null;

    @InvocableMethod
    public static void WorkOrderHandler(List<List<String>> wOrder) {
        try {
            System.debug('calling WorkOrderHandler class');
            String statusOld, statusNew;
            Set<String> ContentDocumentTitleSet = new Set<String>();
            Set<String> WorkStepName = new Set<String>();
            List<WorkStep> WorkStepFindedList = new List<WorkStep>();
            Boolean HasAttachment = false;
            List<String> stepNameList = new List<String>();
            String errorMessage = '';
            String WorkOrderNumber;
            ID WorkOrderId;
            List<Id> IdWorkStepList = new List<Id>();
            Map<String, Id> IdNameWorkStepMap = new Map<String, Id>();
            for (List<String> w : wOrder) {
                WorkOrderId = w[0];
            }

            List<WorkStep> workStepList = [SELECT Name, WorkOrder.WorkOrderNumber, Status, WorkPlan.Name, Id FROM WorkStep WHERE WorkOrderId = :WorkOrderId And WorkPlan.Name = 'Auto Inspeção'];
            if (workStepList.size() > 0) {
                
                for (ContentDocumentLink cdl : [SELECT Id, ContentDocument.Description, ContentDocument.Title,  ContentDocumentId, LinkedentityId FROM ContentDocumentLink WHERE Linkedentityid = :WorkOrderId]) {
                    ContentDocumentTitleSet.add(cdl.ContentDocument.Title);
                    System.debug('Title Attachment '+ ContentDocument.Title);
                }

                for (WorkStep ws : workStepList) {
                    System.debug('adding Name');
                    WorkStepName.add(ws.Name);
                    System.debug('adding Id');
                    IdNameWorkStepMap.put(ws.Name, ws.Id);
                }

                for (String st : WorkStepName) {
                    System.debug('entrou for 1');
                    if (!ContentDocumentTitleSet.contains(st)) {
                        errorMessage += 'Foto não encontrado: '+st+'. \n';
                        IdWorkStepList.add(IdNameWorkStepMap.get(st));
                        System.debug('Foto NÃO encontrada na etapa '+st);
                    } else {    
                        System.debug('Foto encontrada na etapa '+st);
                    }
                }

                if (IdWorkStepList.size() > 0) {
                    System.debug('entrou if IdWorkStepList.size() > 0');
                    List<WorkStep> newWorkStepList = new List<WorkStep>();
                    for(workStep ws : [SELECT Name, WorkOrder.WorkOrderNumber, Status, WorkPlan.Name, id FROM WorkStep WHERE Id = :IdWorkStepList]) {
                        ws.status = 'New';
                        newWorkStepList.add(ws);
                    }

                    update newWorkStepList;
                } else {
                    System.debug('entrou else IdWorkStepList.size() > 0');
                }

                WorkOrder wo =[SELECT Id, ValidationPhotos__c FROM WorkOrder WHERE Id = :WorkOrderId];
                wo.ValidationPhotos__c = errorMessage;
                update wo;
            } else {
                System.debug('Ordem de trabalho '+WorkOrderNumber+' não possui plano de trabalho \'Auto Inspeção\'.');
            }
        } catch (Exception e) {
            System.debug('Erro ao verificar anexo: '+e.getMessage() + ' - '+e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void SchedulingWorkOrder(List<WorkOrder> OldWorkOrderList, List<WorkOrder> NewWorkOrderList) {
        try {
            Boolean SchedulingManagementOld, SchedulingManagementNew;
            Id WOId;
            for (WorkOrder wo : OldWorkOrderList) {
                SchedulingManagementOld = wo.SchedulingManagement__c;
            }
            for (WorkOrder worder : NewWorkOrderList) {
                SchedulingManagementNew = worder.SchedulingManagement__c;
                WOId = worder.Id;
            }
            System.debug('-> WorkOrderTrigger '+SchedulingManagementOld+ ' '+SchedulingManagementNew + ' - '+WOId);
            System.debug('HowManyTimes: '+HowManyTimes);
            if (SchedulingManagementOld == false && SchedulingManagementNew == true) {

                Datetime dt = Datetime.now().addMinutes(1);
                String dtString = dt.format('s m H d M \'?\' yyyy');
                String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().minute() + 1); 
                String ss = String.valueOf(Datetime.now().second());

                //parse to cron expression
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                System.debug('setting schedule Work Order Schedule - Scheduling Management ' + String.valueOf(Datetime.now()));
                System.schedule('Work Order Schedule - Scheduling Management ' + String.valueOf(Datetime.now()), dtString, new ScheduledWorkOrder(WOId, HowManyTimes));
            }
        } catch (Exception e) {
            System.debug('Erro ao criar evento: '+e.getMessage()+ ' '+e.getStackTraceString());
        }
    }

    public static void setHowManyTimes(List<WorkOrder> OldWorkOrderList) {
        Double times;
        for (WorkOrder wo : OldWorkOrderList) {
            times = wo.HowManyTimesWo__c;
        }
        HowManyTimes = times;
    }

    public static void checkConnections(Map<Id,WorkOrder> oldMap, List<WorkOrder> newList) {
        try {
            for (WorkOrder wo : newList) {
                if (wo.Status=='Em execução' && oldMap.get(wo.Id).Status != 'Em execução') {
                    ConnectionStatusController.consultConnections(wo.Id);
                }
            }        
        } catch (Exception e) {
            System.debug('Error checkConnections '+ e.getMessage() + ' ' + e.getStackTraceString());
        }
            
    }
    
    public static void checkUpdate(Map<Id,WorkOrder> oldMap, List<WorkOrder> newList) {
        try {
            Map<String, WorkOrder> mapWo = new Map<String, WorkOrder>();
            for (WorkOrder wo : newList) {
                if (wo.ValidationCompletedSteps__c== true && oldMap.get(wo.Id).ValidationCompletedSteps__c == false) {
                    mapWo.put(String.valueOf(wo.Id), wo);
                }
            }    
            if(mapWo.size()>0){
                WorkOrderController.checkSteps(mapWo);
            }    
        } catch (Exception e) {
            System.debug('Error checkConnections '+ e.getMessage() + ' ' + e.getStackTraceString());
        }
            
    }
}