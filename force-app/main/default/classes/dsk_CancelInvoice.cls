/*---------------------------------------------------------------------------------------------------------------
--- Company: LabsXD
--- Author: Team OM
--- Description: Clase para Api de Cancelacion de facturacion de servicio 
--- CreateDate:  14/11/2022
--- Update for: 
--- UpdateDate: 
--- Update Description: 
---------------------------------------------------------------------------------------------------------------*/
global virtual class dsk_CancelInvoice implements vlocity_cmt.XOMOrchestrationInterfaces.ISystemInterface {
	global virtual void startBatch(String url, String path){
        // Do nothing
    }
    
    global virtual void endBatch(String url, String path){
        // Do nothing
    }
    
    global virtual void executeItem (String url, String path, vlocity_cmt__OrchestrationItem__c item) {
        
    }
    
}