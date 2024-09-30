global with sharing class WorkTypeTriggerHandler {

    @InvocableMethod(label = 'Reprocessa categorias')
    public static void reprocessSA(){
        
        Database.executeBatch(new BatchServiceAppointmentCategoryChange(), 50);
    }
}