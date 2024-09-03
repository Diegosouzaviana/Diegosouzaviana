@IsTest
public class FirstScheduleDateTimeConvertTest {
   @TestSetup
    public static void setup(){
        
        DesktopServiceFactoryTest.setup();
        DataFactoryTest.makeData();
  

    
    }
 @IsTest
    static void frmDate(){
         Test.startTest();
       ServiceAppointment sa =[SELECT id,ArrivalWindowStartTime,FirstScheduleDateTime__c,ArrivalWindowEndTime from ServiceAppointment limit 1];
        sa.ArrivalWindowEndTime =Datetime.now().addDays(1);
         sa.ArrivalWindowStartTime=Datetime.now();
        update sa;
     
        FirstScheduleDateTimeConvert.frmDate(new list<string>{sa.id}  );
         Test.stopTest();
    }


}