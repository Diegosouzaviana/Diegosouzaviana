@isTest
global with sharing class LXD_CLS_CallingIpToEinsteinBot_TST{
    @TestSetup
    static void makeData(){
        Id sysAdminProfileId = [SELECT Id, Name FROM Profile WHERE NAME = 'System Administrator' LIMIT 1].Id;

        UserRole userRole = new UserRole(Name= 'Test Role'); 
        insert userRole;

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
        insert new List<User>{adminUser};

        System.runAs(adminUser){
            Account lAcc = new Account(
                Name = 'test',
                LXD_CPF__c = '77495611618',
                LXD_Email__c = 'test@test.com',
                LXD_Mobile__c = '15999999999',
                Phone = '1599999999'
            );
            insert lAcc;
        }
    }
    
    static testMethod void TestCallingIpToEinsteinBot(){
        List<LXD_CLS_CallingIpToEinsteinBot.ClientOutput> lClientOutputLst = new List<LXD_CLS_CallingIpToEinsteinBot.ClientOutput>();
        
        LXD_CLS_CallingIpToEinsteinBot.ClientInput testeCli = new LXD_CLS_CallingIpToEinsteinBot.ClientInput();
        testeCli.aClientCPF = '77495611618';
        List<LXD_CLS_CallingIpToEinsteinBot.ClientInput> ltesteList = new List<LXD_CLS_CallingIpToEinsteinBot.ClientInput>();
        ltesteList.Add(testeCli);
        lClientOutputLst = LXD_CLS_CallingIpToEinsteinBot.invokeMethod(ltesteList);
        
        system.debug('lClientOutputLst: '+lClientOutputLst);
    }
}