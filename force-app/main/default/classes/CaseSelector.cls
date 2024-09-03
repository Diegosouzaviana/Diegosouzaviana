public with sharing class CaseSelector {

    public static List<EmailTemplate> listEmailsTemplates(){
        return [SELECT Id, Name, Description 
                FROM EmailTemplate 
                WHERE Name LIKE '%Dicas APP%'
                OR Name LIKE '%Ativação Globoplay%'
                OR Name LIKE '%Ativação Watch%'
                OR Name LIKE '%Kaspersky%'
                ];
    }

    public static EmailTemplate getEmailTemplate(Id templateId){
        return [SELECT Id, 
                    Name, 
                    Subject, 
                    Body, 
                    HtmlValue 
                FROM EmailTemplate 
                WHERE Id = :templateId
        ];
    }

    public static List<MapeamentoTemplateEmailService__mdt> getMetadadoMapTemplate(){
        return [SELECT Id, 
                    Label, 
                    Campo__c, 
                    Objeto__c  
                FROM MapeamentoTemplateEmailService__mdt];
    }

    public static List<Case> getCase(Id recordId){
        return [SELECT Id,
                    AccountId,
                    Account.Name
                FROM Case
                WHERE Id = :recordId
                LIMIT 1];               
    }

    public static List<Account> getAccount(Id accountId){
        return [SELECT Id,
                    Name
                FROM Account
                WHERE Id = :accountId
                LIMIT 1];               
    }
}