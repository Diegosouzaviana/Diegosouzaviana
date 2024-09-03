public class FirstScheduleDateTimeConvert {
@InvocableMethod
    public static void frmDate(List<string> idSA){
      ServiceAppointment sa =[SELECT id,ArrivalWindowStartTime,FirstScheduleDateTime__c,ArrivalWindowEndTime from ServiceAppointment where id =:idSA[0] limit 1];
        

        String timeString = sa.ArrivalWindowEndTime.format('HH:mm'); 
       // String firstFiveDigits = timeString.substring(0, 5);
        String dtString = sa.ArrivalWindowStartTime.format();
        String modifiedDtString = dtString.substring(0, dtString.length() );
               
        sa.FirstScheduleDateTime__c= modifiedDtString + ' ás ' + timeString;
        update sa;
    }
    
    
}