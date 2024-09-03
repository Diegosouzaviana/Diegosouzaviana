@IsTest
global class AppointmentBookingHttpCalloutMockImpl implements HttpCalloutMock {
    Integer status = 200;
    String contentType = 'application/json';
    String body = '';
    
    public AppointmentBookingHttpCalloutMockImpl(Integer s, String c, String b) {
        this.status = s;
        this.contentType = c;
        this.body = b;
    }

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        String responseJson = this.body;
        res.setHeader('Content-Type', contentType);
        res.setStatusCode(this.status);
        res.setBody(responseJson);
        return res;
    }
}