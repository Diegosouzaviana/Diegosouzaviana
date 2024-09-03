/*
*   @author: Misael Ribas
*   @since: yyyy/mm/dd
*   @className: LXD_CLS_CallInvoiceIntegration
*   @description: <fill the description>
*
*   =================== FIX LOG ========================
*   2022/11/10            Wesley prado      Add isRunningTest verification & Mocked values.
*   ====================================================
*/

public class LXD_CLS_CallInvoiceIntegration{

	public class ClientInput{
		@InvocableVariable(required=true)
		public String lCPF;
        @InvocableVariable
		public String lBoletoCode;
	}
	public class ClientOutput{
		@InvocableVariable(required=true)
        public Boolean IntegrationError;
		@InvocableVariable(required=true)
        public String ErrorMessage;
		@InvocableVariable(required=true)
        public String Boletos;
    }
  
	@InvocableMethod(label='Busca pdf do boleto')
	public static List<ClientOutput> SendInvoices(List<ClientInput> lInvoicesClientLst){
    
		List<ClientOutput> lClientOutputLst = new List<ClientOutput>(); 
		ClientOutput output =  new ClientOutput();
        lClientOutputLst.add(output);
		try{
            List<String> lClientLst = new List<String>();
            List<String> lBoletoLst = new List<String>();
            for(ClientInput lClientCurrent : lInvoicesClientLst){
                if(lClientCurrent.lCPF != null){
                    lClientLst.add(lClientCurrent.lCPF);
                    lBoletoLst.add(lClientCurrent.lBoletoCode);
                }
            }
            if(lClientLst.isEmpty()){
            	output.IntegrationError = true;
                return lClientOutputLst;
            }
            
            Map<String,Object> response = Test.isRunningTest()? new Map<String,Object>{'segViaBoleto'=>'dGVzdGU='} : (Map<String,Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService('LXD_SecondChargeIntegration', new Map<String, Object>{'CPF' => lClientLst[0], 'Boleto' => lBoletoLst[0]}, new Map<String, Object>());
            output.Boletos = (String) response.get('segViaBoleto');
            
			output.IntegrationError = false;
		}
        catch(Exception e){
            output.IntegrationError = true;
            output.ErrorMessage = e.getMessage();
            LXD_VlocityUtils.debugErrorMessage(e);
        }
		return lClientOutputLst;
	}   
}