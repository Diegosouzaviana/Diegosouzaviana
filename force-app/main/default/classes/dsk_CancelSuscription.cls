/*---------------------------------------------------------------------------------------------------------------
--- Company: LabsXD
--- Author: Team OM
--- Description: Clase para Api de Cancelacion de servicio
--- CreateDate:  14/11/2022
--- Update for: 
--- UpdateDate: 
--- Update Description: 
---------------------------------------------------------------------------------------------------------------*/
global virtual class dsk_CancelSuscription implements vlocity_cmt.XOMOrchestrationInterfaces.ISystemInterface {
	global virtual void startBatch(String url, String path){
        // Do nothing
    }
    
    global virtual void endBatch(String url, String path){
        // Do nothing
    }
    
    global virtual void executeItem (String url, String path, vlocity_cmt__OrchestrationItem__c item) {
        vlocity_cmt__OrchestrationItem__c orchesItem = [SELECT Id
                                                        FROM vlocity_cmt__OrchestrationItem__c
                                                        WHERE id = :item.Id];
        

        Map <String, Object> ipInput = new Map <String, Object> ();
        Map <String, Object> ipOutput = new Map <String, Object> ();
        Map <String, Object> ipOptions = new Map <String, Object> ();
                 
        if(!Test.isRunningTest()) {             
        	 //ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService('dsk_IntegrationProcedure', ipInput, ipOptions);
        }else{
            ipOutput.put('ErrorCode', -1);
            ipOutput.put('ErrorMessage', 'Error');
        }
    }
    
}