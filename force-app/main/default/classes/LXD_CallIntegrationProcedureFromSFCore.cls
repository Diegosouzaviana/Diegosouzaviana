/*
*   @company: LabsXD
*   @author: Wesley Prado
*   @since: 2022/12/02
*   @className: LXD_VlocityUtils
*   @description: Remote Action Utils class for Vlocity.
*
*   =================== UPDATE LOG ========================
*   2022/12/23      Wesley Prado        Feat: add trycatch block ✨.
*   =======================================================
*/
public with sharing class LXD_CallIntegrationProcedureFromSFCore {
    public class InputDTO {
		@InvocableVariable(required=true)
		public String procedureName;
        @InvocableVariable(required=true)
        public String AccountId;
	}

    public class outputDTO {
		@InvocableVariable(required=true)
        public Decimal status;
        @InvocableVariable(required=false)
        public Contract result;

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
        public String contractNumber;
        @InvocableVariable(required=false)
        public String type;
        @InvocableVariable(required=false)
        public String startDate;
        @InvocableVariable(required=false)
        public String startTime;
        @InvocableVariable(required=false)
        public String endDate;
        @InvocableVariable(required=false)
        public String endTime;

        
        public Contract(){
            this.contractNumber = '';
            this.type = '';
            this.startDate = '';
            this.startTime = '';
            this.endDate = '';
            this.endTime = '';
        }
    }
    @testVisible 
    private static Map<String, Object> ipResponseTest =  new Map<String, Object>{
                'status' => 200,
                'response' => new Map<String, Object>{
                    'NumberContact' => new Map<String, Object>{
                        'tipo' => 'incident_type',
                        'inicio' => '2023-02-03 12:20:00',
                        'Fecha' => '2023-07-01 12:20:00'
                    }
                }
            };
        
    @InvocableMethod(label='Call IP' description='Method to call Integration Procedure')
    public static List<outputDTO> invokeIP(List<InputDTO> input){
        if(input == null || input.isEmpty()) throw new LXD_CallIntegrationProcedureFromSFCoreException('Invalid Input');

        List<outputDTO> output = new List<outputDTO>();

        InputDTO inputDTO = input.get(0);
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        inputMap.put('AccountId', inputDTO.AccountId);

        try {
            Map<String, Object> ipResponse = Test.isRunningTest() ? ipResponseTest : (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(inputDTO.procedureName, inputMap, outputMap);

            if(ipResponse == null) return null;
            Decimal statusCode = ipResponse.containsKey('status') ? (Decimal) ipResponse.get('status') : 500;
                System.debug('ipResponse' +ipResponse );

            if(ipResponse.containsKey('response')){
                Map<String, Object> contract = (Map<String, Object>) ipResponse.get('response');
                System.debug('contract' +contract );
                System.debug('contract.keySet().size()' +contract.keySet().size() );

                if(contract.keySet().size() == 0){
                    output.add(new outputDTO(
                        statusCode
                    ));
					System.debug('aquiii' +output );
                    return output;
                }
                    outputDTO outputDTO = new outputDTO();               
                
                    Map<String, Object> c = (Map<String, Object>) contract.get('NumberContact');
                    outputDTO.status = statusCode;
                    outputDTO.result.contractNumber = String.valueOf(c.get('Number'));
                    outputDTO.result.type = c.containsKey('tipo') ? (String) c.get('tipo') : null;
                
                    if(c.containsKey('Fecha') && !String.isBlank((String) c.get('Fecha'))){
                        String datetimeString = (String) c.get('Fecha');
                        String Fecha = String.valueOf(datetimeString.substring(0,10));
                          String Hora = String.valueOf(datetimeString.substring(11,16));

                        
                        outputDTO.result.endDate = Fecha.replace('-', '/');
                        outputDTO.result.endTime = Hora;
                        //Datetime DT = (DateTime)JSON.deserialize(datetimeString, Datetime.class);
                        
                        //outputDTO.result.endDate = DT.format('dd/MM/yyyy');
                        //outputDTO.result.endTime = DT.format('HH:mm');
                    	 output.add(outputDTO);

                }                   
                
            }
        } catch (Exception e) {
            LXD_VlocityUtils.debugErrorMessage(e);
        }

        return output;
    }

    public class LXD_CallIntegrationProcedureFromSFCoreException extends Exception {}
}