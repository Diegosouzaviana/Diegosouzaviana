@RestResource(urlMapping='/CasesApp/*')
global without sharing class GetCasesAppRestResource {
    
    @HttpGet
    global static List<Case> getCasesByDocument() {
        RestRequest req = RestContext.request;

        String[] parts = req.requestURI.split('/CasesApp/')[1].split('/');

        if (parts.size() < 2) {
            RestContext.response.statusCode = 400;
            return null;
        }

        String documento = parts[0];
        String adm = parts[1];

        String limitParam = req.params.get('limit');
        Integer limitSize = 1000;
        if (String.isNotBlank(limitParam)) {
            limitSize = Integer.valueOf(limitParam);
        }

        List<Case> cases = [
            SELECT Id, Status, 
                   toLabel(Motive__c), 
                   toLabel(Submotive__c), 
                   toLabel(Solution__c), 
                   CreatedDate,
                   ClosedDate, 
                   AccountId,
                   toLabel(Area_de_atendimento__c),
                   LastModifiedBy.Name,
                   LXD_ProtocolNumber__c
            FROM Case 
            WHERE (Account.LXD_CPF__c = :documento OR Account.CPFCNPJFormatado__c = :documento) 
              AND ADM__c = :adm 
              AND CreatedDate <= LAST_N_DAYS:90
              AND (Solution__c != 'Resolvido por inatividade' AND Owner.Alias != 'imatr' AND Owner.Name != 'Chatbot')
            ORDER BY CreatedDate DESC 
            LIMIT :limitSize
        ];

        return cases;
    }
}