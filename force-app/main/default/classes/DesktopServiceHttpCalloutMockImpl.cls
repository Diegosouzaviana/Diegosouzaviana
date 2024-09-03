@isTest
global class DesktopServiceHttpCalloutMockImpl implements HttpCalloutMock {
    Integer status = 200;
    String contentType = 'application/json';
    String body = '';
    
    global DesktopServiceHttpCalloutMockImpl(Integer s, String c, String b) {
        this.status = s;
        this.contentType = c;
        this.body = b;
    }
//montar body generico
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        if (req.getEndpoint().contains('token')) {
            String responseJson = '{\"access_token\":\"aaa\"}';
            res.setHeader('content-type', contentType);
            res.setStatusCode(this.status);
            res.setBody(responseJson);
        } else {
            //body da request principal
            String contentType = 'application/json';
            String responseJson = this.body;
            res.setHeader('content-type', contentType);
            res.setStatusCode(this.status);
            res.setBody(responseJson);
        }
        return res;
    }
}