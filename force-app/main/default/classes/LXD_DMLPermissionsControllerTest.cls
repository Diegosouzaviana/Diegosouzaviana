@isTest
public with sharing class LXD_DMLPermissionsControllerTest {
    private static final Map<String, Object> OPTIONS_MAP = new Map<String,Object>();
    private static final String METHOD_NAME = 'manipulateData';
    private static final String METADATA_RECORD_API_NAME = 'LXD_TestMetadata';
    private static final Map<String, Object> sobjectNodeMap = new Map<String, Object>{
        'Name' => 'Test Account',
        'AccountNumber' => '1234567890',
        'Phone' => '(15) 9999-9999',
        'Website' => 'https://www.salesforce.com',
        'BillingStreet' => '123 Main St',
        'BillingCity' => 'San Francisco',
        'BillingState' => 'CA',
        'BillingPostalCode' => '94105',
        'BillingCountry' => 'USA',
        'ShippingStreet' => '123 Main St',
        'ShippingCity' => 'San Francisco',
        'ShippingState' => 'CA',
        'ShippingPostalCode' => '94105',
        'ShippingCountry' => 'USA',
        'LXD_Mobile__c' => '(15) 99999-9999'
    };

    @TestSetup
    static void makeData(){
        Id profileId = [SELECT Id, Name FROM Profile WHERE NAME = 'Minimum Access - Salesforce' LIMIT 1].Id;
        Id supervisorPermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Supervisor' LIMIT 1].Id;
        Id permissionBaseId = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Permission_Base' LIMIT 1].Id;

        UserRole userRole = new UserRole(Name= 'Test Role'); 
        insert userRole;

        User userSupervisor = new User(
            LastName = 'Prado',
            email = 'wesley_prado_dev@mail.com',
            Username = 'wesley_prado_dev@mail.com',
            alias = 'utest',
            profileId = profileId,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            UserRoleId = userRole.Id
        );
        User userCommon = new User(
            LastName = 'userCommon',
            email = 'userCommon_dev@mail.com',
            Username = 'userCommon_dev@mail.com',
            alias = 'utest',
            profileId = profileId,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            UserRoleId = userRole.Id
        );

        insert new List<User>{userSupervisor, userCommon};
        
        PermissionSetAssignment supervisorPermissions = new PermissionSetAssignment(AssigneeId = userSupervisor.Id, PermissionSetId = supervisorPermissionSetId);
        PermissionSetAssignment basePermissions = new PermissionSetAssignment(AssigneeId = userSupervisor.Id, PermissionSetId = permissionBaseId);
        insert new List<PermissionSetAssignment>{supervisorPermissions, basePermissions};
    }

    @isTest
    public static void hasPermissionTest(){
        User userSupervisor = [SELECT Id FROM User WHERE Username = 'wesley_prado_dev@mail.com' LIMIT 1];
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'insert',
            'objectName' => 'Account',
            'featureAPIName' => METADATA_RECORD_API_NAME,
            'sObjectNode' => sobjectNodeMap
        };

        Map<String,Object> outMap = new Map<String,Object>();

        Test.startTest();
        System.runAs(userSupervisor){
            LXD_DMLPermissionsController.invokeMethod(METHOD_NAME, inputMap, outMap, OPTIONS_MAP);
        }
        Test.stopTest();

        //System.assertEquals(true, outMap.get('Response') instanceof List<sObject>, 'A resposta não é uma lista de sObject');

       // List<sObject> response = (List<sObject>) outMap.get('Response');
        //System.assertEquals(true, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como verdadeiro.');
        //System.assertEquals(false, response.isEmpty(), 'Campo de Response deve retornar uma lista de sObjects.');

        System.debug('outMap: ' + outMap);
    }

    @isTest
    public static void hasNoPermissionInsertExceptionTest(){
        User userCommon = [SELECT Id FROM User WHERE Username = 'userCommon_dev@mail.com' LIMIT 1];
        String expectedErrorMessage = 'Você não tem permissão para executar este método ou a permissão personalizada foi digitada incorretamente. Fale com seu administrador.';
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'insert',
            'objectName' => 'Account',
            'featureAPIName' => METADATA_RECORD_API_NAME,
            'sObjectNode' => sobjectNodeMap
        };

        Map<String,Object> outMap = new Map<String,Object>();

        Test.startTest();
        System.runAs(userCommon){
            LXD_DMLPermissionsController.invokeMethod(METHOD_NAME, inputMap, outMap, OPTIONS_MAP);
        }
        Test.stopTest();

        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(expectedErrorMessage, outMap.get('Response'), 'Mensagem de erro incorreta.');
        
    }
    @isTest
    public static void hasNoPermissionDeleteExceptionTest(){
        User user = [SELECT Id FROM User WHERE Username = 'userCommon_dev@mail.com' LIMIT 1];
        String expectedErrorMessage = 'Você não tem permissão para executar este método ou a permissão personalizada foi digitada incorretamente. Fale com seu administrador.';
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'delete',
            'objectName' => 'Account',
            'featureAPIName' => METADATA_RECORD_API_NAME,
            'sObjectNode' => sobjectNodeMap
        };

        Map<String,Object> outMap = new Map<String,Object>();

        Test.startTest();
        System.runAs(user){
            LXD_DMLPermissionsController.invokeMethod(METHOD_NAME, inputMap, outMap, OPTIONS_MAP);
        }
        Test.stopTest();

        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(expectedErrorMessage, outMap.get('Response'), 'Mensagem de erro incorreta.');
        
    }
    @isTest
    public static void hasNoPermissionUpdateExceptionTest(){
        User user = [SELECT Id FROM User WHERE Username = 'userCommon_dev@mail.com' LIMIT 1];
        String expectedErrorMessage = 'Você não tem permissão para executar este método ou a permissão personalizada foi digitada incorretamente. Fale com seu administrador.';
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'update',
            'objectName' => 'Account',
            'featureAPIName' => METADATA_RECORD_API_NAME,
            'sObjectNode' => sobjectNodeMap
        };

        Map<String,Object> outMap = new Map<String,Object>();

        Test.startTest();
        System.runAs(user){
            LXD_DMLPermissionsController.invokeMethod(METHOD_NAME, inputMap, outMap, OPTIONS_MAP);
        }
        Test.stopTest();

        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(expectedErrorMessage, outMap.get('Response'), 'Mensagem de erro incorreta.');
        
    }
    @isTest
    public static void hasNoPermissionUpsertExceptionTest(){
        User user = [SELECT Id FROM User WHERE Username = 'userCommon_dev@mail.com' LIMIT 1];
        String expectedErrorMessage = 'Você não tem permissão para executar este método ou a permissão personalizada foi digitada incorretamente. Fale com seu administrador.';
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'upsert',
            'objectName' => 'Account',
            'featureAPIName' => METADATA_RECORD_API_NAME,
            'sObjectNode' => sobjectNodeMap
        };

        Map<String,Object> outMap = new Map<String,Object>();

        Test.startTest();
        System.runAs(user){
            LXD_DMLPermissionsController.invokeMethod(METHOD_NAME, inputMap, outMap, OPTIONS_MAP);
        }
        Test.stopTest();

        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(expectedErrorMessage, outMap.get('Response'), 'Mensagem de erro incorreta.');
        
    }
    @isTest
    public static void invalidOperationTypeExceptionTest(){
        User user = [SELECT Id FROM User WHERE Username = 'userCommon_dev@mail.com' LIMIT 1];
        String expectedErrorMessage = 'operationType inválido: ';
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'wrongOperationType',
            'objectName' => 'Account',
            'featureAPIName' => METADATA_RECORD_API_NAME,
            'sObjectNode' => sobjectNodeMap
        };

        Map<String,Object> outMap = new Map<String,Object>();

        Test.startTest();
        System.runAs(user){
            LXD_DMLPermissionsController.invokeMethod(METHOD_NAME, inputMap, outMap, OPTIONS_MAP);
        }
        Test.stopTest();

        String response = (String) outMap.get('Response');
        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(true, response.contains(expectedErrorMessage), 'Mensagem de erro incorreta.');
        
    }

    @isTest
    public static void hasNoOperationTypeExceptionTest(){
        User userSupervisor = [SELECT Id FROM User WHERE Username = 'wesley_prado_dev@mail.com' LIMIT 1];
        String expectedErrorMessage = 'operationType é obrigatório. Valores válidos: insert, update, delete e upsert';
        Map<String,Object> inputMap = new Map<String, Object>{
            'objectName' => 'Account',
            'featureAPIName' => METADATA_RECORD_API_NAME,
            'sObjectNode' => sobjectNodeMap
        };

        Map<String,Object> outMap = new Map<String,Object>();

        Test.startTest();
        System.runAs(userSupervisor){
            LXD_DMLPermissionsController.invokeMethod(METHOD_NAME, inputMap, outMap, OPTIONS_MAP);
        }
        Test.stopTest();

        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(expectedErrorMessage, outMap.get('Response'), 'Mensagem de erro incorreta.');

        System.debug('outMap: ' + outMap);
        
    }

    @isTest
    public static void hasNoFeatureAPINameExceptionTest(){
        User userSupervisor = [SELECT Id FROM User WHERE Username = 'wesley_prado_dev@mail.com' LIMIT 1];
        String expectedErrorMessage = 'featureAPIName é obrigatório.';
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'update',
            'objectName' => 'Account',
            'sObjectNode' => sobjectNodeMap
        };

        Map<String,Object> outMap = new Map<String,Object>();

        Test.startTest();
        System.runAs(userSupervisor){
            LXD_DMLPermissionsController.invokeMethod(METHOD_NAME, inputMap, outMap, OPTIONS_MAP);
        }
        Test.stopTest();

        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(expectedErrorMessage, outMap.get('Response'), 'Mensagem de erro incorreta.');

        System.debug('outMap: ' + outMap);
        
    }

    @isTest
    public static void noInstanceFeatureAPINameExceptionTest(){
        User userSupervisor = [SELECT Id FROM User WHERE Username = 'wesley_prado_dev@mail.com' LIMIT 1];
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'update',
            'objectName' => 'Account',
            'featureAPIName' => 'wrong_feature_api_name',
            'sObjectNode' => sobjectNodeMap
        };

        Map<String,Object> outMap = new Map<String,Object>();

        Test.startTest();
        System.runAs(userSupervisor){
            LXD_DMLPermissionsController.invokeMethod(METHOD_NAME, inputMap, outMap, OPTIONS_MAP);
        }
        Test.stopTest();

        String response = (String) outMap.get('Response');

        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(true, response.contains('Não foi encontrada instância para o metadado "Configuração de permissões API" para o nome de API'), 'Mensagem de erro incorreta.');

        System.debug('outMap: ' + outMap);
        
    }
}