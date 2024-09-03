@IsTest
public class ServiceResourceControllerTest {

    @TestSetup
    static void makeData(){
        DataFactoryTest.makeData();
    }
    @IsTest
    public static void checkDuplicateCPF() {
        try {
            Test.startTest();
            User tech = [SELECT Id, FirstName,LastName FROM User WHERE  Alias = 'tsttech1'];
            User adm = [SELECT Id, FirstName,LastName FROM User WHERE  Alias = 'sadmin'];
            
            ServiceResource sr = [SELECT Name, RelatedRecordId, LocationId FROM ServiceResource LIMIT 1];
            sr.RelatedRecordId=tech.Id;
            sr.CPF__c  = '54954252601';
            update sr;
    
            ServiceResource sr2 = new ServiceResource(
                Name = tech.FirstName + ' ' + tech.LastName,
                isActive = true,
                ResourceType = 'T',
                RelatedRecordId = adm.Id,
                CPF__c  = '54954252601'
            );
            
            insert sr2;
            Test.stopTest();
        } catch (Exception e) {
            System.debug('message validation: '+ e.getMessage() + ' - ' +e.getStackTraceString());
        }
    }
    @IsTest
    public static void checkDuplicateCPF_Profile() {
        try {
            Test.startTest();
            Id adminProfileId = [select Id from Profile where Name = 'Administrador do sistema' or Name = 'System Administrator'].Id;
            User adminUser2 = new User(
                ProfileId = adminProfileId,
                FirstName = 'System 1',
                LastName = 'Administrator 2',
                UserName = System.now().getTime() + '@sse.demo.com.int',
                Alias = 'tadmin',
                Email = 'swetha@sse.demo.int',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'nl_NL',
                TimeZoneSidKey = UserInfo.getTimeZone().getID(),
                UserPermissionsSupportUser = true
            );
            insert adminUser2;
            User tech = [SELECT Id, FirstName,LastName FROM User WHERE  Alias = 'tsttech1'];
            User adm = [SELECT Id, ProfileId, FirstName,LastName FROM User WHERE Alias = 'sadmin'];
            String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
            Profile p = [SELECT CreatedBy.Name, Name, Id FROM Profile WHERE Name='Planejamento'];
            adm.ProfileId = p.Id;
            update adm;

            System.runAs(adm) {
                ServiceResource sr3 = new ServiceResource(
                    Name = tech.FirstName + ' ' + tech.LastName,
                    isActive = false,
                    ResourceType = 'T',
                    RelatedRecordId = adm.Id,
                    CPF__c  = '54954252601'
                );
                insert sr3;
                sr3.isActive = true;
                update sr3;
                ServiceResource sr2 = new ServiceResource(
                    Name = tech.FirstName + ' ' + tech.LastName,
                    isActive = true,
                    ResourceType = 'T',
                    RelatedRecordId = adminUser2.Id,
                    CPF__c  = '54954252601'
                );
                insert sr2;
                ServiceResource sr1 = new ServiceResource(
                    Name = tech.FirstName + ' ' + tech.LastName,
                    isActive = true,
                    ResourceType = 'T',
                    RelatedRecordId = tech.Id,
                    CPF__c  = '54954252601'
                );
                insert sr1;
            }
            Test.stopTest();
        } catch (Exception e) {
            System.debug('message validation2: '+ e.getMessage() + ' - ' + e.getStackTraceString());
        }
    }

    @IsTest
    private static void changeIsActiveTest() {
        Test.startTest();
        ServiceResourceController src = new ServiceResourceController();
        User tech = [SELECT Id, FirstName,LastName FROM User WHERE  Alias = 'tsttech1'];
        User adm = [SELECT Id, ProfileId, FirstName,LastName FROM User WHERE Alias = 'sadmin'];
        ServiceResource sr2 = new ServiceResource(
            Name = tech.FirstName + ' ' + tech.LastName,
            isActive = false,
            ResourceType = 'T',
            RelatedRecordId = adm.Id,
            CPF__c  = '54954252601'
        );
        insert sr2;
        sr2.isActive = true;
        update sr2;
        Test.stopTest();
    }

   @IsTest
   public static void checkInvalidCPF() {
    try {
        Test.startTest();
        User tech = [SELECT Id, FirstName,LastName FROM User WHERE  Alias = 'tsttech1'];
        User adm = [SELECT Id, FirstName,LastName FROM User WHERE  Alias = 'sadmin'];
        
        List<ServiceResource> srList = new List<ServiceResource>();
        ServiceResource sr = [SELECT Name, RelatedRecordId, LocationId FROM ServiceResource LIMIT 1];
        sr.RelatedRecordId=tech.Id;
        sr.CPF__c  = '00000000000';
        update sr;
        Test.stopTest();
    } catch (Exception e) {
        System.debug('message validation: '+e.getMessage() + ' - ' +e.getStackTraceString());
    }
   }
}