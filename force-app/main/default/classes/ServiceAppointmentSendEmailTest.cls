@IsTest
public class ServiceAppointmentSendEmailTest {
    static Id emailTemplateID = null;
    @TestSetup
    static void makeData(){
        DataFactoryTest.makeData();
        
        System.debug('makeData');
        insert new Contact(
        	FirstName='First Name',
            LastName='LastName',
            Email='invalidEmail@desktop.com.br'
        );

        
    }

    @future
    static void getEmailTemplateID(){
        EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'test');
        insert e;
        emailTemplateID = e.ID;
    }

    @IsTest
    static void sendEmail() {
        Id wtId = [Select Id from WorkType where Name = 'Maintenance'].Id;
        Id accId = [Select Id from Account where Name = 'New Account Name'].Id;
        Contact ct = [select Name, Id from Contact LIMIT 1];
        List<List<String>> sAppList = new List<List<String>>();
        List<String> sAList = new List<String>();
        // Create Work Order. Service Appointment is created via the Work Type
        WorkOrder wo = new WorkOrder(
            AccountId = accId,
            WorkTypeId = wtId,
            Subject = 'Test',
            Street = 'Kerkstraat 2',
            PostalCode = '3581 RD',
            City = 'Utrecht',
            Country = 'NL',
            State = 'CL'
        );
        insert wo;

        ServiceAppointment sa = [Select ArrivalWindowEndTime, NotificacaoEnviada__c, Est_Atrasado__c, ServiceTerritoryId, Status, Id From ServiceAppointment Where ParentRecordId = :wo.Id];
        System.debug('woId '+wo.Id);
        System.debug('saId '+sa.Id);
        
        // for(OrgWideEmailAddress owa : [Select id, Address from OrgWideEmailAddress Where DisplayName = 'Relatório de Serviço Desktop' limit 1]) {
            //     emailAddressId = owa.id;
            // }
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'desktop-telecom-provedor-de-internet',
            PathOnClient = 'desktop.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion_1;
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        System.debug('documents[0].Id '+documents[0].Id);
        System.debug('contact name '+ct.Name);
        System.debug('emailTemplateID '+emailTemplateID);
        Test.startTest();
        getEmailTemplateID();
        sAList.add(sa.Id);
        sAList.add(emailTemplateID); //
        sAList.add('email@example.com.br');
        sAList.add(documents[0].Id);
        sAList.add(documents[0].Title);
        sAList.add(ct.Id);
        sAList.add('Ativação');
        sAppList.add(sAList);
        
        ServiceAppointmentSendEmail.ServiceAppointmentSendEmail(sAppList);
        System.debug('final->> '+JSON.serialize(sAppList));
        System.assertEquals(documents.size(), 1);
        System.assertEquals(documents[0].Id, contentVersion_2.ContentDocumentId);
        System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion_2.Id);
        System.assertEquals(documents[0].Title, contentVersion_2.Title);
        Test.stopTest();
    }
}