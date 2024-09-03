global with sharing class EveryCaseData {

    @AuraEnabled
    global static List<Case> getCaseData(String casesId) {

        List<String> caseId = casesId.split(';');
        System.debug('Case IDs: ' + caseId);
        if (caseId == null || caseId.isEmpty()) {
            System.debug('No case IDs provided.');
            return new List<Case>();
        }

        List<Case> caseList = [SELECT Id, ADM__c, Endereco_de_Atendimento__Street__s, Endereco_de_Atendimento__City__s, 
                                      motive__c, submotive__c, solution__c, Area_de_atendimento__c,
                                      CreatedDate, Account.Name, Owner.Name, CaseNumber
                               FROM Case 
                               WHERE Id IN :caseId];
        System.debug('Case List: ' + caseList);

        return caseList;
    }

    @AuraEnabled
    public static Id createCSVFile(String base64Data, String fileName) {
        try {
            System.debug('Base64 Data: ' + base64Data);
            System.debug('File Name: ' + fileName);

            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName;
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            insert cv;
            System.debug('ContentVersion ID: ' + cv.Id);
            return cv.Id;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}