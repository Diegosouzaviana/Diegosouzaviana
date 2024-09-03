public with sharing class SchUpdateAssignedResource implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executebatch(new BchUpdateAssignedResource(), 200);
    }
}