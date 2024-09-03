public with sharing class Every_SaveFieldSinalGPON {

    @future(callout=true)
    public static void integracaoIPTrigger(String wOrderId){
        String procedureName = 'LXD_Tabs_IP_GPON';
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
 
        List<WorkOrder> listWO = [SELECT Id, CaseId FROM WorkOrder WHERE Id =: wOrderId LIMIT 1];
        List<Case> listCase = [SELECT Id, AssetId, Nivel_Sinal__c FROM Case WHERE Id =: listWO[0].CaseId LIMIT 1];
System.debug(listWO);
        System.debug(listCase);
        Object AssetId = listCase[0].AssetId;

        ipInput.put('AssetId', AssetId);        
        ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);

        metodoCondicoes(listCase, ipOutput);

    }

    public static void metodoCondicoes(List<Case> listCase,  Map<String, Object> ipOutput){
        if ((ipOutput.containsKey('statusCode') && ipOutput.containsKey('response'))) {
            Integer statusCode = (Integer) ipOutput.get('statusCode');
            String response = (String) ipOutput.get('response');
            if(statusCode == 422){
                listCase[0].Nivel_Sinal__c = '0.0';
                update listCase;
            }
            
        }

        else if (ipOutput.containsKey('apiStatus') && ipOutput.containsKey('fullJson')){
            Integer success = (Integer) ((Map<String, Object>) ipOutput.get('apiStatus')).get('success');
            Map<String, Object> oltsMap = (Map<String, Object>)((Map<String, Object>)((Map<String, Object>)ipOutput.get('fullJson')).get('status')).get('olts');
            String nivelSinal = (String)oltsMap.get('onu_onu_rx');

            Map<String, Object> statusMap = (Map<String, Object>)((Map<String, Object>)((Map<String, Object>)ipOutput.get('fullJson')).get('status'));
            String statusConnectionVazio = (String)statusMap.get('status');

            if(success == 200){

                if(statusConnectionVazio == 'not_found'){
                    listCase[0].Nivel_Sinal__c = '0.0';
                    update listCase;
                } else {
                    listCase[0].Nivel_Sinal__c = nivelSinal;
                    update listCase;
                }
            } 
        }

        else if (ipOutput.containsKey('result')){
            String message = (String) ((Map<String, Object>) ipOutput.get('result')).get('message');
            listCase[0].Nivel_Sinal__c = '0.0';
            update listCase;
        }

        else{
            listCase[0].Nivel_Sinal__c = '0.0';
        }
    }
}