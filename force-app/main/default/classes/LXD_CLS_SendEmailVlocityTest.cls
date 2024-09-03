/*
*   @author: Juan Sequeira
*   @since: yyyy/mm/dd
*   @className: LXD_CLS_SendEmailVlocityTest
*   @description: <fill the description>
*/
@IsTest
public with sharing class LXD_CLS_SendEmailVlocityTest {
    private static final LXD_CLS_SendEmailVlocity SUT = new LXD_CLS_SendEmailVlocity();

     @TestSetup
    static void makeData(){
        User adminUser = LXD_CLS_SObjectFactory.CreateUserADM();
        User minimumUser = LXD_CLS_SObjectFactory.CreateUserMinimum('Minimum CAL');
        insert new List<User>{adminUser, minimumUser};

        System.runAs(adminUser){
            Account customerAccount = LXD_CLS_SObjectFactory.createAccount(
                'Com User CALT', 
                '77490557038', 
                LXD_CLS_SObjectFactory.AccountRTEnum.CUSTOMER
            );
            Account billingAccount = LXD_CLS_SObjectFactory.createAccount(
                'Bil Account CALT', 
                '72567095012', 
                LXD_CLS_SObjectFactory.AccountRTEnum.BILLING
            );
    
            insert new List<Account>{customerAccount, billingAccount};
        }

    }
    
    @IsTest
    public static void returnSendEmailTest(){
        Map<String, Object> inputs = new Map<String, Object>{
            'lBoletoCode' => '123456',
            'lCpf' => '123452346',
            'lEmail' => 'nose@gmail.com'
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        List<User> lUserList = [SELECT Id FROM User WHERE Name LIKE 'Devops Devops' LIMIT 1];
        System.assertEquals(false, lUserList.isEmpty(),'No community user was created');
        User commUser = lUserList[0];
       
        System.runAs(commUser){
            SUT.invokeMethod('returnSendEmail', inputs, output, new Map<String, Object>());
        }
        Test.stopTest();

        System.assertEquals(200, output.get('statusCode'), 'Should return statusCode 200');
        System.assertEquals(false, String.isBlank(String.valueOf( output.get('result'))), 'Should send a pdf email');
    }
   
     @IsTest
    public static void returnSendEmailMethodErrorTest(){
        Map<String, Object> inputs = new Map<String, Object>{
            'lBoletoCode' => '123456',
            'lCpf' => '123452346',
            'lEmail' => 'nose@gmail.com'
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        //Troquei o usuario 'Com User CALT%' para o usuario 'Devops Devops' para rodar a teste.
        List<User> lUserList = [SELECT Id FROM User WHERE Name LIKE 'Devops Devops' LIMIT 1];
        System.assertEquals(false, lUserList.isEmpty(),'No community user was created');
        User commUser = lUserList[0];
       
        System.runAs(commUser){
            SUT.invokeMethod('returnSendEmail123', inputs, output, new Map<String, Object>());
        }
        Test.stopTest();

        System.assertEquals(null, output.get('statusCode'), 'Should don´t return statusCode 200');
        System.assertEquals(true, String.isBlank((String) output.get('result')), 'Should don´t send a pdf email');
    }
}