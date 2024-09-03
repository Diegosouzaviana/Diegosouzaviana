@IsTest
public class BookAppointmentRestTest {
    static final String POST = 'POST';
    static final String DEL = 'DELETE';
    static final String URI = '/services/apexrest';
    static final String CONTENT_TYPE = 'application/json';
    static final Integer STATUS_CODE = 200;

    @TestSetup
    static void makeData(){
        DataFactoryTest.makeData();
    }

    @IsTest
    public static void BookAppointmentRestTestCallout() {
        Id wtId = [select Id from WorkType where Name = 'Maintenance'].Id;
        Id accId = [select Id from Account where Name = 'New Account Name'].Id;

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

        Id saId = [select Id from ServiceAppointment where ParentRecordId = :wo.Id].Id;
        String body = '{"ServiceAppointment": "'+saId+'"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AppointmentBookingHttpCalloutMockImpl(STATUS_CODE, CONTENT_TYPE, body));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI+'/appointmentBookingSlot';
        req.httpMethod = POST;
        req.addHeader('Content-Type', CONTENT_TYPE);
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(body);

        AppointmentBookingSlot.GetAvailableSlot();
        Test.stopTest();
    }

    @IsTest
    public static void SetBookAppointmentRestTestCallout() {
        // Retrieve Work Type Id
        Id wtId = [select Id from WorkType where Name = 'Maintenance'].Id;
        Id accId = [select Id from Account where Name = 'New Account Name'].Id;

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

        Id saId = [select Id from ServiceAppointment where ParentRecordId = :wo.Id].Id;

        DateTime currentDate = DateTime.now();
        String dayOfWeek=currentDate.format('EEEE');
        System.debug('dayOfWeek : ' + dayOfWeek);
        if (dayOfWeek=='Friday') {
            System.debug('entrou if..'+currentDate.yearGmt()+' '+ currentDate.month()+' '+ currentDate.day());
            DateTime adjustedDate = DateTime.newInstance(currentDate.date().addDays(3), currentDate.time());
            currentDate = adjustedDate;
            System.debug('entrou if..'+currentDate.yearGmt()+' '+ currentDate.month()+' '+ currentDate.day());
        }
        DateTime startTime1 = DateTime.newInstance(currentDate.yearGmt(), currentDate.month(), currentDate.day(), 09, 0, 0);
        DateTime startTime2 = DateTime.newInstance(currentDate.yearGmt(), currentDate.month(), currentDate.day(), 10, 0, 0);
        String body = '{"serviceAppointmentId": "'+saId+'","serviceAppointment":{"schedStartTime":"'+startTime1+'","schedEndTime":"'+startTime2+'"}}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AppointmentBookingHttpCalloutMockImpl(STATUS_CODE, CONTENT_TYPE, body));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI+'/setAppointmentBookingSlot';
        req.httpMethod = POST;
        req.addHeader('Content-Type', CONTENT_TYPE);
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(body);

        bookingAndSchedulingClass.setAppointmentSlots();
        Test.stopTest();
    }

    @IsTest
    public static void DeleteBookAppointmentRestTestCallout() {
        // Retrieve Work Type Id
        Id wtId = [select Id from WorkType where Name = 'Maintenance'].Id;
        Id accId = [select Id from Account where Name = 'New Account Name'].Id;

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

        ServiceAppointment sa = [select Id, Status from ServiceAppointment where ParentRecordId = :wo.Id];
        // Id saId = sa.Id;
        // sa.Status = 'Agendado';
        // update sa;
        String body = '{"ServiceAppointmentID": "'+sa.Id+'","ReasonCancellation":"Acesso normalizado"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AppointmentBookingHttpCalloutMockImpl(STATUS_CODE, CONTENT_TYPE, body));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI+'/setAppointmentBookingSlot';
        req.httpMethod = DEL;
        req.addHeader('Content-Type', CONTENT_TYPE);
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(body);

        bookingAndSchedulingClass.deleteSAppointment();
        Test.stopTest();
    }

    

    @IsTest
    public static void SetBookAppointmentRestTestCallout2() {
        // Retrieve Work Type Id
        Id wtId = [select Id from WorkType where Name = 'Maintenance'].Id;
        Id accId = [select Id from Account where Name = 'New Account Name'].Id;

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

        Id saId = [select Id from ServiceAppointment where ParentRecordId = :wo.Id].Id;

        DateTime currentDate = DateTime.now();
        String dayOfWeek=currentDate.format('EEEE');
        System.debug('dayOfWeek : ' + dayOfWeek);
        if (dayOfWeek=='Friday') {
            System.debug('entrou if..'+currentDate.yearGmt()+' '+ currentDate.month()+' '+ currentDate.day());
            DateTime adjustedDate = DateTime.newInstance(currentDate.date().addDays(3), currentDate.time());
            currentDate = adjustedDate;
            System.debug('entrou if..'+currentDate.yearGmt()+' '+ currentDate.month()+' '+ currentDate.day());
        }
        DateTime startTime1 = DateTime.newInstance(currentDate.yearGmt(), currentDate.month(), currentDate.day(), 22, 0, 0);
        DateTime startTime2 = DateTime.newInstance(currentDate.yearGmt(), currentDate.month(), currentDate.day(), 23, 0, 0);
        String body = '{"serviceAppointmentId": "'+saId+'","serviceAppointment":{"schedStartTime":"'+startTime1+'","schedEndTime":"'+startTime2+'"}}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AppointmentBookingHttpCalloutMockImpl(STATUS_CODE, CONTENT_TYPE, body));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI+'/setAppointmentBookingSlot';
        req.httpMethod = POST;
        req.addHeader('Content-Type', CONTENT_TYPE);
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(body);

        bookingAndSchedulingClass.setAppointmentSlots();
        Test.stopTest();
    }

    
    @IsTest
    public static void SetBookAppointmentRestTestCallout3() {
        // Retrieve Work Type Id
        Id wtId = [select Id from WorkType where Name = 'Maintenance'].Id;
        Id accId = [select Id from Account where Name = 'New Account Name'].Id;

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

        Id saId = [select Id from ServiceAppointment where ParentRecordId = :wo.Id].Id;

        DateTime currentDate = DateTime.now();
        String dayOfWeek=currentDate.format('EEEE');
        System.debug('dayOfWeek : ' + dayOfWeek);
        if (dayOfWeek=='Friday') {
            System.debug('entrou if..'+currentDate.yearGmt()+' '+ currentDate.month()+' '+ currentDate.day());
            DateTime adjustedDate = DateTime.newInstance(currentDate.date().addDays(3), currentDate.time());
            currentDate = adjustedDate;
            System.debug('entrou if..'+currentDate.yearGmt()+' '+ currentDate.month()+' '+ currentDate.day());
        }
        DateTime startTime1 = DateTime.newInstance(currentDate.yearGmt(), currentDate.month(), currentDate.day(), 09, 0, 0);
        DateTime startTime2 = DateTime.newInstance(currentDate.yearGmt(), currentDate.month(), currentDate.day(), 10, 0, 0);
        String body = '{"serviceAppointmentId": "'+saId+'","rescheduleReason":"Valor Aleatório pra quebrar","serviceAppointment":{"schedStartTime":"'+startTime1+'","schedEndTime":"'+startTime2+'"}}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AppointmentBookingHttpCalloutMockImpl(STATUS_CODE, CONTENT_TYPE, body));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = URI+'/setAppointmentBookingSlot';
        req.httpMethod = POST;
        req.addHeader('Content-Type', CONTENT_TYPE);
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(body);

        bookingAndSchedulingClass.setAppointmentSlots();
        Test.stopTest();
    }
}