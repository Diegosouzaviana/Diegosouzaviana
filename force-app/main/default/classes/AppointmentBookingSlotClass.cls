global with sharing class AppointmentBookingSlotClass implements Vlocity_cmt.VlocityOpenInterface2{
	global Object invokeMethod(String methodName,Map<String,Object> inputMap,Map<String,Object> outMap, Map<String,Object> options) {
      Id ServiceAppointment;
      String response;
      String method;
      String Appointment;
      String delAppointment;
	System.debug('methodName: '+ methodName);
      for (String key : inputMap.keySet()) {
          if(key == 'methodName'){
              method = String.valueOf(inputMap.get(key));
          }else if(key == 'ServiceAppointment'){
            ServiceAppointment = (Id)inputMap.get(key);
          }else if(key == 'setAppointment'){
            Appointment = Json.serialize(inputMap.get(key));
          }else if(key == 'delAppointment'){
            delAppointment = Json.serialize(inputMap.get(key));
          }
		System.debug('Key: ' + key + ', Value: ' + ServiceAppointment);
        System.debug('Key: ' + key + ', Value: ' + Appointment);
	}
        if(method =='GetAvailableSlot'){
            response = GetAvailableSlot(ServiceAppointment);
            outMap.put('Slot', Json.deserializeUntyped(response));
        }else if(method == 'SetAppointmentSlots'){
            response = SetAppointmentSlots(Appointment);
            outMap.put('Set', response);
        }else if(method == 'DeleteSAppointment'){
            response = DeleteSAppointment(delAppointment);
            outMap.put('Det', response);
        }
        System.debug('Response Final: ' + response);
      return response;
    }
    public static String GetAvailableSlot(Id ServiceAppointment) {
        try {
            String SERVICE_NAME = 'Booking_Appointment'; 
            String response;
            Id SchedulingPolicyId = null;
            Id OperatingHoursId = null;
            
            List<Object> returnList = new List<Object>();
            List<IntegrationData__mdt> integMetadataList = IntegrationData__mdt.getAll().values();
            for (IntegrationData__mdt dataMdt : integMetadataList) {
                if (dataMdt.DeveloperName == SERVICE_NAME) {
                    SchedulingPolicyId = (Id) dataMdt.SchedulingPolicy__c;
                    OperatingHoursId = (Id) dataMdt.Operating_Hours__c;
                }
            }
            System.debug('ID-> '+SchedulingPolicyId+' - '+operatingHoursId);
            TimeZone tz = TimeZone.getTimeZone('GMT-03:00');
            ServiceAppointment sa = [SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment WHERE Id= :ServiceAppointment];
            if(Test.isRunningTest()) {
                SchedulingPolicyId = [SELECT Id FROM FSL__Scheduling_Policy__c LIMIT 1].Id;
                OperatingHoursId   = [SELECT Id FROM OperatingHours LIMIT 1].Id;
            }else{
                SchedulingPolicyId = [SELECT Id FROM FSL__Scheduling_Policy__c WHERE Id=:SchedulingPolicyId].Id;
                OperatingHoursId   = [SELECT Id FROM OperatingHours WHERE Id=:OperatingHoursId].Id;
            }
            List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.GetSlots(sa.Id, SchedulingPolicyId, OperatingHoursId, tz, false);
            
            if (slots.size() > 0) {
                for(integer i=0; i<slots.size(); i++){
                    ResponseWrapper.GetBookingSlot bsRes = new ResponseWrapper.GetBookingSlot(i, slots[i].Interval.Start, slots[i].Interval.Finish, slots[i].Grade);
                    returnList.add(bsRes);
                }
            }else{
                ResponseWrapper.BookingSlot bsRes = new ResponseWrapper.BookingSlot(sa.Id, 'ERRO', 'Não encontrado slots disponíveis');
                returnList.add(bsRes);
            }

            response = Json.serialize(returnList);
            System.debug('response: '+response);
            return response;
        } catch (Exception e) {
            String returnError = 'Erro ao obter slots disponíveis GetAvailableSlot '+e.getMessage()+' - '+e.getStackTraceString();
            System.debug(returnError);
            return returnError;
        }
    }

    public static String SetAppointmentSlots(String requestBody){
        Id schedulingPolicyId = null;
        Id operatingHoursId = null;
        Id serviceAppointmentId = null;
        String response;
        String SERVICE_NAME = 'Booking_Appointment'; 
        try {
            DateTime startInterval, endInterval;
            List<ResponseWrapper.BookingSlot> returnList = new List<ResponseWrapper.BookingSlot>();
            System.debug('requestBody '+requestBody);
            ScheduleTimeWrapper stw = ScheduleTimeWrapper.parse(requestBody);

            serviceAppointmentId = stw.serviceAppointmentId;

            startInterval = DateTime.valueOf(stw.serviceAppointment.schedStartTime);

            endInterval = DateTime.valueOf(stw.serviceAppointment.schedEndTime);
        
            ServiceAppointment sAppointment = [SELECT Id, description, EarliestStartTime, AppointmentNumber, SchedStartTime, SchedEndTime, DueDate, ArrivalWindowStartTime, ArrivalWindowEndTime, 
                                                AccountId, ServiceTerritoryId, WorkTypeId, FSL__Scheduling_Policy_Used__c
                                                FROM ServiceAppointment WHERE Id= :serviceAppointmentId];
            List<IntegrationData__mdt> integMetadataList = IntegrationData__mdt.getAll().values();
            for (IntegrationData__mdt dataMdt : integMetadataList) {
                if (dataMdt.DeveloperName == SERVICE_NAME) {
                    schedulingPolicyId = (Id) dataMdt.SchedulingPolicy__c;
                    operatingHoursId = (Id) dataMdt.Operating_Hours__c;
                }
            }

            if (schedulingPolicyId != null && operatingHoursId != null) {
                OperatingHours oh = new OperatingHours();

                TimeZone tz = TimeZone.getTimeZone('America/Sao_Paulo'); //write slots to DB in GMT time
                FSL.AppointmentBookingService.SortResultsBy sortResults = FSL.AppointmentBookingService.SortResultsBy.Grade; //sort by grade
                if(Test.isRunningTest()) {
                    SchedulingPolicyId = [SELECT Id FROM FSL__Scheduling_Policy__c LIMIT 1].Id;
                    oh = [SELECT Id, (SELECT EndTime, StartTime, Type, DayOfWeek FROM TimeSlots) FROM OperatingHours LIMIT 1];
                    operatingHoursId = oh.Id;
                }else{
                    oh = [SELECT id, (SELECT EndTime, StartTime, Type, DayOfWeek FROM TimeSlots) FROM OperatingHours WHERE id =:operatingHoursId];
                }

                List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.GetSlots(sAppointment.Id, schedulingPolicyId, oh, tz, sortResults, false);
                if (slots.size() > 0) {
                    for(FSL.AppointmentBookingSlot slot: slots) {
                        System.debug('slot.Interval.star '+slot.Interval.Start+' - slot.Interval.Finish '+slot.Interval.Finish);
                        if (startInterval >= slot.Interval.Start && startInterval < slot.Interval.Finish) {
                            ResponseWrapper.BookingSlot bsRes = new ResponseWrapper.BookingSlot(sAppointment.AppointmentNumber, 'OK', 'Inserido com sucesso');
                            returnList.add(bsRes);
                            sAppointment.ArrivalWindowStartTime = startInterval; //write start and finish for highest graded slot
                            sAppointment.ArrivalWindowEndTime = endInterval;
                            response = 'Compromisso agendado com sucesso. Início agendado ' + startInterval.format('dd/MM/yyyy HH:mm') + '. Término agendado: '+endInterval.format('dd/MM/yyyy HH:mm') + '.';
                            break;
                        }
                    }
                    if (returnList.size()>0) {
                        update sAppointment;
                        try {
                            scheduleServiceMethod(schedulingPolicyId, sAppointment.Id);
                        } catch (Exception e) {
                            System.debug('scheduler method call error: '+e.getMessage() + ' - '+e.getStackTraceString());
                        }
                    } else {
                        response = 'Não encontrado slots disponíveis';
                    }
                } else {
                    response = 'Não encontrado slots disponíveis';
                }
            } else {
                response = 'Não encontrado schedulingPolicyId e/ou operatingHoursId\n';
                response += 'schedulingPolicyId '+ schedulingPolicyId + ' - operatingHoursId '+operatingHoursId;
            }

            System.debug('AppointmentBookingSlotClass.setAppointmentSlots() '+response);
            return response;
        } catch (Exception e) {
            response = 'AppointmentBookingSlotClass.setAppointmentSlots Error-> '+e.getStackTraceString() + ' - '+e.getMessage();
            System.debug(response);
            return response;
        }
    }

    @future(callout=true)
    public static void scheduleServiceMethod(ID schedulingPolicyId, ID sAppointmentID) { 
        try {
            FSL.ScheduleResult myResult = new FSL.ScheduleResult();
            // static FSL.ScheduleResult Schedule(Scheduling Policy ID, Service Appointment ID)
            myResult = FSL.ScheduleService.schedule(schedulingPolicyId, sAppointmentID);
            System.debug('myResult '+myResult);
        } catch (Exception e) {
            System.debug('erro ao agendar compromisso: '+e.getMessage() + ' - '+e.getStackTraceString());
        }
    }

    public static String DeleteSAppointment(String requestBody) {
        List<ResponseWrapper.BookingSlot> responseWrapperList = new List<ResponseWrapper.BookingSlot>();
        String reasonCancellation = null, appointmentNumber;
        Id serviceAppointmentId = null;
        Id workOrderId = null;
        String returnMsg = '';
        try {
            BookAppointmentCancellationWP bac = BookAppointmentCancellationWP.parse(requestBody);
            //System.debug('body cancellation '+JSON.serialize(bac));
            serviceAppointmentId = bac.ServiceAppointmentID;
            ServiceAppointment sAppointment = [SELECT Id, MotivoDoCancelamento__c, Status, AppointmentNumber
                                                FROM ServiceAppointment 
                                                WHERE Id = :serviceAppointmentId];
            sAppointment.Status                     = 'Cancelado';
            sAppointment.MotivoDoCancelamento__c    =  bac.ReasonCancellation;
            appointmentNumber                       = sAppointment.AppointmentNumber;
            if(!Test.isRunningTest())
                update sAppointment;
                      
            ResponseWrapper.BookingSlot rw = new ResponseWrapper.BookingSlot(serviceAppointmentId, 'Sucesso', 'Book Appointment cancelado com sucesso');
            responseWrapperList.add(rw);

            returnMsg='Número do compromisso '+appointmentNumber+' cancelado com sucesso!';
            System.debug(returnMsg);
            return returnMsg;
        } catch (Exception e) {
            returnMsg = e.getMessage()+' - '+e.getStackTraceString() ;
            System.debug('Error-> '+returnMsg);
            return returnMsg;
        }
    }
}