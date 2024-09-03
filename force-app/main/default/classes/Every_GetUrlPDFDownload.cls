global without sharing class Every_GetUrlPDFDownload implements vlocity_cmt.VlocityOpenInterface{
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        
        if (methodName.equalsIgnoreCase('getUrlPDF')) getUrlPDF(inputs, output);
        else return false;

        return true;
    }

    global static void getUrlPDF(Map<String, Object> inputs, Map<String, Object> output){
        String url = (String) inputs.get('endpoint');
        String authorization = (String) inputs.get('Authorization');
        String billetNumber = (String) inputs.get('billetNumber');

        String nameBillet = 'Boleto_'+billetNumber+'.pdf';
        String authorizationFinal = 'Bearer '+authorization;

        Http http = new Http();

        HttpRequest req = new HttpRequest();

        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/pdf');
        req.setHeader('Authorization', authorizationFinal);
        req.setCompressed(true);

        HttpResponse res = http.send(req);

        system.debug('Ressssssssssssssss:'+ res);

        blob filePDF = res.getBodyAsBlob();

        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = nameBillet;
        conVer.IsMajorVersion = true;
        conVer.VersionData = filePDF;
        conVer.Title = nameBillet;

        insert conVer;

        ContentDistribution conDis = new ContentDistribution();
        conDis.ContentVersionId = conVer.id;
        conDis.Name = nameBillet;

        insert conDis;

        String urlDownload = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id =:conDis.Id].DistributionPublicUrl;
        
        output.put('urlDownload', urlDownload);
    
    }
}