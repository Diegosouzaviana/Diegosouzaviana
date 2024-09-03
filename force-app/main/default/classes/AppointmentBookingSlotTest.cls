@IsTest
public class AppointmentBookingSlotTest {
    @TestSetup
    static void makeData(){
        DataFactoryTest.makeData();
        DataFactoryTest.DeleteBookAppointment();
    }

/*
    @isTest
    static void testInvokeMethod() {
        // Crie instâncias dos objetos necessários
        AppointmentBookingSlotClass service = new AppointmentBookingSlotClass();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = null; // Você pode adicionar opções, se necessário

        ServiceAppointment IdServiceAppointment = [SELECT Id FROM ServiceAppointment LIMIT 1];
        
        // Defina os valores dos parâmetros de entrada
        inputMap.put('methodName', 'GetAvailableSlot');
        inputMap.put('ServiceAppointment', (Object)IdServiceAppointment);

        // Chame o método a ser testado
        Object result = service.invokeMethod('GetAvailableSlot', inputMap, outMap, options);

        // Realize as verificações com base no resultado esperado
        System.assertEquals('Expected result', result, 'Test failed');
        // Adicione mais verificações conforme necessário para outros cenários

        // Lembre-se de incluir cenários de teste para 'SetAppointmentSlots' e 'DeleteSAppointment'
    }
    */

    @IsTest
    public static void InvokedMethodTest_1() {
        Map<String, Object> inputMap = new Map<String, Object>();

        AppointmentBookingSlotClass service = new AppointmentBookingSlotClass();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = null;
        ServiceAppointment IdServiceAppointment = [SELECT Id FROM ServiceAppointment LIMIT 1];
        System.debug('id-> '+IdServiceAppointment);
        inputMap.put('methodName', 'GetAvailableSlot');
        inputMap.put('ServiceAppointment', (Object)IdServiceAppointment.Id);

        Test.startTest();
        Object result = service.invokeMethod('GetAvailableSlot', inputMap, outMap, options);
        Test.stopTest();
    }
/*
    @IsTest
    public static void InvokeMethodTest_2() {
        try {
            Map<String, Object> inputMap = new Map<String, Object>();
            AppointmentBookingSlotClass service = new AppointmentBookingSlotClass();
            Map<String, Object> outMap = new Map<String, Object>();
            Map<String, Object> options = null;
            ServiceAppointment ServiceAppointment = [SELECT Id FROM ServiceAppointment LIMIT 1];
            DateTime currentDate = DateTime.now();
            DateTime startTime1 = DateTime.newInstance(currentDate.yearGmt(), currentDate.month(), currentDate.day(), 09, 0, 0);
            DateTime startTime2 = DateTime.newInstance(currentDate.yearGmt(), currentDate.month(), currentDate.day(), 13, 0, 0);
            String body = '{"serviceAppointmentId": "'+ServiceAppointment.Id+'","serviceAppointment":{"schedStartTime":"'+startTime1+'","schedEndTime":"'+startTime2+'"}}';
            //String body = '{"serviceAppointmentId":"'+ServiceAppointment.Id+'","rescheduleReason":"teste","serviceAppointment":{"schedStartTime":"2023-12-10 08:00:00","schedEndTime":"2023-12-10 12:00:00"}}';
            //String bodyCancellation = '{"serviceAppointmentId":"'+IdServiceAppointment.Id+'","ReasonCancellation":"teste"}';
            System.debug('id-> '+ServiceAppointment.Id);
            System.debug('body-> '+JSON.serialize(body));
    
    
            inputMap.put('methodName', 'SetAppointmentSlots');
            inputMap.put('setAppointment', body);
    
            Test.startTest();
            Object result = service.invokeMethod('GetAvailableSlot', inputMap, outMap, options);
            Test.stopTest();
        } catch (Exception e) {
            System.debug('error-> '+e.getMessage()+'-'+e.getStackTraceString());
        }
    }
*/
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

        Test.startTest();
        AppointmentBookingSlotClass.GetAvailableSlot(saId);
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

        Id saId = [select Id from ServiceAppointment where ParentRecordId = :wo.Id limit 1].Id;

        DateTime currentDate = DateTime.now();
        String dayOfWeek=currentDate.format('EEEE');
        System.debug('dayOfWeek : ' + dayOfWeek);
        if (dayOfWeek=='Friday') {
            DateTime adjustedDate = DateTime.newInstance(currentDate.date().addDays(3), currentDate.time());
            currentDate = adjustedDate;
        }
        DateTime startTime1 = DateTime.newInstance(currentDate.yearGmt(), currentDate.month(), currentDate.day(), 09, 0, 0);
        DateTime startTime2 = DateTime.newInstance(currentDate.yearGmt(), currentDate.month(), currentDate.day(), 13, 0, 0);
        startTime1.addDays(1);
        startTime2.addDays(1);
        String body = '{"serviceAppointmentId": "'+saId+'","serviceAppointment":{"schedStartTime":"'+startTime1+'","schedEndTime":"'+startTime2+'"}}';
        Test.startTest();
        AppointmentBookingSlotClass.SetAppointmentSlots(body);
        Test.stopTest();
    }

    @IsTest
    public static void SetBookAppointmentRestNotOKTestCallout() {
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

        Id saId = [select Id from ServiceAppointment where ParentRecordId = :wo.Id limit 1].Id;

        DateTime currentDate = DateTime.now();
        String dayOfWeek=currentDate.format('EEEE');
        System.debug('dayOfWeek : ' + dayOfWeek);
        if (dayOfWeek=='Friday') {
            DateTime adjustedDate = DateTime.newInstance(currentDate.date().addDays(3), currentDate.time());
            currentDate = adjustedDate;
        }
        DateTime startTime1 = DateTime.newInstance(currentDate.date().addDays(-30), currentDate.time());
        DateTime startTime2 = DateTime.newInstance(currentDate.date().addDays(-10), currentDate.time());
        String body = '{"serviceAppointmentId": "'+saId+'","serviceAppointment":{"schedStartTime":"'+startTime1+'","schedEndTime":"'+startTime2+'"}}';
        Test.startTest();
        AppointmentBookingSlotClass.SetAppointmentSlots(body);
        Test.stopTest();
    }

    @IsTest
    public static void DeleteBookAppointmentRestTestCallout() {
        // Retrieve Work Type Id
        User techUser = [Select id From User Where FirstName = 'Integração' And LastName = 'Desktop' LIMIT 1];

        // Add FSL Admin Permissions if not already to running user (assuming admin)
        //System.runAs(techUser){
            WorkOrder wo = [Select id from WorkOrder where Subject = 'Test DeleteBookAppointment'];

            ServiceAppointment sa = [select Id, Status from ServiceAppointment where ParentRecordId = :wo.Id limit 1];

            String body = '{"ServiceAppointmentID": "'+sa.Id+'","ReasonCancellation":"Acesso normalizado"}';
            Test.startTest();
            AppointmentBookingSlotClass.DeleteSAppointment(body);
            Test.stopTest();
        //}
    }

    /*
    @IsTest
    public static void InvokeMethodTest() {
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

        String methodName = 'GetAvailableSlot';
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();

        String bodysa = '{"serviceAppointmentId": "'+saId+'"}';

        inputMap.put('methodName', 'GetAvailableSlot');
        inputMap.put('ServiceAppointment', saId);
        inputMap.put('setAppointment', bodysa);
        inputMap.put('delAppointment', bodysa);

        Test.startTest();
        AppointmentBookingSlotClass app = new AppointmentBookingSlotClass();
        app.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest();
    } */
}