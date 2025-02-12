public abstract with sharing class TriggerHandler {

    public System.TriggerOperation operation {get; set;}
    public List<SObject> newRecords {get;set;}
    public List<SObject> oldRecords {get;set;}
    public Map<Id, SObject> newMap {get;set;}
    public Map<Id, SObject> oldMap {get;set;}

    public TriggerHandler(System.TriggerOperation operation, List<SObject> newRecords, List<SObject> oldRecords, Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        this.operation  = operation;
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newMap     = newMap;
        this.oldMap     = oldMap;
    }

    public void execute() {
        if (this.operation == System.TriggerOperation.BEFORE_INSERT) {
            beforeInsert();
        }
        else if (this.operation == System.TriggerOperation.AFTER_INSERT) {
            afterInsert();
        }
        else if (this.operation == System.TriggerOperation.BEFORE_UPDATE) {
            beforeUpdate();
        }
        else if (this.operation == System.TriggerOperation.AFTER_UPDATE) {
            afterUpdate();
        }
        else if (this.operation == System.TriggerOperation.BEFORE_DELETE) {
            beforeDelete();
        }
        else if (this.operation == System.TriggerOperation.AFTER_DELETE) {
            afterDelete();
        }
    }

    public abstract void beforeInsert();

    public abstract void afterInsert();

    public abstract void beforeUpdate();

    public abstract void afterUpdate();

    public abstract void beforeDelete();

    public abstract void afterDelete();

}