public class UpdateAppointmentTime {

    @InvocableMethod
    public static void updatetime(List<String> SaId){

        List<ServiceAppointment> saRecords = new List<ServiceAppointment>();
        saRecords = [SELECT id,ArrivalWindowEndTime, ServiceTerritoryId, ArrivalWindowStartTime,ServiceTerritory.OperatingHoursId,SchedStartTime FROM ServiceAppointment WHERE id IN :SaId];
        
        Map<String, List<ServiceAppointment>> mapObj = new Map<String, List<ServiceAppointment>>();
        List<String> listOpID = new List<String>();

        for(ServiceAppointment sa : saRecords){
            if(!listOpID.contains(String.valueOf(sa.serviceTerritory.OperatingHoursId))){
                listOpID.add(String.valueOf(sa.serviceTerritory.OperatingHoursId));
            }
            if(mapObj.containsKey(String.valueOF(sa.ServiceTerritory.OperatingHoursId))){
                mapObj.get(String.valueOf(sa.ServiceTerritory.OperatingHoursId)).add(sa);
            }else{
                mapObj.put(String.valueOf(sa.ServiceTerritory.OperatingHoursId), new List<ServiceAppointment>{sa});
            }

        }

        List<OperatingHours> opList = new List<OperatingHours>();
        opList = [SELECT id, (SELECT id, StartTime, endTime, dayOfWeek FROM TimeSlots) FROM OperatingHours WHERE id IN: listOpId];

        List<ServiceAppointment> updateSa = new List<ServiceAppointment>();
        for(OperatingHours op : opList){
            if(mapObj.containsKey(String.valueOf(op.Id))){
                updateSa.addAll(validateDate(op, mapObj.get(String.valueOf(op.Id))));
            }
        }

        if(updateSa.size()>0){
            Database.update(updateSa, false);
        }
        
    }

    public static List<ServiceAppointment> validateDate(OperatingHours op, List<ServiceAppointment> saList){

        List<TimeSlot> tm = op.timeSlots;
        List<ServiceAppointment> returnSA = new List<ServiceAppointment>();

        Map<String, List<TimeSlot>> mapTm = new Map<String, List<TimeSlot>>();
        for(TimeSlot t : tm){
            String dia = t.dayOfWeek.left(3);
            if(mapTm.containsKey(dia)){
                mapTm.get(dia).add(t);
            }else{
                mapTm.put(dia, new List<TimeSlot>{t});
            }
        }

        for(ServiceAppointment sa : saList){
            if(sa.SchedStartTime == null){
                sa.ArrivalWindowStartTime = null;
                sa.ArrivalWindowEndTime = null;
                returnSA.add(sa);
            }else{
                String dia = sa.SchedStartTime.format('E');
                if(mapTm.containskey(dia)){
                    returnSA.add(catchSlot(sa,mapTm.get(dia)));
                }
            }
        }
        return returnSA;
    }

    public static ServiceAppointment catchSlot(ServiceAppointment sa, List<TimeSlot> tsList){

        for(TimeSlot ts : tsList){
            if(sa.SchedStartTime.Time() > ts.StartTime && sa.SchedStartTime.Time() < ts.EndTime){
                sa.ArrivalWindowStartTime = Datetime.newInstance(sa.SchedStartTime.date(), ts.startTime);
                sa.ArrivalWindowEndTime = Datetime.newInstance(sa.SchedStartTime.date(), ts.EndTime);
                break;
            }
        }
        return sa;

    }
    
}