@RestResource(urlMapping='/appointmentBookingSlot/*')
global with sharing class AppointmentBookingSlot {
    static List<Object> returnListNew = new List<Object>();
    public AppointmentBookingSlot(List<Object> returnList){
        System.debug('->returningList '+returnList.size());
        
        returnListNew = returnList;
    }
    
    @HttpPost
    global static void GetAvailableSlot() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        try {
            String SERVICE_NAME = 'Booking_Appointment';
            Id SchedulingPolicyId = null;
            Id OperatingHoursId = null;
            String requestBody = RestContext.request.requestBody.toString();
            
            AppointmentBookingRequestWrapper appBooking = AppointmentBookingRequestWrapper.parse(requestBody);


            List<Object> returnList = new List<Object>();
            List<IntegrationData__mdt> integMetadataList = IntegrationData__mdt.getAll().values();
            for (IntegrationData__mdt dataMdt : integMetadataList) {
                if (dataMdt.DeveloperName == SERVICE_NAME) {
                    SchedulingPolicyId = (Id) dataMdt.SchedulingPolicy__c;
                    OperatingHoursId = (Id) dataMdt.Operating_Hours__c;
                }
            }
            System.debug('ID-> '+SchedulingPolicyId+' - '+operatingHoursId);
            System.debug('SA-> '+appBooking.ServiceAppointment);
            TimeZone tz = TimeZone.getTimeZone('America/Sao_Paulo');
            FSL.AppointmentBookingService.SortResultsBy sortResults = FSL.AppointmentBookingService.SortResultsBy.Grade; //sort by grade
            ServiceAppointment sa = [SELECT Id, EarliestStartTime, DueDate, ArrivalWindowStartTime, ArrivalWindowEndTime FROM ServiceAppointment WHERE Id= :appBooking.ServiceAppointment];



            
            if(Test.isRunningTest()) {
                SchedulingPolicyId = [SELECT Id FROM FSL__Scheduling_Policy__c LIMIT 1].Id;
                OperatingHoursId   = [SELECT Id FROM OperatingHours LIMIT 1].Id;
            }else{
                SchedulingPolicyId = [SELECT Id FROM FSL__Scheduling_Policy__c WHERE Id=:SchedulingPolicyId].Id;
                OperatingHoursId   = [SELECT Id FROM OperatingHours WHERE Id=:OperatingHoursId].Id;
            }

            List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.GetSlots(sa.Id, SchedulingPolicyId, OperatingHoursId, tz, false);//comentar 
            
            if (slots.size() > 0) {
                
                for(integer i=0; i<slots.size(); i++){  
                    ResponseWrapper.GetBookingSlot bsRes = new ResponseWrapper.GetBookingSlot(i, slots[i].Interval.Start, slots[i].Interval.Finish, slots[i].Grade);
                    returnList.add(bsRes);
                }
            }else{
                ResponseWrapper.BookingSlot bsRes = new ResponseWrapper.BookingSlot(sa.Id, 'ERRO', 'Não encontrado slots disponíveis');
                returnList.add(bsRes);
            }
            
            
            res.statusCode=201;
            res.responseBody=Blob.valueOf(Json.serialize(returnList));

        } catch (Exception e) {
            System.debug('Error-> '+e.getStackTraceString() + ' - '+e.getMessage());
            res.statusCode=500;
            res.responseBody=Blob.valueOf(e.getMessage());
        }
    }
}