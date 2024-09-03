/*
*   @author: Misael Ribas
*   @since: 2023/01/18
*   @className: LXD_CLS_GetLinkToBot
*   @description: <fill the description>
*
*   =================== FIX LOG ========================
*   2023/01/18            Misael Ribas      Class restructuring
*   ====================================================
*/
public class LXD_CLS_GetLinkToBot {
	public class ClientInput{
		@InvocableVariable(required=true)
		public String lAccountId;
        @InvocableVariable(required=true)
        public String lbillCode;
	}
	public class ClientOutput{
		@InvocableVariable(required=true)
        public String lLink;
        @InvocableVariable(required=true)
        public Integer lStatusCode;
    }
    private static final LXD_CLS_CreateAttachmentLink UTILS = new LXD_CLS_CreateAttachmentLink();
  
	@InvocableMethod(label='Buscar link do boleto')
    public static list<ClientOutput> getLink(List<ClientInput> lClientInputLst){
		ClientInput lClientInput = lClientInputLst[0];
        ClientOutput lClientOutput = new ClientOutput();
        list<ClientOutput> lClientOutputLst = new list<ClientOutput>();
        
		Map<String, Object> inputs = new Map<String, Object>{
            'billCode' => lClientInput.lbillCode,
            'accountId' => lClientInput.lAccountId
        };
        Map<String, Object> output = new Map<String, Object>();
        try{
            UTILS.invokeMethod('returnLinkBill', inputs, output, new Map<String, Object>());
            
            if(output.containsKey('result')){
                lClientOutput.lLink = (String) output.get('result');
                lClientOutput.lStatusCode = (Integer) output.get('statusCode');
            }
    	}
        catch(Exception e){
            LXD_VlocityUtils.badRequest(output, e.getMessage());
            LXD_VlocityUtils.debugErrorMessage(e);
            lClientOutput.lStatusCode = 400;
        }
        lClientOutputLst.add(lClientOutput);
		
        return lClientOutputLst;
    }
}