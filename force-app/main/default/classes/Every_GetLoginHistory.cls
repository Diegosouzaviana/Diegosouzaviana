public with sharing class Every_GetLoginHistory {
    @AuraEnabled(cacheable=true)
    public static Map<Boolean,Map<String,List<String>>>  getMapLoginHistory() {
        List<ServiceResource> serviceResourceList = [Select id,RelatedRecordId,RelatedRecord.Name from ServiceResource where IsActive = true];
        List<String> ids= new list<string>();
        List<String> idsSR= new list<string>();
        List<String> idsOH= new list<string>();
        for(ServiceResource sr :serviceResourceList){
            ids.add(sr.RelatedRecordId);
            idsSR.add(sr.id);
        }
        List<ServiceTerritoryMember> stm =[ SELECT id,OperatingHoursId,ServiceResourceId  from ServiceTerritoryMember where TerritoryType = 'P' and ServiceResourceId in :idsSR];
        for(ServiceTerritoryMember stmsr :stm){
            
            idsOH.add(stmsr.OperatingHoursId);
        }
        List<OperatingHours> ohRecords = [select id from OperatingHours where id in :idsOH];
        List<TimeSlot> tslist = [SELECT id,DayOfWeek,StartTime,EndTime,OperatingHoursId from TimeSlot where OperatingHoursId in :ohRecords ];
        
        
        
        List<LoginHistory> loginHistoryList = [SELECT Id, UserId, LoginTime, SourceIp, Status, Application FROM LoginHistory WHERE LoginTime>= :System.now().addHours(-24) AND UserId  IN :ids   ORDER BY LoginTime DESC ];
       // Map<id,List<String>> mapLogin = new  Map<id,List<String>>();
        Map<Boolean,Map<String,List<String>>> mapEstrutura = new  Map<Boolean,Map<String,List<String>>>();
        Date myDate = Date.today(); 
        DateTime myDateTime = (DateTime) myDate;
        String dayOfWeekNow = myDateTime.format('E');
     
        for( ServiceResource sr : serviceResourceList){
            Map<String,List<String>> mapLogin = new  Map<String,List<String>>();
            List<String> LoginTime = new List<String>();
            Integer count=0;
            Integer countTimeSlot=0;
            Boolean isLated= false;
            for ( LoginHistory lh: loginHistoryList) {
                if(lh.UserId == sr.RelatedRecordId && count <1){
                    LoginTime.add(lh.loginTime.format());   
                    count++;
                    //verifica se entrou no horario
                    for (ServiceTerritoryMember strecord : stm) {
                        if(strecord.ServiceResourceId == sr.id ){
                            for(OperatingHours oh : ohRecords){
                                if(oh.id == strecord.OperatingHoursId){
                                    for (TimeSlot ts : tslist) {
                                        if(ts.OperatingHoursId == oh.id &&  ts.DayOfWeek.contains(dayOfWeekNow) == true && countTimeSlot <1){
                                            Time time1 = lh.loginTime.time();
                                            if(time1 > ts.StartTime ){
                                                System.debug('atrasou');
                                                countTimeSlot++;
                                                isLated= true;
                                              //  mapLogin.put(sr.RelatedRecord.Name,LoginTime );
                                            }
                                           // mapLogin.put(sr.RelatedRecordId,LoginTime );
                                        }
                                    }
                                }
                            }
                        }        
                    } 
                }
            }
            if(!LoginTime.isEmpty()){
                system.debug(mapEstrutura);
               mapLogin.put(sr.RelatedRecord.Name,LoginTime );
                mapEstrutura.put(isLated,mapLogin);
                system.debug('entrou 1');
            }     
        }
       
        system.debug(mapEstrutura);
        
        return mapEstrutura;
        
    }
}