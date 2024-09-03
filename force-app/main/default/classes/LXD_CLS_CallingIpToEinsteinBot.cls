public class LXD_CLS_CallingIpToEinsteinBot{
    
    public class ClientInput {
		@InvocableVariable(required=true)
		public String aClientCPF;
	}
	public class ClientOutput {
		@InvocableVariable(required=true)
        public Boolean aClientStatus;
        @InvocableVariable(required=true)
		public Boolean aAuthorizedUnlockedClient;
        @InvocableVariable(required=true)
		public Boolean aCustomerTwoInvoiceDelays;
	}

    @InvocableMethod(label='Chamar IP dos clientes' description='Chamar IP dos clientes para a utilização no Einstein Bot')
    public static List<ClientOutput> invokeMethod(List<ClientInput> lCpfClientLst){
        
        List<String> lCpfLst = new List<String>();
        for(ClientInput lCpfCurrent : lCpfClientLst){
      		lCpfLst.add(lCpfCurrent.aClientCPF);
    	}
        Map<String,Object> response = (Map<String,Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService('LXD_CustomerInvoiceIntegration', new Map<String, Object>{'CPF' => lCpfLst[0]}, new Map<String, Object>());
		system.debug('response: '+response);
        
        List<ClientOutput> lClientOutputLst = new List<ClientOutput>();
        ClientOutput lClientOutput = new ClientOutput();
        lClientOutput.aClientStatus = (Boolean) response.get('ClienteBloqueado');
        lClientOutput.aAuthorizedUnlockedClient = (Boolean) response.get('DesbloqueioAutorizado');
        lClientOutput.aCustomerTwoInvoiceDelays = (Boolean) response.get('DuasFaturasEmAtraso');
        lClientOutputLst.add(lClientOutput);
        return lClientOutputLst;
    }
}