@isTest
public with sharing class LXD_CallIPFromSFAPITest {
  @isTest
    public static void invokeIPSuccess() {
        Case caso = LXD_CLS_SObjectFactory.CreateCaseSolicitacao('0058b00000GOTPaAAP');
        Insert caso;
        LXD_CallIntegrationProcedureFromSFAPI.InputDTO inputDTO = new LXD_CallIntegrationProcedureFromSFAPI.InputDTO();
        inputDTO.CaseId = caso.Id;
        inputDTO.procedureName = 'LXD_ApiMassive_ProblemCase';
        List<LXD_CallIntegrationProcedureFromSFAPI.InputDTO> inputList = new List<LXD_CallIntegrationProcedureFromSFAPI.InputDTO>{inputDTO};

        Test.startTest();
        List<LXD_CallIntegrationProcedureFromSFAPI.outputDTO> output = LXD_CallIntegrationProcedureFromSFAPI.invokeIP(inputList);
        Test.stopTest();

        LXD_CallIntegrationProcedureFromSFAPI.outputDTO response = output.get(0);
        LXD_CallIntegrationProcedureFromSFAPI.Contract result = response.result;
        
        System.assertEquals(1, output.size(), 'Output size should be 1');
        System.assertEquals(false, result.boleano, 'Boleano should be false');

       
    }
    
@isTest
    public static void invokeIPEmpty() {
        Case caso = LXD_CLS_SObjectFactory.CreateCaseSolicitacao('0058b00000GOTPaAAP');
        Insert caso;
        LXD_CallIntegrationProcedureFromSFAPI.ipResponseTest = new Map<String, Object>{
        'status' => 200,
            'response' => new Map<String, Object>()
    };
        LXD_CallIntegrationProcedureFromSFAPI.InputDTO inputDTO = new LXD_CallIntegrationProcedureFromSFAPI.InputDTO();
        inputDTO.CaseId = caso.Id;
        inputDTO.procedureName = 'LXD_ApiMassive_ProblemCase';
        List<LXD_CallIntegrationProcedureFromSFAPI.InputDTO> inputList = new List<LXD_CallIntegrationProcedureFromSFAPI.InputDTO>{inputDTO};

        Test.startTest();
        List<LXD_CallIntegrationProcedureFromSFAPI.outputDTO> output = LXD_CallIntegrationProcedureFromSFAPI.invokeIP(inputList);
        Test.stopTest();

        LXD_CallIntegrationProcedureFromSFAPI.outputDTO response = output.get(0);
        LXD_CallIntegrationProcedureFromSFAPI.Contract result = response.result;
        
        System.assertEquals(1, output.size(), 'Output size should be 1');
		System.assertEquals(null, result, 'result size should be null');

 
    }
}