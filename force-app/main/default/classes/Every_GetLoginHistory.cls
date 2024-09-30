public with sharing class Every_GetLoginHistory {
    @AuraEnabled(cacheable=true)
    public static Map<Boolean,Map<String,List<String>>>  getMapLoginHistory() {
        //instanciar lsitas e maps
        List<ServiceResource> serviceResourceList = [Select id,RelatedRecordId,RelatedRecord.Name from ServiceResource where IsActive = true];
        List<String> ids= new list<string>();
        List<String> idsSR= new list<string>();
        List<String> idsOH= new list<string>();
        for(ServiceResource sr :serviceResourceList){
            ids.add(sr.RelatedRecordId);
            idsSR.add(sr.id);
        }
        List<ServiceTerritoryMember> stm =[ SELECT id,OperatingHoursId,ServiceResourceId,ServiceResource.name  from ServiceTerritoryMember where TerritoryType = 'P' and ServiceResourceId in :idsSR];
        for(ServiceTerritoryMember stmsr :stm){
            
            idsOH.add(stmsr.OperatingHoursId);
        }
        List<OperatingHours> ohRecords = [select id from OperatingHours where id in :idsOH];
        List<TimeSlot> tslist = [SELECT id,DayOfWeek,StartTime,EndTime,OperatingHoursId from TimeSlot where OperatingHoursId in :ohRecords ];
        List<LoginHistory> loginHistoryList = [SELECT Id, UserId, LoginTime, SourceIp, Status, Application FROM LoginHistory WHERE LoginTime>= :System.now().addHours(-8) AND UserId  IN :ids   ORDER BY LoginTime DESC ];
       // Map<id,List<String>> mapLogin = new  Map<id,List<String>>();
        Map<Boolean,Map<String,List<String>>> mapEstrutura = new  Map<Boolean,Map<String,List<String>>>();
        Date myDate = Date.today(); 
        DateTime myDateTime = (DateTime) myDate;
        String dayOfWeekNow = myDateTime.format('E');
        Boolean isLated= false;
        //percorrer os dados e validar se o primeiro login foi feito antes do primeiro slot do time slot, 
        Map<String,List<String>> mapLogin = new  Map<String,List<String>>();
        for( ServiceResource sr : serviceResourceList){
           
            List<String> LoginTime = new List<String>();
            Integer count=0;
            Integer countTimeSlot=0;
             isLated= false;
           
            for ( LoginHistory lh: loginHistoryList) {
                if(lh.UserId == sr.RelatedRecordId && count <1){
                    //LoginTime.add(lh.loginTime.format() + 'Horarario Inicial:'+ );   
                    count++;
                    //verifica se entrou no horario
                    for (ServiceTerritoryMember strecord : stm) {
                        if(strecord.ServiceResourceId == sr.id ){
                           // System.debug(sr.RelatedRecord.Name +'----' + strecord.ServiceResourceId );
                            for(OperatingHours oh : ohRecords){
                                if(oh.id == strecord.OperatingHoursId){
                                    for (TimeSlot ts : tslist) {
                                        if(ts.OperatingHoursId == oh.id &&  ts.DayOfWeek.contains(dayOfWeekNow) == true && countTimeSlot <1){
                                            Time time1 = lh.loginTime.time();
                                            if(time1 > ts.StartTime ){
                                                System.debug('atrasou' + strecord.id);
                                                countTimeSlot++;
                                                isLated= true;
                                               
                                             
                                                LoginTime.add(' Horarario de Entrada: '+lh.loginTime.format() + ' Horarario Inicial: '+ ts.StartTime );
                                            //  mapLogin.put(sr.RelatedRecord.Name,LoginTime );
                                          //  mapLogin.put(sr.RelatedRecord.Name,LoginTime );
                                        }
                                       
                                    } //mapLogin.put(sr.RelatedRecord.Name,LoginTime );
                                 
                                    }
                                }
                            }
                        }        
                    } 
                }
            }
            if( isLated == true ){
              
               mapLogin.put(sr.RelatedRecord.Name,LoginTime );
               
                system.debug('entrou 1');
            }     
        }
        mapEstrutura.put(isLated,mapLogin);
        system.debug(mapEstrutura);
        
        return mapEstrutura;
        
    }
}