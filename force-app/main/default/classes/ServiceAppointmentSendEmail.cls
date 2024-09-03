public class ServiceAppointmentSendEmail {

    @InvocableMethod
    public static void ServiceAppointmentSendEmail(List<List<String>> sAppointment) {
        try {
            Id recordID, contactID, templateID, contentDocumentID;
            Id emailAddressId = null;
            String emailToSend, contentDocumentTitle, typeJob;
            for (List<String> sA : sAppointment) {
                recordID = sA[0];
                templateID = sA[1];
                emailToSend = sA[2];
                contentDocumentID = sA[3];
                contentDocumentTitle = sA[4];
                contactID = sA[5];
                typeJob = sA[6];
            }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            ContentDocument cD = [Select LatestPublishedVersion.VersionData, ContentDocument.Title, Id 
                                    From ContentDocument 
                                    Where ID = :contentDocumentID And Title = :contentDocumentTitle
                                    Order by CreatedDate desc limit 1];

            emailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Comunicado@Desktop' LIMIT 1].Id;
            
            if (contactID==null) 
                contactID = [SELECT  id FROM Contact WHERE LXD_AlternativeEmail__c = 'dummy@dummy.com.br' AND LXD_CPF__c = '11111111111' LIMIT 1].Id;
            
            Blob b = cD.LatestPublishedVersion.VersionData;
            attach.setFileName('RELATORIO_DE_SERVICO.pdf');
            attach.setBody(b);
            System.debug('contactID '+contactID);
            email.setTemplateId(templateID);//Replace TEMPLATEID with salesforce email template id
            email.setCcAddresses(new String[]{emailToSend});
            email.setTargetObjectId(contactID);//Replace TARGETOBJECTID with user, contact or lead Id to which emai need to be sent.
            email.setWhatId(recordID);//Record Id for which email template need to be applied
            email.setOrgWideEmailAddressId(emailAddressId);
            email.setSaveAsActivity(false);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});

            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        } catch (Exception e) {
            System.debug('Erro ao enviar email em ServiceAppointmentSendEmail: '+e.getMessage() + ' - '+e.getStackTraceString());
        }
    }
}