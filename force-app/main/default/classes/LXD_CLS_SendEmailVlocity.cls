global without sharing class LXD_CLS_SendEmailVlocity implements vlocity_cmt.VlocityOpenInterface{
	
     global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        
        if (methodName.equalsIgnoreCase('returnSendEmail')) returnSendEmail(inputs, output);
        else return false;

        return true;
    }
    
    global static void returnSendEmail(Map<String, Object> inputs, Map<String, Object> output){
          try {
        List<LXD_CLS_SendEmail.ClientInput> lEmailClientLst = new List<LXD_CLS_SendEmail.ClientInput>();
              
				 LXD_CLS_SendEmail.ClientInput  inp = new  LXD_CLS_SendEmail.ClientInput();
                 inp.lBoletoCode =  (String)inputs.get('lBoletoCode');
                 inp.lCpf =  (String)inputs.get('lCpf');
                 inp.lEmail =  (String)inputs.get('lEmail');
              
              lEmailClientLst.add(inp);
              String jsonResponse = String.valueOf( JSON.serialize(LXD_CLS_SendEmail.SendEmail(lEmailClientLst)));
               LXD_VlocityUtils.success(output, JSON.deserializeUntyped(jsonResponse));
        } catch (Exception e) {
            LXD_VlocityUtils.badRequest(output, e.getMessage());
            LXD_VlocityUtils.debugErrorMessage(e);
        }
        
    }
}