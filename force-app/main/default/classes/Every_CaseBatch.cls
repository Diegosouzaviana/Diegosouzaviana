public with sharing class Every_CaseBatch implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext batchBC) {
        return Database.getQueryLocator([SELECT Id, CaseNumber, Status,  StatusSLAPicklist__c, motive__c, submotive__c, 
                                             SLAEstourado__c, Departamento__c, OwnerId
                                        FROM Case
                                        WHERE Status != 'Finalizado'
                                        AND StatusSLAPicklist__c = 'Estourado'
                                        AND SLAEstourado__c = true]);
    }

    public void execute(Database.BatchableContext batchBC, List<Case> listCasos) {
        for (Case caso : listCasos) {
            CustomNotificationType custonNotification = [SELECT Id, CustomNotifTypeName
                                                         FROM CustomNotificationType 
                                                         WHERE CustomNotifTypeName = 'SLA Notification'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setNotificationTypeId(custonNotification.Id);
            notification.setSenderId (Userinfo.getUserId ());
            notification.setBody('O caso ' + caso.CaseNumber + ' teve seu SLA estourado!' + '\nMotivo: '+ caso.motive__c + '.' +'\nSubmotivo: ' 
                                 + caso.submotive__c + '.' + '\nClique aqui para ser direcionado ao caso.');
            notification.setTitle('Você possui um caso com SLA estourado!');
            notification.setTargetId(caso.Id);
            notification.send(new Set<String> {caso.OwnerId});
        }
    }

    public void finish(Database.BatchableContext batchBC) {

    }
}