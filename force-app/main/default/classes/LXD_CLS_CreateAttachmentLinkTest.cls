/*
*   @author: Misael Ribas
*   @since: yyyy/mm/dd
*   @className: LXD_CLS_CreateAttachmentLinkTest
*   @description: <fill the description>
*
*   =================== FIX LOG ========================
*   2023/01/20            Wesley Prado      Fix: make returnLinkBillNoCommunityTest run as Minimum Access user 🐛
*   2023/01/20            Wesley Prado      Fix: duplicate usernames being created 🐛
*   2023/01/19            Misael Ribas      Class change to use ContentVersion instead of Attachment
*   2022/12/30            Misael Ribas      Class restructuring
*   ====================================================
*/
@IsTest
public with sharing class LXD_CLS_CreateAttachmentLinkTest {
    private static final LXD_CLS_CreateAttachmentLink SUT = new LXD_CLS_CreateAttachmentLink();
    private static final String RT_CUSTOMER_ACCOUNT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    private static final String RT_BILLING_ACCOUNT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
    private static final Long TIMESTAMP = System.now().getTime();

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
    public static void returnLinkBillTest(){
        Map<String, Object> inputs = new Map<String, Object>{
            'billCode' => '123456'
        };
        Map<String, Object> output = new Map<String, Object>();

        Test.startTest();
        //Troquei o usuario 'Com User CALT%' para o usuario 'Devops Devops' para rodar a teste.
        List<User> lUserList = [SELECT Id FROM User WHERE Name LIKE 'Devops Devops' LIMIT 1];
        System.assertEquals(false, lUserList.isEmpty(),'No community user was created');
        System.debug(lUserList);
        User commUser = lUserList[0];
       
        System.runAs(commUser){
            SUT.invokeMethod('returnLinkBill', inputs, output, new Map<String, Object>());
        }
        Test.stopTest();

        System.debug('output: ' + output);

        System.assertEquals(200, output.get('statusCode'), 'Should return statusCode 200');
        System.assertEquals(false, String.isBlank((String) output.get('result')), 'Should return a download pdf link');
    }

    @isTest
    public static void returnLinkBillNoCommunityTest(){
        Test.startTest();
        User minimumUser = [SELECT Id FROM User WHERE LastName = 'Minimum CAL' LIMIT 1];
        List<Account> lAccList = [SELECT Id FROM Account WHERE Name LIKE 'Bil Account CALT%' LIMIT 1];

        System.assertEquals(false, lAccList.isEmpty(),'No billing account was created');

        Account billAcc = lAccList[0];
        Map<String, Object> inputs = new Map<String, Object>{
            'billCode' => '123456',
            'accountId' => billAcc.Id
        };
        Map<String, Object> output = new Map<String, Object>();

        System.runAs(minimumUser){
            SUT.invokeMethod('returnLinkBill', inputs, output, new Map<String, Object>());
        }
        
        Test.stopTest();

        System.debug('output: ' + output);

        System.assertEquals(200, output.get('statusCode'), 'Should return statusCode 200');
        System.assertEquals(false, String.isBlank((String) output.get('result')), 'Should return a download pdf link');
    }
}