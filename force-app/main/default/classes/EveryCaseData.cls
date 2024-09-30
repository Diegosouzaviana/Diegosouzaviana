global with sharing class EveryCaseData {

    @AuraEnabled
    global static List<Case> getCaseData(String casesId) {

        List<String> caseId = casesId.split(';');

        if (caseId == null || caseId.isEmpty()) {
            System.debug('No case IDs provided.');
            return new List<Case>();
        }

        return CaseSelector.getCasesBetweenTwoDates(caseId);
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