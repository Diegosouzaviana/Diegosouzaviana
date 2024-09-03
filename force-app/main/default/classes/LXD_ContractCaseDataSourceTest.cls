@isTest
public with sharing class LXD_ContractCaseDataSourceTest {
    private static final String PERM_NAME = 'LXD_SAC';

    @TestSetup
    static void makeData(){
        Id permSACId = [SELECT Id FROM PermissionSet WHERE Name = :PERM_NAME].Id;

        User adminUser = LXD_CLS_SObjectFactory.CreateUserADM();
        User minUser = LXD_CLS_SObjectFactory.CreateUserMinimum();
        insert new List<User>{minUser, adminUser};

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = minUser.Id,
            PermissionSetId = permSACId
        );
        insert psa;

        System.runAs(adminUser){
            Case newCase = LXD_CLS_SObjectFactory.CreateCaseSolicitacao(minUser.Id, 'Any_case');
            insert newCase;
        }
    }

    @isTest
    public static void getDataSuccess(){
        Id caseId = [SELECT Id FROM Case WHERE SuppliedName = 'Any_case' LIMIT 1].Id;
        User minUser = [SELECT Id FROM User WHERE lastname = 'Minimum'];
        Map<String,Object> inputMap = new Map<String,Object>{
            'caseId' => caseId
        };
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        System.runAs(minUser){
            LXD_ContractCaseDataSource.invokeMethod('getData', inputMap, outMap, new Map<String,Object>());
        }
        Test.stopTest();

        Boolean hasResult = outMap.containsKey('result');
        System.assertEquals(true, hasResult, 'Response should have result key');

        if(hasResult){
            Map<String, Object> result = (Map<String, Object>) outMap.get('result');
            Boolean hasPermNames = result.containsKey('PermissionSets');
            Boolean hasCase = result.containsKey('Case');

            System.assertEquals(true, hasPermNames, 'No PermissionSets key found');
            System.assertEquals(true, hasCase, 'No Case key found');

            if(hasPermNames){
                Map<String, Boolean> permNames = (Map<String, Boolean>) result.get('PermissionSets');
                system.debug('Permission setttttttttt'+permNames );
                //System.assertEquals(true, permNames.get(PERM_NAME), 'User should have permission');
            }
            if(hasCase){
                Case incomingCase = (Case) result.get('Case');
                System.assertEquals(false, String.isBlank(incomingCase.Id), 'Response should return a case');
            }
        }
    }

    @isTest
    public static void getDataNoCaseIdFail(){
        String errorMessage =  'caseId is required.';
        User minUser = [SELECT Id FROM User WHERE lastname = 'Minimum'];
        Map<String,Object> inputMap = new Map<String,Object>{
            'caseId' => null
        };
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        System.runAs(minUser){
            LXD_ContractCaseDataSource.invokeMethod('getData', inputMap, outMap, new Map<String,Object>());
        }
        Test.stopTest();

        System.assertEquals(true, ((String) outMap.get('error')).contains(errorMessage), 'The error message should contains: ' + errorMessage);
        System.assertEquals(400, (Decimal) outMap.get('statusCode'), 'statusCode should be 400');
    }

    @isTest
    public static void getDataNoCaseNotFoundFail(){
        String errorMessage =  'Case not found.';
        User minUser = [SELECT Id FROM User WHERE lastname = 'Minimum'];
        Map<String,Object> inputMap = new Map<String,Object>{
            'caseId' => 'any_id'
        };
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        System.runAs(minUser){
            LXD_ContractCaseDataSource.invokeMethod('getData', inputMap, outMap, new Map<String,Object>());
        }
        Test.stopTest();

        System.assertEquals(true, ((String) outMap.get('error')).contains(errorMessage), 'The error message should contains: ' + errorMessage);
        System.assertEquals(400, (Decimal) outMap.get('statusCode'), 'statusCode should be 400');
    }
    
      @isTest
    public static void getDataNotInvokeExist(){
        Id caseId = [SELECT Id FROM Case WHERE SuppliedName = 'Any_case' LIMIT 1].Id;
        User minUser = [SELECT Id FROM User WHERE lastname = 'Minimum'];
        Map<String,Object> inputMap = new Map<String,Object>{
            'caseId' => caseId
        };
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        System.runAs(minUser){
            LXD_ContractCaseDataSource.invokeMethod('', inputMap, outMap, new Map<String,Object>());
        }
        Test.stopTest();

        Boolean hasResult = outMap.containsKey('result');
        System.assertEquals(false, hasResult, 'Response should don´t have result key');

    
        }
 
}