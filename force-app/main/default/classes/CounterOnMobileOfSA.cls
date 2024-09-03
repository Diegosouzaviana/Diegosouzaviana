public without sharing class CounterOnMobileOfSA {
    @AuraEnabled 
    public static String GetCounterMobile() {
        try {
            //User currentUser = [SELECT FirstName, LastName, Id FROM User WHERE Id =: UserInfo.getUserId()];
            Integer totalQuantity = 0, canceledQuantity = 0, completedQuantity = 0, toDoQuantity = 0;
            //List<ServiceResource> ServiceResourceList = [SELECT Name, RelatedRecordId, Id FROM ServiceResource WHERE RelatedRecordId = :currentUser.Id ORDER BY CreatedDate DESC LIMIT 1];
            List<ServiceResource> ServiceResourceList = [SELECT Name, RelatedRecordId, Id FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1];

            if (ServiceResourceList.size() > 0) {
                List<ServiceAppointment> ServiceAppointmentList = [SELECT Status, Id FROM ServiceAppointment WHERE IsSAfortoday__c = TRUE AND ServiceResourceLK__c =:ServiceResourceList[0].Id ORDER BY SchedStartTime DESC];
                if (ServiceAppointmentList.size() > 0) {
                    totalQuantity = ServiceAppointmentList.size();
                    for (ServiceAppointment sa : ServiceAppointmentList) {
                        if (sa.Status == 'Cancelado') {
                            canceledQuantity = canceledQuantity + 1;
                        } else if(sa.Status == 'Concluída'){
                            completedQuantity = completedQuantity + 1;
                        }
                    }
                    toDoQuantity = totalQuantity - (canceledQuantity + completedQuantity);
                }
            }
            return totalQuantity+'@'+toDoQuantity+'@'+completedQuantity+'@'+canceledQuantity;
        } catch (Exception e) {
            System.debug('Erro ao obter contagem de SA '+e.getMessage()+' - '+e.getStackTraceString());
            return 'Erro ao obter contagem de SA '+e.getMessage()+' - '+e.getStackTraceString();
        }
    }
}