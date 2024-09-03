public with sharing class Every_CaseScheduler implements Schedulable{
    
    private static String name = 'Emitir notificação de SLA Estourado.';
    
    private static String cron = '0 0 * * * ?';

    public static void executeSchedule(){
        System.schedule(name, cron, new Every_CaseScheduler());
    }

    public void execute(SchedulableContext context){
        Database.executeBatch(new Every_CaseBatch());
    }
}