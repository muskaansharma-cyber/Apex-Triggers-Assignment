@isTest
public class OpportunityGeoFutureTest {

    @isTest
    static void testSuccessFlow_ThroughTrigger() {

        Test.setMock(HttpCalloutMock.class, new ZipApiMock());

        Opportunity opp = new Opportunity(
            Name = 'Geo Success',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Zip_Code__c = '90210'
        );

        Test.startTest();
            insert opp; // trigger fires → future method runs
        Test.stopTest();

        Opportunity updatedOpp = [
            SELECT City__c, State__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals('Beverly Hills', updatedOpp.City__c);
        System.assertEquals('California', updatedOpp.State__c);
    }

    @isTest
    static void testZipNull_NoFutureCall() {

        Opportunity opp = new Opportunity(
            Name = 'No Zip',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );

        Test.startTest();
            insert opp;
        Test.stopTest();

        Opportunity unchangedOpp = [
            SELECT City__c, State__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals(null, unchangedOpp.City__c);
        System.assertEquals(null, unchangedOpp.State__c);
    }

    @isTest
    static void testEmptyApiResponse() {

        Test.setMock(HttpCalloutMock.class, new ZipApiEmptyMock());

        Opportunity opp = new Opportunity(
            Name = 'Empty API',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Zip_Code__c = '99999'
        );

        Test.startTest();
            insert opp;
        Test.stopTest();

        Opportunity unchangedOpp = [
            SELECT City__c, State__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals(null, unchangedOpp.City__c);
        System.assertEquals(null, unchangedOpp.State__c);
    }

    @isTest
    static void testApiExceptionHandledGracefully() {

        Test.setMock(HttpCalloutMock.class, new ZipApiExceptionMock());

        Opportunity opp = new Opportunity(
            Name = 'API Failure',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Zip_Code__c = '12345'
        );

        Test.startTest();
            insert opp;
        Test.stopTest();

        Opportunity unchangedOpp = [
            SELECT City__c, State__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals(null, unchangedOpp.City__c);
        System.assertEquals(null, unchangedOpp.State__c);
    }

    // ---------------- MOCKS ----------------

    private class ZipApiMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' +
                    '"places": [' +
                        '{' +
                            '"place name": "Beverly Hills",' +
                            '"state": "California"' +
                        '}' +
                    ']' +
                '}'
            );
            return res;
        }
    }

    private class ZipApiEmptyMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "places": [] }');
            return res;
        }
    }

    private class ZipApiExceptionMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Simulated API failure');
        }
    }
}
