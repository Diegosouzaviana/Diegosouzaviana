global with sharing class Every_VerifyUpdatePlan implements vlocity_cmt.VlocityOpenInterface2 {

    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

        if(methodName == 'verifyUpdatePlanFinish'){
            try{
            	verifyUpdatePlanFinish(inputMap,outMap,options);
            }catch (Exception e) {
                // Lidar com o timeout de conexão
                outMap.put('ErrorApex', e.getMessage());
                System.debug('Timeout de conexão: ' + e.getMessage());
                // Você pode tentar novamente ou tomar outras medidas apropriadas
            }
        }

        return true;
}


public static void verifyUpdatePlanFinish(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
  
    String statusUpdate = '';
    String idServiceAppointment = (String) inputMap.get('idServiceAppointment');
    Boolean continuarLoop = true;
    Integer delayIteracao = 1000;
    try{
       while (continuarLoop) {
        
        ServiceAppointment serviceAP = [SELECT message_update_speed__c FROM ServiceAppointment WHERE Id = :idServiceAppointment];

        if (serviceAP.message_update_speed__c != 'Processing ...' && serviceAP.message_update_speed__c != '' && serviceAP.message_update_speed__c != null) {
            continuarLoop = false;
            statusUpdate = serviceAP.message_update_speed__c;
            outMap.put('statusUpdate', statusUpdate);
        } else {
           Long startTime = System.currentTimeMillis();
           Long endTime = startTime + delayIteracao;
            try{
           while (System.currentTimeMillis() < endTime) {
               
           
           }}catch(Exception e){
                outMap.put('ErrorApex', e.getMessage());
                system.debug('trrrrrrrrrrrr'+ e.getMessage());
            }
        }
    }
    }catch(Exception e){
            outMap.put('ErrorApex', e.getMessage());
        system.debug('exempmlo errodddddddddd'+ e.getMessage());
        }
}


}