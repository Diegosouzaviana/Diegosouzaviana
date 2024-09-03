public with sharing class LXD_CallIntegrationProcedureFromSFAPI{
    public class InputDTO {
		@InvocableVariable(required=true)
		public String procedureName;
        @InvocableVariable(required=true)
        public String CaseId;
	}

    public class outputDTO {
        @InvocableVariable(required=false)
        public Contract result;
        @InvocableVariable(required=false)
        public Decimal status;

        public outputDTO(){
            this.result = new Contract();
        }
        public outputDTO(Decimal status, Contract result){
            this.status = status;
            this.result = result;
        }
        public outputDTO(Decimal status){
            this.status = status;
            this.result = null;
        }
	}

    public class Contract{
        @InvocableVariable(required=false)
        public Boolean boleano;
        
        public Contract(){
            this.boleano = true;
        }
    }
	@testVisible 
    private static Map<String, Object> ipResponseTest = new Map<String, Object>{
        'status' => 200,
            'response' => new Map<String, Object>{
                'bolean' => false   
                    }
    };
                    
    @InvocableMethod(label='Call IP' description='Method to call Integration Procedure')
    public static List<outputDTO> invokeIP(List<InputDTO> input){
        if(input == null || input.isEmpty()) throw new LXD_CallIntegrationProcedureFromSFCoreException('Invalid Input');
		
        List<outputDTO> output = new List<outputDTO>();

        InputDTO inputDTO = input.get(0);
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        inputMap.put('CaseId', inputDTO.CaseId);

        try {
            Map<String, Object> ipResponse = Test.isRunningTest() ? ipResponseTest : (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(inputDTO.procedureName, inputMap, outputMap);

            if(ipResponse == null) return null;
            Decimal statusCode = ipResponse.containsKey('status') ? (Decimal) ipResponse.get('status') : 500;

            if(ipResponse.containsKey('response')){
                Map<String, Object> contract = (Map<String, Object>) ipResponse.get('response');

                if(contract.keySet().size() == 0){
                    output.add(new outputDTO(
                        statusCode
                    ));

                    return output;
                }
                    outputDTO outputDTO = new outputDTO();               
                    outputDTO.result.boleano = (boolean)contract.get('bolean');
                    output.add(outputDTO);
   
                
            }
        } catch (Exception e) {
            LXD_VlocityUtils.debugErrorMessage(e);
        }

        return output;
    }

    public class LXD_CallIntegrationProcedureFromSFCoreException extends Exception {}
}