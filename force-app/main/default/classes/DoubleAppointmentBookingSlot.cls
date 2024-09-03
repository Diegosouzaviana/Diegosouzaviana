global with sharing class DoubleAppointmentBookingSlot {
    
    @InvocableMethod(label = 'Get Slot')
    global static List<String> getSecondSlot(List<Requests> req){
        
        RestResponse res = new RestResponse();
        //res.addHeader('Content-Type', 'application/json');

        TimeZone tz = TimeZone.getTimeZone('GMT-03:00');
        List<Object> returnList = new List<Object>();
        List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.GetSlots(req[0].ServiceAppointmentId, req[0].SchedulingPolicyId, req[0].OperatingHoursId, tz, false);
        
        for(integer i=0; i<slots.size(); i++){  
            ResponseWrapper.GetBookingSlot bsRes = new ResponseWrapper.GetBookingSlot(i, slots[i].Interval.Start, slots[i].Interval.Finish, slots[i].Grade);
            returnList.add(bsRes);
        }
        
        //res.statusCode=201;
        res.responseBody=Blob.valueOf(Json.serialize(returnList));


        List<String> resultsList = new List<String>();
        resultsList.add(Json.serialize(res));
        return resultsList;
        

    }
    global class Requests {
        @InvocableVariable
        global Id ServiceAppointmentId;
        
        @InvocableVariable
        global Id OperatingHoursId;  

        @InvocableVariable
        global Id SchedulingPolicyId;         
    }
}