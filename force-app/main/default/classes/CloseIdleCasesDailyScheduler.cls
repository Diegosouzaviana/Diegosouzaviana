// 
// Classes de testes:
// ** CloseIdleCasesSchedulerTest
// 
global class CloseIdleCasesDailyScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        CloseIdleCasesDailyBatch batch = new CloseIdleCasesDailyBatch();
        Database.executeBatch(batch);
    }
    
    // Executa todos os dias à meia-noite
    public static void scheduleJob() {
        
        String cronExpression = '0 0 0 * * ?';
        CloseIdleCasesDailyScheduler scheduler = new CloseIdleCasesDailyScheduler();
        System.schedule('CloseIdleCasesBatchJob', cronExpression, scheduler);
    }
}