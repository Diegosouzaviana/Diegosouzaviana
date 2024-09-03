public with sharing class CaseController {

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> listEmailsTemplate(){
        List<EmailTemplate> emails = new List<EmailTemplate>();

        try{
            emails = CaseSelector.listEmailsTemplates();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return emails;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> emailTemplates(Id templateId, Id recordId){
        EmailTemplate emailTemplate = new EmailTemplate();
        Map<String, String> templateContent = new Map<String, String>();

        try {
            emailTemplate = CaseSelector.getEmailTemplate(templateId);
            templateContent.put('Subject', formatarTemplate(emailTemplate.Subject, recordId));
            templateContent.put('Body', formatarTemplate(emailTemplate.HtmlValue, recordId));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return templateContent;
    }

    @AuraEnabled(cacheable=true)
    public static String formatarTemplate(String template, Id recordId){

        String templateFormatado = template;
        List<MapeamentoTemplateEmailService__mdt> metadados = CaseSelector.getMetadadoMapTemplate();
        List<Case> cases = CaseSelector.getCase(recordId);
        Case caso = cases[0];

        List<Account> accounts = CaseSelector.getAccount(caso.AccountId);
        Account conta = accounts[0];

        Map<String, String> mapCampos = new Map<String, String>(); 
        Map<Object, String> mapObjetos = new Map<Object, String>(); 
        List<String> listaTags = new List<String>(); 

        for(MapeamentoTemplateEmailService__mdt metadado : metadados){
            mapCampos.put(metadado.Label, metadado.Campo__c);
            mapObjetos.put(metadado.Label, metadado.Objeto__c);
            listaTags.add(metadado.Label);
        }

        for(String tag :  listaTags){

            String campoTag = mapCampos.get(tag);
            if (campoTag == null){
                continue;
            }
            String objeto = mapObjetos.get(tag);
            if (objeto == null){
                continue;
            }

            switch on objeto {
                when 'Case'{
                    String campo = mapCampos.get(tag);
                    Object campoObjeto = caso.get(campo);

                    if (campoObjeto == null) {
                        templateFormatado = templateFormatado.replace(tag, '');
                        continue;
                    }

                    templateFormatado = templateFormatado.replace(tag, String.valueOf(campoObjeto));
                }
                when 'Account'{
                    String campo = mapCampos.get(tag);
                    Object campoObjeto = conta.get(campo);

                    if(campoObjeto == null) {
                        templateFormatado = templateFormatado.replace(tag, '');
                        continue;
                    }

                    templateFormatado = templateFormatado.replace(tag, String.valueOf(campoObjeto));
                }
            }
        }

        System.debug('templateFormatado:  '+ templateFormatado);
        return templateFormatado;
    }

    @AuraEnabled(cacheable=true)
    public static String sendEmail(List<String> customerEmails, String subject, String body, List<Map<String, String>> files){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        List<String> toAddresses = new List<String>();
        for (String cEmail : customerEmails) {
            toAddresses.add(cEmail);
        }

        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setHtmlBody(body);

        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for (Map<String, String> file : files) {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(file.get('fileName'));
            efa.setBody(EncodingUtil.base64Decode(file.get('fileBody')));
            fileAttachments.add(efa);
        }

        email.setFileAttachments(fileAttachments);

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            return 'Email enviado com sucesso';
        } catch (Exception e) {
            return 'Erro ao enviar email: ' + e.getMessage();
        }

    }
}