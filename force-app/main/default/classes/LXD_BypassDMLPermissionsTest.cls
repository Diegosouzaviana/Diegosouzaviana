@isTest
public with sharing class LXD_BypassDMLPermissionsTest {
    private static final String METHOD_NAME = 'manipulateData';
    private static final Map<String, Object> SOBJECT_NODE_MAP = new Map<String, Object>{
        'Name' => 'Test Account',
        'Phone' => new Map<String, Object>{
            'value' => '(15) 9999-9999',
            'datatype' => 'string'
        },
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
        Id sysAdminProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' OR Name ='Administrador do sistema' LIMIT 1].Id;
        Id permissionBaseId = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Permission_Base' LIMIT 1].Id;

        UserRole userRole = new UserRole(Name= 'Test Role'); 
        insert userRole;

        User commonUser = new User(
            LastName = 'commonUser',
            email = 'commonUser_dev@mail.com',
            Username = 'commonUser_dev@mail.com',
            alias = 'utest',
            profileId = profileId,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            UserRoleId = userRole.Id
        );
        
        User adminUser = new User(
            LastName = 'adminUser',
            email = 'adminUser_dev@mail.com',
            Username = 'adminUser_dev@mail.com',
            alias = 'uAdmin',
            profileId = sysAdminProfileId,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            UserRoleId = userRole.Id
        );
        insert new List<User>{commonUser, adminUser};
        
        insert new PermissionSetAssignment(AssigneeId = commonUser.Id, PermissionSetId = permissionBaseId);

        System.runAs(adminUser){
            Account account = new Account(Name = 'Test Account 2');
            insert account;
        }
    }

    @isTest
    public static void emptySObjectNodeExceptionTest(){
        String expectedErrorMessage = 'sObjectNode é obrigatório.';
        User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'insert',
            'objectName' => 'Account',
            'sObjectNode' => ''
        };
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();

        Test.startTest();
        System.runAs(commonUser){
            LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
        }
        Test.stopTest();

        System.debug('outMap: ' + outMap);

        String response = (String) outMap.get('Response');
        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(true, response.contains(expectedErrorMessage), 'Mensagem de erro incorreta.');
    }

    @isTest
    public static void invalidSObjectNodeExceptionTest(){
        String expectedErrorMessage = 'sObjectNode inválido.';
        User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'insert',
            'objectName' => 'Account',
            'sObjectNode' => null
        };
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();

        Test.startTest();
        System.runAs(commonUser){
            LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
        }
        Test.stopTest();

        System.debug('outMap: ' + outMap);

        String response = (String) outMap.get('Response');
        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(true, response.contains(expectedErrorMessage), 'Mensagem de erro incorreta.');
    }

    @isTest
    public static void emptyObjectNameTest(){
        String expectedErrorMessage = 'objectName é obrigatório.';
        User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'insert',
            'objectName' => '',
            'sObjectNode' => SOBJECT_NODE_MAP
        };
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        Test.startTest();
        System.runAs(commonUser){
            LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
        }
        Test.stopTest();

        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(expectedErrorMessage, (String) outMap.get('Response'), 'Mensagem de erro incorreta.');
    }

    @isTest
    public static void emptyOperationTypeTest(){
        String expectedErrorMessage = 'operationType é obrigatório. Valores válidos: insert, update, delete e upsert.';
        User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => '',
            'objectName' => 'Account',
            'sObjectNode' => SOBJECT_NODE_MAP
        };
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        Test.startTest();
        System.runAs(commonUser){
            LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
        }
        Test.stopTest();

        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(expectedErrorMessage, (String) outMap.get('Response'), 'Mensagem de erro incorreta.');
    }

    @isTest
    public static void invalidOperationTypeTest(){
        String expectedErrorMessage = 'operationType inválido: ';
        User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'wrong_operation_type',
            'objectName' => 'Account',
            'sObjectNode' => SOBJECT_NODE_MAP
        };
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        Test.startTest();
        System.runAs(commonUser){
            LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
        }
        Test.stopTest();

        String response = (String) outMap.get('Response');
        System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(true, response.contains(expectedErrorMessage), 'Mensagem de erro incorreta.');
    }

    @isTest
    public static void singleInsertSuccessTest(){
        User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'insert',
            'objectName' => 'Account',
            'sObjectNode' => SOBJECT_NODE_MAP
        };
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        Test.startTest();
        System.runAs(commonUser){
            LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
        }
        Test.stopTest();

        List<sObject> response = (List<sObject>) outMap.get('Response');
        System.assertEquals(true, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(1, response.size(), 'Quantidade de registros retornados incorreta.');
    }

    @isTest
    public static void singleInsertSuccessStringInputTest(){
        User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'insert',
            'objectName' => 'Account',
            'sObjectNode' => JSON.serialize(SOBJECT_NODE_MAP)
        };
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        Test.startTest();
        System.runAs(commonUser){
            LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
        }
        Test.stopTest();

        List<sObject> response = (List<sObject>) outMap.get('Response');
        System.assertEquals(true, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(1, response.size(), 'Quantidade de registros retornados incorreta.');
    }

    @isTest
    public static void multipleInsertSuccessTest(){
        Map<String, Object> clonedMap = SOBJECT_NODE_MAP.clone();
        clonedMap.put('Name', 'Account 2');

        List<Map<String, Object>> sObjectNodeList = new List<Map<String, Object>>{
            SOBJECT_NODE_MAP,
            clonedMap
        };
        User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'insert',
            'objectName' => 'Account',
            'sObjectNode' => sObjectNodeList
        };
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        Test.startTest();
        System.runAs(commonUser){
            LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
        }
        Test.stopTest();

        List<sObject> response = (List<sObject>) outMap.get('Response');
        System.assertEquals(true, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(2, response.size(), 'Quantidade de registros retornados incorreta.');
    }

    @isTest
    public static void updateSuccessTest(){
        User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        Map<String, Object> node = new Map<String, Object>{
            'Id' => account.Id,
            'LXD_Email__c' => 'test@labsxd.com'
        };

        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'update',
            'objectName' => 'Account',
            'sObjectNode' => node
        };

        Map<String,Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        Test.startTest();
        System.runAs(commonUser){
            LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
        }
        Test.stopTest();
        List<Account> response = (List<sObject>) outMap.get('Response');
        System.assertEquals(true, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals('test@labsxd.com', response[0].LXD_Email__c, 'Email da conta não atualizada.');
    }

    @isTest
    public static void deleteSuccessTest(){
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        Map<String, Object> node = new Map<String, Object>{
            'Id' => account.Id
        };
        User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'delete',
            'objectName' => 'Account',
            'sObjectNode' => node
        };
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();
        Test.startTest();
        System.runAs(commonUser){
            LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
        }
        Test.stopTest();

        List<sObject> response = (List<sObject>) outMap.get('Response');
        System.assertEquals(true, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(0, [SELECT count() FROM Account WHERE Name = 'Test Account 2' LIMIT 1], 'Conta não foi deletada.');
        System.assertEquals(1, response.size(), 'Não retornou o registro deletado.');
    }

    @isTest
    public static void upsertSuccessTest(){
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
        Map<String, Object> oldAccount = new Map<String, Object>{
            'LXD_Email__c' => 'test@labsxd.com',
            'Id' => new Map<String, Object>{
                'value' => account.Id,
                'type' => 'id'
            }
        };
        Map<String, Object> newAccount = new Map<String, Object>{
            'Name' => 'New Account'
        };
        List<Map<String, Object>> sObjectNodeList = new List<Map<String, Object>>{
            oldAccount,
            newAccount
        };
        Map<String,Object> inputMap = new Map<String, Object>{
            'operationType' => 'upsert',
            'objectName' => 'Account',
            'sObjectNode' => sObjectNodeList
        };
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String, Object> options = new Map<String,Object>();

        Test.startTest();
        System.runAs(commonUser){
            LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
        }
        Test.stopTest();

        Map<String, Account> accountMap = new Map<String, Account>();
        for(Account acc :[SELECT Id, Name, LXD_Email__c FROM Account]){
            accountMap.put(acc.Name, acc);
            accountMap.put(acc.LXD_Email__c, acc);
        }

        List<sObject> response = (List<sObject>) outMap.get('Response');
        System.assertEquals(true, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
        System.assertEquals(2, response.size(), 'Não retornou os registros do upsert.');
        System.assertEquals(true, accountMap.containsKey('test@labsxd.com'), 'Conta não foi atualizada.');
        System.assertEquals(true, accountMap.containsKey('New Account'), 'Conta não foi criada.');
    }

    // @isTest
    // public static void insertWithFieldConfigTest(){
    //     Id AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1].Id;
    //     User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
    //     Map<String, Object> sObjectNodeInput = new Map<String, Object>{
    //         'LXD_TrustUnlockDate__c' => new Map<String, Object>{
    //                 'value' => '08/11/2022',
    //                 'datatype' => 'date'
    //             },
    //         'AccountId' => AccountId
    //     };

    //     Map<String,Object> inputMap = new Map<String, Object>{
    //         'operationType' => 'insert',
    //         'objectName' => 'Contract',
    //         'sObjectNode' => sObjectNodeInput
    //     };
    //     Map<String,Object> outMap = new Map<String,Object>();
    //     Map<String, Object> options = new Map<String,Object>();

    //     Test.startTest();
    //     System.runAs(commonUser){
    //         LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
    //     }
    //     Test.stopTest();

    //     Assert.isInstanceOfType(outMap.get('Response'), List<sObject>.class, 'Response is not instance of List<sObject>: ' + outMap.get('Response'));
    //     Assert.isTrue((Boolean) outMap.get('Success'), 'Success should be true');

    //     List<sObject> response = (List<sObject>) outMap.get('Response');

    //     Assert.areEqual(1, response.size(), 'Reponse should have 1 record count');
    //     Assert.areEqual(1, [SELECT count() FROM Contract WHERE AccountId = :AccountId], 'Should have inserted 1 record');
    // }

    // @isTest
    // public static void failNoValueFieldConfigTest(){
    //     String expectedErrorMessage = 'value é obrigatório para o campo: ';
    //     Id AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1].Id;
    //     User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
    //     Map<String, Object> sObjectNodeInput = new Map<String, Object>{
    //         'LXD_TrustUnlockDate__c' => new Map<String, Object>{
    //                 'datatype' => 'date'
    //             },
    //         //'Status' => 'RASCUNHO',
    //         'AccountId' => AccountId
    //     };

    //     Map<String,Object> inputMap = new Map<String, Object>{
    //         'operationType' => 'insert',
    //         'objectName' => 'Contract',
    //         'sObjectNode' => sObjectNodeInput
    //     };
    //     Map<String,Object> outMap = new Map<String,Object>();
    //     Map<String, Object> options = new Map<String,Object>();

    //     Test.startTest();
    //     System.runAs(commonUser){
    //         LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
    //     }
    //     Test.stopTest();

    //     String response = (String) outMap.get('Response');
    //     System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
    //     System.assertEquals(true, response.contains(expectedErrorMessage), 'Mensagem de erro não contém o texto esperado.');
    // }

    // @isTest
    // public static void failInvalidFieldConfigTest(){
    //     String expectedErrorMessage = 'Tipo de campo inválido: ';
    //     Id AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1].Id;
    //     User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
    //     Map<String, Object> sObjectNodeInput = new Map<String, Object>{
    //         'LXD_TrustUnlockDate__c' => new List<Boolean>(),
    //         //'Status' => 'RASCUNHO',
    //         'AccountId' => AccountId
    //     };

    //     Map<String,Object> inputMap = new Map<String, Object>{
    //         'operationType' => 'insert',
    //         'objectName' => 'Contract',
    //         'sObjectNode' => sObjectNodeInput
    //     };
    //     Map<String,Object> outMap = new Map<String,Object>();
    //     Map<String, Object> options = new Map<String,Object>();

    //     Test.startTest();
    //     System.runAs(commonUser){
    //         LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
    //     }
    //     Test.stopTest();

    //     String response = (String) outMap.get('Response');
    //     System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
    //     System.assertEquals(true, response.contains(expectedErrorMessage), 'Mensagem de erro não contém o texto esperado.'); 
    // }

    // @isTest
    // public static void failInvalidDatatypeFieldConfigTest(){
    //     String expectedErrorMessage = 'Tipo de dado inválido: ';
    //     Id AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1].Id;
    //     User commonUser = [SELECT Id FROM User WHERE Username = 'commonUser_dev@mail.com' LIMIT 1];
    //     Map<String, Object> sObjectNodeInput = new Map<String, Object>{
    //         'LXD_TrustUnlockDate__c' => new Map<String, Object>{
    //                 'value' => '08/11/2022',
    //                 'datatype' => 'invalid_datatype'
    //             },
    //         //'Status' => 'RASCUNHO',
    //         'AccountId' => AccountId
    //     };

    //     Map<String,Object> inputMap = new Map<String, Object>{
    //         'operationType' => 'insert',
    //         'objectName' => 'Contract',
    //         'sObjectNode' => sObjectNodeInput
    //     };
    //     Map<String,Object> outMap = new Map<String,Object>();
    //     Map<String, Object> options = new Map<String,Object>();

    //     Test.startTest();
    //     System.runAs(commonUser){
    //         LXD_BypassDMLPermissions.invokeMethod(METHOD_NAME, inputMap, outMap, options);
    //     }
    //     Test.stopTest();

    //     String response = (String) outMap.get('Response');
    //     System.assertEquals(false, (Boolean) outMap.get('Success'), 'Campo de Success não foi definido como falso.');
    //     System.assertEquals(true, response.contains(expectedErrorMessage), 'Mensagem de erro não contém o texto esperado.'); 
    // }
}