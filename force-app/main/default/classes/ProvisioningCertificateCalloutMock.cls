/**
**************************************************************************************************************
* @company          Sys4b
* @author           Guilherme
* @project          DesktopSA
* @name             ProvisioningCertificateCalloutMock
* @description      Mock Callout of  ProvisioningCertificate Integration
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2023-09-02   Guilherme                     Initial version. 
******
**/

@isTest
global class ProvisioningCertificateCalloutMock implements HttpCalloutMock {
    Integer status;

    public ProvisioningCertificateCalloutMock(Integer status) {
        this.status = status;
    }

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        switch on this.status {
            when 200 {
                if (req.getEndPoint().contains('provisioning_certificate')) {
                    res.setBody('{"message":"Processing ..."}');    
                } else 
                    res.setBody('{"access_token":"123","expires_in":5000,"refresh_expires_in":3000,"token_type":""}');
            } when else {
                if (req.getEndPoint().contains('provisioning_certificate')) 
                    res.setBody('"message":""');
                else
                    res.setBody('{"access_token":"123","expires_in":5000,"refresh_expires_in":3000,"token_type":""}');
            } 
        }
        res.setStatusCode(this.status);
        return res;
    }
}