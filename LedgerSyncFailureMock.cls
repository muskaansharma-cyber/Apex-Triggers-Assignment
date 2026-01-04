@isTest
public class LedgerSyncFailureMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse r = new HttpResponse();
        r.setStatusCode(500);
        return r;
    }
}
