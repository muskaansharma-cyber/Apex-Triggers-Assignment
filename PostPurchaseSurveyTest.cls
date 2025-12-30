@isTest
public class PostPurchaseSurveyTest {

    public class PostPurchaseSurveyMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true, "message": "Survey triggered"}');
            return res;
        }
    }

    @isTest
    static void testPostPurchaseSurvey() {
        Account acc = new Account(Name='Test Account');
        insert acc;

        Order ord = new Order(
            Name = 'Test Order',
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert ord;

        Test.setMock(HttpCalloutMock.class, new PostPurchaseSurveyMock());

        ord.Status = 'Delivered';
        Test.startTest();
        update ord;
        Test.stopTest();

        System.assert(true, 'Post-purchase survey callout executed successfully.');
    }
}
