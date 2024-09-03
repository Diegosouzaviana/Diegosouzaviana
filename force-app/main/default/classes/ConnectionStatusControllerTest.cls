@isTest
public with sharing class ConnectionStatusControllerTest {
    
    @testSetup
    static void setup(){
        WorkType workType = new WorkType(
            Name = 'Maintenance',
            ShouldAutoCreateSvcAppt = true,
            FSL__Due_Date_Offset__c = 60*24*7, 
            DurationType = 'Minutes',
            EstimatedDuration = 60
        );
        insert workType;

        Account acc = new Account(
            Name = 'New Account Name',
            CNPJ__c = '49401667000195',
            LXD_CPF__c = '40094880000',
            LXD_Email__c='teste@gmail.com'
        );
        insert acc;

        Contact contact = new Contact(
            FirstName = 'Test', 
            LastName = 'Test',  
            LegacyId__c = '1', 
            AccountId = acc.Id
        );
        insert contact;

        Asset commercialAsset = new Asset(
            Name = 'GloboPlay', 
            IdPlanoUsuario__c = 01, 
            AccountId = acc.Id, 
            ContactId = contact.Id
        );
        insert commercialAsset;

        WorkOrder wo = new WorkOrder(
            AccountId = acc.Id,
            WorkTypeId = workType.Id,
            Subject = 'Test',
            Street = 'Kerkstraat 2',
            PostalCode = '3581 RD',
            City = 'Utrecht',
            Country = 'NL',
            State = 'AM',
            AssetId = commercialAsset.Id
        );
        insert wo;

        ConnectionHistory__c conn = new ConnectionHistory__c();
        conn.WorkOrder__c = wo.Id;
        conn.Start__c = System.now();
        conn.End__c = System.now();
        conn.Duration__c = '';
        conn.IP__c = '187.183.187.87';
        conn.MAC__c = '4cc5.3ee6.8653';
        conn.NAS__c = '	172.28.0.112';
        conn.DownloadTraffic__c = '303959885';
        conn.UploadedTraffic__c = '15629825';
        conn.Status__c =  'Desconectado';
        insert conn;
    }

    @isTest
    static void testMethod_getHistory(){
        String workOrderId = [Select Id From WorkOrder Limit 1].Id;
        Test.startTest();
        List<ConnectionHistory__c> response = ConnectionStatusController.getHistory(workOrderId);        
        System.Assert.areNotEqual(null, response);
        System.Assert.areEqual(1, response.size());
        Test.stopTest();
        
    }

    @isTest
    static void testMethod_getConnections(){
        String workOrderId = [Select Id From WorkOrder Limit 1].Id;
        Test.setMock(HttpCalloutMock.class, new ConnectionHistoryHttpCalloutMockImpl(200));    
        Test.startTest();
        ConnectionStatusController.ConnectionResponse response = ConnectionStatusController.getConnections(workOrderId);
        Test.stopTest();
        System.Assert.areNotEqual(null, response);
        System.Assert.areEqual(true, response.success);
    }

    @isTest
    static void testMethod_getConnections_error(){
        String workOrderId = [Select Id From WorkOrder Limit 1].Id;
        Test.setMock(HttpCalloutMock.class, new ConnectionHistoryHttpCalloutMockImpl(500));    
        Test.startTest();
        ConnectionStatusController.ConnectionResponse response = ConnectionStatusController.getConnections(workOrderId);
        Test.stopTest();
        System.Assert.areNotEqual(null, response);
        System.Assert.areNotEqual(true, response.success);
    }

    @isTest
    static void testMethod_consultConnections(){
        String workOrderId = [Select Id From WorkOrder Limit 1].Id;
        Test.setMock(HttpCalloutMock.class, new ConnectionHistoryHttpCalloutMockImpl(200));    
        Test.startTest();
        ConnectionStatusController.consultConnections(workOrderId);
        Test.stopTest();
        System.Assert.areEqual(5,[Select COUNT() From ConnectionHistory__c Where WorkOrder__c = :workOrderId]);    
    }

    @isTest
    static void testMethod_consultConnections_error(){
        String workOrderId = [Select Id From WorkOrder Limit 1].Id;
        Test.setMock(HttpCalloutMock.class, new ConnectionHistoryHttpCalloutMockImpl(500));    
        Test.startTest();
        ConnectionStatusController.consultConnections(workOrderId);
        Test.stopTest();
        System.Assert.areEqual(1,[Select COUNT() From IntegrationLog__c ]);   
        
    }

    class ConnectionHistoryHttpCalloutMockImpl implements HttpCalloutMock {
        Integer status = 200;
        String contentType = 'application/json';
        String body = '';
    
        public ConnectionHistoryHttpCalloutMockImpl(Integer status) {
            this.status = status;
        }
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            String responseJson = this.body;
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndPoint().contains('current-connection')) {
                res.setStatusCode(this.status);
                if (this.status==200)
                    res.setBody('{"ipAddress":"187.94.170.38","macAddress":"4cc5.3ee6.8653",'+
                                '"nasAddress":"172.28.0.112","startTime":"'+String.valueOf(System.now())+'",'+
                                '"stopTime":null,"terminateCause":null,"received":134572088940,'+
                                '"sent":8640364420,"logs":[{"ipAddress":"189.124.72.128","macAddress":'+
                                '"4cc5.3ee6.8653","nasAddress":"172.28.0.112","startTime":"'+
                                String.valueOf(System.now())+'","stopTime":"'+
                                String.valueOf(System.now())+'","terminateCause":"Lost-Carrier",'+
                                '"received":303959885,"sent":15629825},{"ipAddress":"187.94.183.92",'+
                                '"macAddress":"4cc5.3ee6.8653","nasAddress":"172.28.0.112","startTime":"'+
                                String.valueOf(System.now())+'","stopTime":"2023-11-10 13:09:01",'+
                                '"terminateCause":"NAS-Request","received":96188112740,"sent":4981585772},'+
                                '{"ipAddress":"100.81.92.71","macAddress":"4cc5.3ee6.8653","nasAddress":'+
                                '"172.28.0.112","startTime":"'+String.valueOf(System.now())+'",'+
                                '"stopTime":"'+String.valueOf(System.now())+'","terminateCause":"NAS-Request",'+
                                '"received":89856406213,"sent":2913177717},{"ipAddress":"100.81.241.122",'+
                                '"macAddress":"4cc5.3ee6.8653","nasAddress":"172.28.0.112","startTime":"'+
                                String.valueOf(System.now())+'","stopTime":"'+String.valueOf(System.now())+'",'+
                                '"terminateCause":"Admin-Split-End","received":6435293103,"sent":432640918}]}')
                    ;
                else 
                    res.setBody('{"message":"test"}');
            } else {
                res.setBody('{"access_token":"123","expires_in":5000,"refresh_expires_in":3000,"token_type":""}');
                res.setStatusCode(200);
            }
            return res;
        }
    }

}