global class ScheduledServiceAppointment implements Schedulable {
    public static String CRON_EXP = '0 40 17 * * ?';
	global void execute(SchedulableContext sc) {
        try {
            List<ServiceAppointment> SAppointmentList = new List<ServiceAppointment>();
            List<ServiceAppointment> SAppListToSave = new List<ServiceAppointment>();
            List<Report> reportList = [Select Id from Report where DeveloperName = 'OrdemTrabalhoCompromissoNotificacao' order by CreatedDate desc limit 1];
            String urlString = '', territoryName = '';
            Date todayDate = Date.today();
            Id emailAddressId;
            SAppointmentList = [Select AppointmentNumber, ArrivalWindowEndTime, Est_Atrasado__c, Account.Name, NotificacaoEnviada__c, Id,
                                    ServiceTerritory.NotificationEmailCOP__c, ServiceTerritory.NotificationEmailFM__c, ServiceTerritory.Name,
                                    ServiceTerritory.NotificationEmailFS__c 
                                    From ServiceAppointment Where Est_Atrasado__c = true And NotificacaoEnviada__c  = false And DAY_ONLY(ArrivalWindowEndTime) = TODAY
                                    ];

            List<String> toAddresses = new List<String>();
            List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
            List<opportunity> opp = new List<opportunity>();
            String htmlBody;
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();   
            //System.debug('UrlTest '+baseUrl);
            if (reportList.size() > 0) 
                urlString =  baseUrl+'/lightning/r/Report/'+reportList[0].Id+'/view';
            else
                System.debug('Não encontrado relatório \'OrdemTrabalhoCompromissoNotificacao\'');

            for (ServiceAppointment sApp : SAppointmentList) {
                toAddresses.add(sApp.ServiceTerritory.NotificationEmailCOP__c);
                toAddresses.add(sApp.ServiceTerritory.NotificationEmailFM__c);
                toAddresses.add(sApp.ServiceTerritory.NotificationEmailFS__c);
                sApp.NotificacaoEnviada__c = true;
                territoryName = sApp.ServiceTerritory.Name;
                System.debug('sApp.ServiceTerritory.NotificationEmailCOP__c '+sApp.ServiceTerritory.NotificationEmailCOP__c);
                System.debug('sApp.ServiceTerritory.NotificationEmailFM__c '+sApp.ServiceTerritory.NotificationEmailFM__c);
                System.debug('sApp.ServiceTerritory.NotificationEmailFS__c '+sApp.ServiceTerritory.NotificationEmailFS__c);
            }
            if (SAppointmentList.size() > 0) {
                htmlbody = '<html><body>';
                htmlbody += '<p>O agendamento com o cliente está vencido, no território '+ territoryName +'. </br>Acesse o relatório para mais informações: <a href="'+urlString+'"> Relatório</a></p>';
                htmlbody += '</body></html>';

                for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress Where DisplayName = 'Relatório de Serviço Desktop' limit 1]) {
                    emailAddressId = owa.id;
                }
                    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);      
                //mail.setOrgWideEmailAddressId(emailAddressId);
                //mail.setSenderDisplayName('Ordem Trabalho Compromisso Notificação');
                mail.setSubject('Ordem Trabalho Compromisso Notificacao');
                mail.setUseSignature(false);            
                mail.setHtmlBody(htmlBody);
                mailsToSend.add(mail);
                Messaging.sendEmail(mailsToSend);
                
                update SAppointmentList;
            }
        } catch (Exception e) {
            System.debug('ScheduledServiceAppointment Exception: '+e.getMessage() + ' - '+e.getStackTraceString());
        }
    }
}