/*---------------------------------------------------------------------------------------------------------------
--- Company: LabsXD
--- Author: Team OM
--- Description: Clase para envio de notificaciones
--- CreateDate:  14/11/2022
--- Update for: 
--- UpdateDate: 
--- Update Description: 
---------------------------------------------------------------------------------------------------------------*/

global with sharing class dsk_NotificationImplementation implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
    private static String DISPLAY_NAME = 'DESKTOP';
    class notificationException extends Exception{}
    
    global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items){
        try{
            if (!items.isEmpty()){
                
                vlocity_cmt__OrchestrationItem__c OrchesItem = [SELECT vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c, vlocity_cmt__AutoTaskParameters__c
                                                                FROM vlocity_cmt__OrchestrationItem__c
                                                                WHERE id = :items[0].id];
                
                Order order = [SELECT id, OrderNumber
                               FROM Order
                               WHERE Id = :OrchesItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c];                
                
                Map<string, Object> input = (Map<string, Object>)JSON.deserializeUntyped(OrchesItem.vlocity_cmt__AutoTaskParameters__c);
        		string email_template = (string)input.get('notificacion');
                
                EmailTemplate et = [SELECT Id, HtmlValue, Subject
                                    FROM EmailTemplate
                                    WHERE DeveloperName = :email_template];
                
                String htmlBody = et?.HtmlValue;
                String accountId = [SELECT	vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId
                                    FROM vlocity_cmt__OrchestrationItem__c
                                    WHERE id = :items[0].id].vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r?.AccountId;
                
                Account[] a = [SELECT id, Name
                                FROM Account
                                WHERE id = :accountId];

                List<Contact> contacts = [SELECT id, Email
                                            FROM Contact
                                            WHERE AccountId = :a[0].id 
                                            AND Email != ''];

                if(contacts.size()<1){
                    throw new notificationException('No email contacts to account id=' + a[0].id);
                }
                
                htmlBody = htmlBody.replace('[NOMBRE CUENTA]', a[0]?.Name);
                htmlBody = htmlBody.replace('[NUMERO ORDEN]', order.OrderNumber);

                List<String> toAddress = new List<String>();
                toAddress.add(contacts[0]?.Email);

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(contacts[0]?.id);
                mail.setTemplateId(et?.id);
                mail.setHtmlBody(htmlBody);
                mail.setToAddresses(toAddress);
                mail.setSubject(et?.Subject);
                mail.setWhatId(a[0]?.id);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
                
                OrgwideEmailAddress orgwideaddress = [SELECT id, displayname, Address
                                                    FROM orgwideEmailAddress
                                                    WHERE DisplayName = :DISPLAY_NAME
                                                    LIMIT 1];

                mail.setOrgWideEmailAddressId(orgwideaddress?.Id);
						 
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                allmsg.add(mail);
				
                Messaging.sendEmail(allmsg, true);
                System.debug(logginglevel.DEBUG,'Number of emails sent by the execution: ' + System.Limits.getEmailInvocations());
                
            }
        }
        catch(Exception e){
            switch on e.getTypeName() {
                when 'QueryException' {
                    System.debug(
                        System.LoggingLevel.ERROR,
                        'Error- Check in the line : ' +
                        e.getLineNumber() +
                        ' for possible null or incorrect value. Query is empty' +
                        ' Cause: ' +
                        e.getCause() +
                        'StackTrace: ' +
                        e.getStackTraceString() +
                        e.getMessage()
                    );
                }
                when 'EmailException' {
                    System.debug(
                        e.getMessage() +
                        ' \n' +
                        e.getLineNumber() +
                        ' \n' +
                        e.getCause()
                    );
                }
                when 'NullPointerException' {
                    System.debug(e.getMessage() + ' \n' + e.getCause());
                }
                when else {
                    System.debug(
                        System.LoggingLevel.ERROR,
                        'Unexpected Error, check log files.'
                    );
                }
            }
        }
    }
}