/*
*   @author: Misael Ribas
*   @since: yyyy/mm/dd
*   @className: LXD_CLS_SendEmail
*   @description: <fill the description>
*
*   =================== FIX LOG ========================
*   2022/12/30            Misael Ribas      Class restructuring
*   ====================================================
*/
public class LXD_CLS_SendEmail{
	public class ClientInput{
		@InvocableVariable(required=true)
		public String lEmail;
        @InvocableVariable(required=true)
        public String lCpf;
        @InvocableVariable
        public String lBoletoCode;
	}
	public class ClientOutput{
		@InvocableVariable(required=true)
        public Boolean lEmailEnviado;
    }
  
	@InvocableMethod(label='Enviar email com boleto para cliente')
	public static List<ClientOutput> SendEmail(List<ClientInput> lEmailClientLst){
    	List<ClientOutput> ClientOutputLst = new List<ClientOutput>();
        ClientOutput lClientOutput = new ClientOutput(); 
		lClientOutput.lEmailEnviado = false;
        ClientOutputLst.add(lClientOutput);
        
        if(lEmailClientLst.isEmpty()) return ClientOutputLst;
        ClientInput lEmailClient = lEmailClientLst[0];
        
        List<LXD_CLS_CallInvoiceIntegration.ClientInput> lCliLst = new List<LXD_CLS_CallInvoiceIntegration.ClientInput>();
        LXD_CLS_CallInvoiceIntegration.ClientInput lCli = new LXD_CLS_CallInvoiceIntegration.ClientInput();
		lCli.lCPF = lEmailClient.lCpf;
        lCli.lBoletoCode = lEmailClient.lBoletoCode;
        lCliLst.add(lCli);
        
		Blob lBody = null;
		try{
			List<LXD_CLS_CallInvoiceIntegration.ClientOutput> outputInvoiceIntegrationlst = LXD_CLS_CallInvoiceIntegration.SendInvoices(lCliLst);
            LXD_CLS_CallInvoiceIntegration.ClientOutput outputInvoiceIntegration = outputInvoiceIntegrationlst[0];
		
			if(outputInvoiceIntegration == null) return ClientOutputLst;
	
			String lPdfBoleto = outputInvoiceIntegration.Boletos;
		
			lBody = EncodingUtil.base64Decode(lPdfBoleto);
		} 
		catch(Exception e){
			lClientOutput.lEmailEnviado = false;
            LXD_VlocityUtils.debugErrorMessage(e);
		}
        try{

            Messaging.EmailFileAttachment lAttach = new Messaging.EmailFileAttachment();
            lAttach.setContentType('application/pdf');
            lAttach.setFileName('Boleto.pdf');
            lAttach.setInline(false);
            lAttach.Body = lBody != null ? lBody : Blob.valueOf('');//lPdf;
            
            Messaging.SingleEmailMessage lMail = new Messaging.SingleEmailMessage();
            lMail.setUseSignature(false);
            lMail.setToAddresses(new String[] { lEmailClient.lEmail });
            lMail.setSubject('Desktop - 2º via do boleto');
            lMail.setHtmlBody('Estamos lhe enviando a 2º via do boleto!');
            lMail.setFileAttachments( new Messaging.EmailFileAttachment[]{lAttach});
    
		
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {lMail});
			lClientOutput.lEmailEnviado = true;
		}
        catch(Exception e){
			lClientOutput.lEmailEnviado = false;
            LXD_VlocityUtils.debugErrorMessage(e);
        }
		return ClientOutputLst;
	}   

}