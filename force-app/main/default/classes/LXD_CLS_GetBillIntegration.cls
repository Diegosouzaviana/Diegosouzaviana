/*
*   @author: Misael Ribas
*   @since:  2022/12/20
*   @className: LXD_CLS_GetBillIntegration
*   @description: <fill the description>
*
*   =================== FIX LOG ========================
*   2022/11/16      Misael Ribas        Class creation.
*   2022/12/27      Wesley Prado        feat: add a variable that tells if a bill is expired more than 5 days✨
*   2023/01/09      Misael Ribas        feat: add a variable that tells if a bill is expired more than 50 days✨
*   2023/02/15      Guilherme Gauy      Added variable: dayCount
*   2023/05/24      Misael Ribas        feat: add validation of customer status and amount of overdue charges✨
*   2023/05/30      Misael Ribas        fix: implementation of integration and adjustments in chatbot inputs and outputs✨
*   ====================================================
*/

public class LXD_CLS_GetBillIntegration {

    public static Map<String,Object> mockResponse;

	public class ClientInput{
		@InvocableVariable(required=true)
		public String lCPF;
        @InvocableVariable(required=true)
		public String lAccountId;
        @InvocableVariable(required=false)
		public String ResponseTest;

        public ClientInput(){
            this.lCPF = null;
        }

        public ClientInput(String lCPF){
            this.lCPF = lCPF;
        }
	}

	public class ClientOutput{
		@InvocableVariable(required=true)
        public Boolean IntegrationError;
		@InvocableVariable(required=true)
        public String ErrorMessage;
		@InvocableVariable(required=true)
        public InfoInvoice Boleto;
		@InvocableVariable(required=true)
        public InfoInvoice ExpiredBill5Days;
		@InvocableVariable(required=true)
        public InfoInvoice ExpiredBill50Days;
		@InvocableVariable(required=true)
        public List<InfoInvoice> infoBoleto;
        @InvocableVariable(required=true)
        public Integer dayCount;

        @InvocableVariable(required=true)
        public Boolean aCustomerTwoInvoiceDelays;
        @InvocableVariable(required=true)
        public Boolean aClientStatus;

        public ClientOutput(){
            this.IntegrationError = null;
            this.ErrorMessage = null;
            this.Boleto = null;
            this.infoBoleto = null;
            this.ExpiredBill5Days = null;
        }
    }
    
    public class InfoInvoice{
        public Double amount;
        public String codigoCobranca;
        public String dueDate;
        public String payload;
        public String status;
        public String message;
    }

	@InvocableMethod(label='Busca boletos do cliente')
	public static List<ClientOutput> GetBill(List<ClientInput> lInvoicesClientLst){
    
		List<ClientOutput> lClientOutputLst = new List<ClientOutput>(); 
		ClientOutput output =  new ClientOutput();
		try{
            List<String> lClientLst = new List<String>();
            for(ClientInput lClientCurrent : lInvoicesClientLst){
                system.debug('test lClientCurrent: '+lClientCurrent);
                if(!String.isBlank(lClientCurrent.lCPF)){
                    lClientLst.add(lClientCurrent.lCPF);
                } 
            }

            if(lClientLst.isEmpty()){
                output.IntegrationError = true;
                lClientOutputLst.add(output);
                return lClientOutputLst;
            }
            system.debug('test lClientLst: '+lClientLst[0]);

            List<Contract> lContractLst = [SELECT Id, Status FROM Contract WHERE AccountId =: lInvoicesClientLst[0].lAccountId LIMIT 1];
            for(Contract lcontract:lContractLst){
                if(lcontract.Status == 'BLOQUEADO'){
                    output.aClientStatus = true;
                    break;
                }
            }
            
            Map<String,Object> response = new Map<String,Object>();
            Map<String, Object> inputMap = new Map<String, Object>();
        	Map<String, Object> optionsMap = new Map<String, Object>();
            
        	inputMap.put('CPF', lClientLst[0]);
            system.debug('test inputMap: '+inputMap);
            response = Test.isRunningTest() ? (Map<String,Object>) JSON.deserializeUntyped(lInvoicesClientLst[0].ResponseTest) : (Map<String,Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService('LXD_IP_BankSlipDataIntegration',inputMap, optionsMap);
            system.debug('teste response: '+response);
            
            if(response.containsKey('Boleto') && (response.get('statusCode') == 200 || response.get('statusCode') == '')){
                String lJsonBoletos = JSON.serialize(response.get('Boleto'));
                if(!lJsonBoletos.contains('[')){
                    lJsonBoletos = '['+lJsonBoletos+']';
                }
                system.debug('teste lJsonBoletos: '+lJsonBoletos);
                List<InfoInvoice> lBoletosLst = (List<InfoInvoice>) JSON.deserialize(lJsonBoletos, List<InfoInvoice>.class);

                Integer cont = 0;
                for(InfoInvoice invoice : lBoletosLst){
                    system.debug('test invoice:'+invoice);
                    
                    if(invoice.message == 'null'){
                        //Validando prazos expiração da data de vencimento
                    	if(Date.parse(invoice.dueDate) <= Date.today().addDays(-5) && Date.parse(invoice.dueDate) >= Date.today().addDays(-49) && output.ExpiredBill5Days == null){
                        	Date billDate = Date.parse(invoice.dueDate);
                        	output.ExpiredBill5Days = invoice;
                        	output.dayCount = billDate.daysBetween(Date.today());
                    	} else if(Date.parse(invoice.dueDate) <= Date.today().addDays(-50) && output.ExpiredBill50Days == null){
                        	output.ExpiredBill50Days = invoice;
                    	}

                    	//Validando quantidade de boletos atrasados
                    	if(invoice.status.toLowerCase() == 'Em Atraso'){
                        	cont++;
                    	}
                    }
                }
                if(cont>=2){
                    output.aCustomerTwoInvoiceDelays = true;
                }

                output.infoBoleto = lBoletosLst;
                if(lBoletosLst.size() == 1){
                    output.Boleto = lBoletosLst[0];
                }
                output.IntegrationError = false;
            }
            else{
                output.IntegrationError = true;
                
                if(response.get('statusCode') == 400){
                    output.ErrorMessage = 'Os documentos passados não estão vinculados.';
                }
                else if(response.get('statusCode') == 404){
                    output.ErrorMessage = 'Os documentos passados para este cliente não foram encontrados.';                    
                }
            }

            lClientOutputLst.add(output);
		}
        catch(Exception e){
            LXD_VlocityUtils.debugErrorMessage(e);

            output.IntegrationError = true;
            output.ErrorMessage = e.getMessage();
			lClientOutputLst.add(output);
        }
        system.debug('teste lClientOutputLst: '+lClientOutputLst);
		return lClientOutputLst;
	}   
}