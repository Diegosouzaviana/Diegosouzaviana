@RestResource(urlMapping='/setAppointmentBookingSlot/*')
global with sharing class bookingAndSchedulingClass {
    static final String SERVICE_NAME = 'Booking_Appointment';

    @HttpPost
    global static void setAppointmentSlots() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Id schedulingPolicyId = null;
        Id operatingHoursId = null;
        Id serviceAppointmentId = null;
        String rescheduleReason = null, AppointmentNumber = null;
        List<ResponseWrapper.BookingSlot> returnList = new List<ResponseWrapper.BookingSlot>();
        try {
            String requestBody = RestContext.request.requestBody.toString();
            DateTime startInterval, endInterval;
            System.debug('requestBody '+requestBody);
            ScheduleTimeWrapper stw = ScheduleTimeWrapper.parse(requestBody);
            System.debug('slots-> '+JSON.serialize(stw));
            serviceAppointmentId = stw.serviceAppointmentId;
            System.debug('->> '+stw.serviceAppointment.schedStartTime);
            startInterval = getDateTime(stw.serviceAppointment.schedStartTime);
            System.debug('->> '+stw.serviceAppointment.schedEndTime);
            endInterval = getDateTime(stw.serviceAppointment.schedEndTime);
            //Datetime local = Utility.getLocalDateTime(Datetime.Now());
            rescheduleReason = stw.rescheduleReason;
            System.debug('startInterval->> '+startInterval);
            System.debug('endInterval->> '+endInterval);
            ServiceAppointment sAppointment = [SELECT Id, description, EarliestStartTime, AppointmentNumber, SchedStartTime, SchedEndTime, DueDate, ArrivalWindowStartTime, ArrivalWindowEndTime, 
                                                AccountId, ServiceTerritoryId, WorkTypeId, FSL__Scheduling_Policy_Used__c, Reschedule_Reason_SA__c
                                                FROM ServiceAppointment WHERE Id= :serviceAppointmentId];
            List<IntegrationData__mdt> integMetadataList = IntegrationData__mdt.getAll().values();
            for (IntegrationData__mdt dataMdt : integMetadataList) {
                if (dataMdt.DeveloperName == SERVICE_NAME) {
                    schedulingPolicyId = (Id) dataMdt.SchedulingPolicy__c;
                    operatingHoursId = (Id) dataMdt.Operating_Hours__c;
                }
            }
            AppointmentNumber = sAppointment.AppointmentNumber;
            if (schedulingPolicyId != null && operatingHoursId != null) {
                res.statusCode=201;
                OperatingHours oh = new OperatingHours();
                System.debug('schedulingPolicyId '+schedulingPolicyId +' - operatingHoursId '+operatingHoursId);
                TimeZone tz = TimeZone.getTimeZone('America/Sao_Paulo'); //write slots to DB in GMT time
                FSL.AppointmentBookingService.SortResultsBy sortResults = FSL.AppointmentBookingService.SortResultsBy.Grade; //sort by grade
                if(Test.isRunningTest()) {
                    SchedulingPolicyId = [SELECT Id FROM FSL__Scheduling_Policy__c LIMIT 1].Id;
                    oh = [SELECT Id, (SELECT EndTime, StartTime, Type, DayOfWeek FROM TimeSlots) FROM OperatingHours WHERE id IN (SELECT OperatingHoursId FROM TimeSlot) LIMIT 1];
                    operatingHoursId = oh.Id;
                }else{
                    oh = [SELECT id, (SELECT EndTime, StartTime, Type, DayOfWeek FROM TimeSlots) FROM OperatingHours WHERE id =:operatingHoursId];
                }
                System.debug('schedulingPolicyId '+schedulingPolicyId +' - operatingHoursId '+operatingHoursId);
                List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.GetSlots(sAppointment.Id, schedulingPolicyId, oh, tz, sortResults, false);
                if (slots.size() > 0) {
                    
                    for(FSL.AppointmentBookingSlot slot: slots) {
                        System.debug('slot.Interval.star '+slot.Interval.Start+' - slot.Interval.Finish '+slot.Interval.Finish);
                        if (startInterval >= slot.Interval.Start && startInterval < slot.Interval.Finish) {
                            System.debug('inside conditional slots ok!!!');
                            ResponseWrapper.BookingSlot bsRes = new ResponseWrapper.BookingSlot(sAppointment.AppointmentNumber, 'OK', 'Inserido com sucesso');
                            returnList.add(bsRes);
                            sAppointment.ArrivalWindowStartTime = startInterval.addHours(3); //write start and finish for highest graded slot
                            sAppointment.ArrivalWindowEndTime = endInterval.addHours(3);
                            break;
                        }
                    }
                    System.debug('rescheduleReason '+rescheduleReason);
                    if (returnList.size()>0) {
                        if (rescheduleReason != null)
                            sAppointment.Reschedule_Reason_SA__c = rescheduleReason;
                        try {
                            update sAppointment;
                            ScheduleServiceBatch ssb = new ScheduleServiceBatch(schedulingPolicyId, sAppointment.Id);
                            Id batchId = Database.executeBatch(ssb, 1);
                            System.debug('batchId log '+batchId);
                                
                        } catch (Exception e) {
                            String msg = 'Erro ao realizar agendamento: '+e.getMessage()+ ' - ' + e.getStackTraceString();
                            System.debug(msg);
                            ResponseWrapper.BookingSlot bsRes2 = new ResponseWrapper.BookingSlot(sAppointment.AppointmentNumber, 'ERRO', msg);
                            returnList = new List<ResponseWrapper.BookingSlot>();
                            returnList.add(bsRes2);  
                            res.statusCode=400;                          
                        }
                    } else {
                        System.debug('Não encontrado slot no intervalo selecionado');
                        ResponseWrapper.BookingSlot bsRes = new ResponseWrapper.BookingSlot(sAppointment.AppointmentNumber, 'ERRO', 'Não encontrado slots disponíveis');
                        returnList = new List<ResponseWrapper.BookingSlot>();
                        returnList.add(bsRes);
                        res.statusCode=404;
                    }
                } else {
                    ResponseWrapper.BookingSlot bsRes = new ResponseWrapper.BookingSlot(sAppointment.AppointmentNumber, 'ERRO', 'Não encontrado slots disponíveis');
                    returnList = new List<ResponseWrapper.BookingSlot>();
                    returnList.add(bsRes);
                    res.statusCode=404;
                    System.debug('return: '+ JSON.serialize(returnList));
                }
                
                res.responseBody=Blob.valueOf(JSON.serialize(returnList));
            } else {
                System.debug('Não encontrado schedulingPolicyId e/ou operatingHoursId');
                System.debug('schedulingPolicyId '+ schedulingPolicyId + ' - operatingHoursId '+operatingHoursId);
            }
        } catch (Exception e) {
            ResponseWrapper.BookingSlot bsRes = new ResponseWrapper.BookingSlot(AppointmentNumber, 'ERRO', e.getStackTraceString() + ' - '+e.getMessage());
            returnList = new List<ResponseWrapper.BookingSlot>();
            returnList.add(bsRes);
            System.debug('Error-> '+e.getStackTraceString() + ' - '+e.getMessage());
            res.statusCode=400;
            res.responseBody=Blob.valueOf(JSON.serialize(returnList));
        }
    }

    class ScheduleServiceAction implements Queueable, Database.AllowsCallouts {
        private Id scPId;
        private Id saID;
        public ScheduleServiceAction(Id schedulingPolicyId, Id sAppointmentID ) {
            this.saID   = sAppointmentID;
            this.scPId  = schedulingPolicyId;
        }
        
        public void execute(QueueableContext qc) {
            FSL.ScheduleResult myResult = new FSL.ScheduleResult();
            myResult = FSL.ScheduleService.schedule(this.scPId, this.saID);
            System.debug('myResult '+myResult);
        }
    }

    // @future(callout=true)
    // public static void scheduleServiceMethod(ID schedulingPolicyId, ID sAppointmentID) { 
    //     try {
    //         FSL.ScheduleResult myResult = new FSL.ScheduleResult();
    //         // static FSL.ScheduleResult Schedule(Scheduling Policy ID, Service Appointment ID)
    //         myResult = FSL.ScheduleService.schedule(schedulingPolicyId, sAppointmentID);

    //         System.debug('myResult '+myResult);
    //     } catch (Exception e) {
    //         System.debug('erro ao agendar compromisso: '+e.getMessage() + ' - '+e.getStackTraceString());
    //     }
    // }

    @HttpDelete
    global static void deleteSAppointment() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        List<ResponseWrapper.BookingSlot> responseWrapperList = new List<ResponseWrapper.BookingSlot>();
        String reasonCancellation = null;
        Id serviceAppointmentId = null;
        Id workOrderId = null;
        String returnMsg = '';
        try {
            String requestBody = RestContext.request.requestBody.toString();
            BookAppointmentCancellationWP bac = BookAppointmentCancellationWP.parse(requestBody);

            System.debug('body cancellation '+JSON.serialize(bac));
            serviceAppointmentId = bac.ServiceAppointmentID;
            ServiceAppointment sAppointment = [SELECT Id, MotivoDoCancelamento__c, Status
                                                FROM ServiceAppointment 
                                                WHERE Id = :serviceAppointmentId];
            sAppointment.Status                     = 'Cancelado';
            sAppointment.MotivoDoCancelamento__c    =  bac.ReasonCancellation;
            update sAppointment;
                      
            ResponseWrapper.BookingSlot rw = new ResponseWrapper.BookingSlot(serviceAppointmentId, 'Sucesso', 'Book Appointment cancelado com sucesso');
            responseWrapperList.add(rw);

            res.statusCode=201;
            res.responseBody=Blob.valueOf(JSON.serialize(responseWrapperList));
        } catch (Exception e) {
            System.debug('Error-> '+e.getStackTraceString() + ' - '+e.getMessage());
            String errorMsg = e.getMessage()+' - '+e.getStackTraceString() ;
            ResponseWrapper.BookingSlot rw = new ResponseWrapper.BookingSlot(serviceAppointmentId, 'Error', errorMsg);
            responseWrapperList.add(rw);
            res.statusCode=500;
            res.responseBody=Blob.valueOf(JSON.serialize(responseWrapperList));
        }
    }

    private static Datetime getDateTime(String dateTimeStr) {
        try {
            System.debug('getDateTime function '+dateTimeStr);
            String dateStr = dateTimeStr.substring(0,10);
            String timeStr = dateTimeStr.substring(11,19);
            List<String> dateList = dateStr.split('-');
            List<String> timeList = timeStr.split(':');
            Datetime dt = DateTime.newInstanceGmt(Integer.valueOf(dateList[0]),
                                   Integer.valueOf(dateList[1]),
                                   Integer.valueOf(dateList[2]),
                                   Integer.valueOf(timeList[0]),
                                   Integer.valueOf(timeList[1]),
                                   Integer.valueOf(timeList[2]));
            System.debug('dt-> '+dt);
            return dt;
        } catch (Exception e) {
            System.debug('erro ao converter a data '+dateTimeStr+': '+e.getStackTraceString() + ' - '+ e.getMessage());
            return null;
        }
    }
}