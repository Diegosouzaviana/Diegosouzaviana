@isTest
public with sharing class LXD_CallIPFromSFCoreTest {
    @isTest
    public static void invokeIPSuccess() {
         Account testAccount = LXD_CLS_SObjectFactory.CreateAccount();
         insert testAccount;
        LXD_CallIntegrationProcedureFromSFCore.InputDTO inputDTO = new LXD_CallIntegrationProcedureFromSFCore.InputDTO();
        inputDTO.AccountId = testAccount.Id;
        inputDTO.procedureName = 'LXD_APIMassiveProblem';
        List<LXD_CallIntegrationProcedureFromSFCore.InputDTO> inputList = new List<LXD_CallIntegrationProcedureFromSFCore.InputDTO>{inputDTO};

        Test.startTest();
        List<LXD_CallIntegrationProcedureFromSFCore.outputDTO> output = LXD_CallIntegrationProcedureFromSFCore.invokeIP(inputList);
        Test.stopTest();

        LXD_CallIntegrationProcedureFromSFCore.outputDTO response = output.get(0);
        LXD_CallIntegrationProcedureFromSFCore.Contract result = response.result;
        
        System.assertEquals(1, output.size(), 'Output size should be 1');
        System.assertEquals(200, response.status, 'Status should be 200');
        System.assertEquals('incident_type', result.type, 'Type should be incident_type'); 
        System.assertEquals('2023/07/01', result.endDate, 'Start date should be 01/07/2023');
        System.assertEquals('12:20', result.endTime, 'End time should be 12:20');
    }
      @isTest
    public static void invokeIPEmpty() {
         Account testAccount = LXD_CLS_SObjectFactory.CreateAccount();
         insert testAccount;
        LXD_CallIntegrationProcedureFromSFCore.ipResponseTest = new Map<String, Object>{
            'status' => 400,
                'response' => new Map<String, Object>{}
                };
        LXD_CallIntegrationProcedureFromSFCore.InputDTO inputDTO = new LXD_CallIntegrationProcedureFromSFCore.InputDTO();
        inputDTO.AccountId = testAccount.Id;
        inputDTO.procedureName = 'LXD_APIMassiveProblem';
        List<LXD_CallIntegrationProcedureFromSFCore.InputDTO> inputList = new List<LXD_CallIntegrationProcedureFromSFCore.InputDTO>{inputDTO};

        Test.startTest();
        List<LXD_CallIntegrationProcedureFromSFCore.outputDTO> output = LXD_CallIntegrationProcedureFromSFCore.invokeIP(inputList);
        Test.stopTest();

        LXD_CallIntegrationProcedureFromSFCore.outputDTO response = output.get(0);
        LXD_CallIntegrationProcedureFromSFCore.Contract result = response.result;

        System.assertEquals(1, output.size(), 'Output size should be 1');
        System.assertEquals(null, result, 'result should be null');

      
    }
}