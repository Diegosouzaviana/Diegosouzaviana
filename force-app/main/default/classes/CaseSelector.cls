// 
// Classe de testes: CaseSelectorTest
// 
public with sharing class CaseSelector {
    
    // Selector para casos com Contrato, ClosedDate, Motivo, Submotivo, Tipo e Tema preenchidos, dentro do
    // intervalo do último ano.
    public static List<Case> getCasesLastYear(){
        Date oneYearAgo = Date.today().addMonths(-12);
        return [
            SELECT Id, CaseNumber, motive__c, submotive__c, CreatedDate, Contrato__c, OwnerId, Tipo__c, Tema__c
            FROM Case
            WHERE CreatedDate >= :oneYearAgo AND
            (motive__c != null AND submotive__c != null AND 
            Tipo__c != null AND Tema__c != null)
            AND Contrato__c != null
            AND ClosedDate != null
            ORDER BY CreatedDate DESC
        ];
    }

    // Selector para casos com Contrato, ClosedDate, Motivo, Submotivo, Tipo e Tema preenchidos, dentro do
    // intervalo de data início e data fim.
    public static List<Case> getCasesBetweenTwoDates(Date startDate, Date endDate){
        return [SELECT  Id, 
                        CaseNumber, 
                        motive__c, 
                        submotive__c, 
                        CreatedDate, 
                        Contrato__c, 
                        OwnerId, 
                        Tipo__c, 
                        Tema__c
                FROM    Case
                WHERE   CreatedDate >= :startDate AND CreatedDate <= :endDate AND
                        (motive__c != null AND submotive__c != null AND 
                        Tipo__c != null AND Tema__c != null)
                AND     Contrato__c != null
                AND     ClosedDate != null
                ORDER BY CreatedDate DESC];
    }

    // Selector para pegar Casos por lista de Ids
    public static List<Case> getCasesBetweenTwoDates(List<String> caseIds){
        return [SELECT  Id, 
                        ADM__c, 
                        Endereco_de_Atendimento__Street__s, 
                        Endereco_de_Atendimento__City__s, 
                        motive__c, 
                        submotive__c, 
                        Tipo__c, 
                        Tema__c, 
                        solution__c, 
                        Area_de_atendimento__c,
                        CreatedDate, 
                        Account.Name, 
                        Owner.Name, 
                        CaseNumber
                FROM    Case 
                WHERE   Id IN :caseIds];
    }


}