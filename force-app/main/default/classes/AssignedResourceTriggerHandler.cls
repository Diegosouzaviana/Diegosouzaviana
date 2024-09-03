public with sharing class AssignedResourceTriggerHandler {
    
    public static Map<Id,AssignedResource> newMap = new Map<Id,AssignedResource>();
    public static Map<Id,AssignedResource> oldMap = new Map<Id,AssignedResource>();

    public static void afterUpdate(Map<Id,AssignedResource> nMap, Map<Id,AssignedResource> oMap){
        newMap = nMap;
        oldMap = oMap;
        List<String> SRIds = new List<String>();
        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        for(AssignedResource ar : oMap.values()){
            if(nMap.containsKey(ar.Id) && nMap.get(ar.id).ServiceResourceId != ar.ServiceResourceId ){
                if(!SRIds.contains(String.valueOf(nMap.get(ar.id).ServiceResourceId))){
                    SRIds.add(String.valueOf(nMap.get(ar.id).ServiceResourceId));
                }
                if(!SRIds.contains(String.valueOf(ar.ServiceResourceId))){
                    SRIds.add(String.valueOf(ar.ServiceResourceId));
                }
            }
        }
        if(SRIds.size()>0){
            listSa = searchNextAppointment(SRIds);
        }
        if(listSa.size()>0){
            Database.update(listSa,false);
        }

    }

    
    public static void afterInsert(Map<Id,AssignedResource> nMap){
        newMap = nMap;
        List<String> SRIds = new List<String>();
        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        for(AssignedResource ar : nMap.values()){
            if(!SRIds.contains(String.valueOf(ar.ServiceResourceId))){
                SRIds.add(String.valueOf(ar.ServiceResourceId));
            }
        }
        if(SRIds.size()>0){
            listSa = searchNextAppointment(SRIds);
        }
        if(listSa.size()>0){
            Database.update(listSa,false);
        }
    }
    
    public static void afterDelete(Map<Id, AssignedResource> oMap){
        oldMap = oMap;
        List<String> SRIds = new List<String>();
        List<ServiceAppointment> clearSa = new List<ServiceAppointment>();
        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        List<ServiceAppointment> updateSa = new List<ServiceAppointment>();
        for(AssignedResource ar : oldMap.values()){
            if(!SRIds.contains(String.valueOf(ar.ServiceResourceId))){
                SRIds.add(String.valueOf(ar.ServiceResourceId));
            }
            ServiceAppointment sa = new ServiceAppointment();
            sa.id = ar.ServiceAppointmentId;
            sa.PreviousAppointment__c = null;
            clearSa.add(sa);
        }
        if(SRIds.size()>0){
            listSa = searchNextAppointment(SRIds);
        }
        System.debug('listSa => '+ listSa);
        updateSa = dispatchNextAppointment(oMap);
        System.debug('updateSa => '+ updateSa);
        
        if(listSa.size()>0 || updateSa.size()>0){
            for(ServiceAppointment sa : listSa){
                for(ServiceAppointment s : updateSa){
                    if(s.id == sa.id){
                        sa.status = 'Despachado';
                    }
                }
            }
        }
        List<Database.SaveResult> listResult = new  List<Database.SaveResult>();
        System.debug('updateSa2 => '+ updateSa);
        if(listSa.size()>0 || clearSa.size()>0){
            for(ServiceAppointment sa : clearSa){
                if(!listSa.contains(sa)){
                    listSa.add(sa);
                }
            }
            listResult = Database.update(listSa,false);
        }
        Map<String, ServiceAppointment> mapSa = new Map<String, ServiceAppointment>();
        for(ServiceAppointment sa : listSa){
            mapSa.put(sa.id, sa);
        }
        List<ServiceAppointment> retrySa = new List<ServiceAppointment>();
        if(listResult.size()>0){
            for(Database.SaveResult res : listResult){
                if(!res.isSuccess()){
                    ServiceAppointment sa = new ServiceAppointment();
                    if(mapSa.containskey(String.valueOf(res.getid()))){
                        sa = mapSa.get(String.valueOf(res.getid()));
                    }else{
                        sa.Id =res.getid();
                    }
                    sa.status = 'Agendado';
                    retrySa.add(sa);
                }
            }
        }
        if(retrySa.size()>0){
            Database.Update(retrySa,false);
        }
    }

    public static List<ServiceAppointment> searchNextAppointment(List<String> listSRIds){

        DateTime startDt = DateTime.newInstance(System.Today().year(),System.Today().month(), System.Today().day(),0,0,0);
        DateTime endDt = DateTime.newInstance(System.Today().year(),System.Today().month(), System.Today().day(),23,59,59);

        List<AssignedResource> listAr = new List<AssignedResource>();
        listAr = [SELECT id, ServiceAppointmentId, ServiceResourceId, ServiceAppointment.SchedStartTime,ServiceAppointment.SchedEndTime, ServiceAppointment.PreviousAppointment__c FROM AssignedResource WHERE ServiceResourceID IN: listSRIds AND ServiceAppointment.SchedStartTime>=:startDt AND ServiceAppointment.SchedEndTime <=: endDt ORDER BY ServiceAppointment.SchedStartTime ASC];
        
        Map<String,List<AssignedResource>> mapAr = new Map<String,List<AssignedResource>>();

        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        for(AssignedResource ar : listAr){
            if(mapAr.containsKey(String.valueOf(ar.ServiceResourceId))){
                List<AssignedResource> varListAr = new List<AssignedResource>();
                varListAr = mapAr.get(String.valueOf(ar.ServiceResourceId));
                varListAr.add(ar);
                mapAr.put(String.valueOf(ar.ServiceResourceId), varListAr);
            }else{
                mapAr.put(String.valueOf(ar.ServiceResourceId), new List<AssignedResource>{ar});
            }
        }
        if(mapAr.size()>0){
            listSa = updateNextAppointment(mapAr);
        }
        return listSa;
    }

    public static List<ServiceAppointment> updateNextAppointment(Map<String,List<AssignedResource>> mapAr){
        List<ServiceAppointment> listSa = new List<ServiceAppointment>();
        for(String s : mapAr.keySet()){
            Integer position = 1;
            for(AssignedResource ar : mapAr.get(s)){
                if(mapAr.get(s).size() > position){
                    if(ar.ServiceAppointmentId != mapAr.get(s).get(position).ServiceAppointment.PreviousAppointment__c){
                        ServiceAppointment sa = new ServiceAppointment();
                        sa.Id = mapAr.get(s).get(position).ServiceAppointmentId;
                        sa.PreviousAppointment__c = ar.ServiceAppointmentId;
                        listSa.add(sa);
                    }
                }
                if(position == 1){
                    ServiceAppointment sa = new ServiceAppointment();
                    sa.Id = mapAr.get(s).get(0).ServiceAppointmentId;
                    sa.PreviousAppointment__c = null;
                    listSa.add(sa);
                }
                position +=1;
            }
        }
        return listSa;
    }

    public static List<ServiceAppointment> dispatchNextAppointment(Map<Id,AssignedResource> listAs){
        List<ServiceAppointment> sas = new List<ServiceAppointment>();
        List<ServiceAppointment> returnSa = new List<ServiceAppointment>();
        List<String> saIds = new List<String>();
        for(AssignedResource asR : listAs.values()){
            if(!saIds.contains(String.valueOf(asR.ServiceAppointmentId))){
                saIds.add(String.valueOf(asR.ServiceAppointmentId));
            }
        }
        sas = [SELECT id, status FROM ServiceAppointment WHERE PreviousAppointment__c IN: saIds];
        return sas;
    }
}