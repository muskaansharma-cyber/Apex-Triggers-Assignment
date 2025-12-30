@isTest
public class ServiceTerritoryFixBatchTest {

    private class ZipApiMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(
                '{"places":[{"state abbreviation":"NY"}]}'
            );
            return res;
        }
    }

    @testSetup
    static void setupData() {

        Account acc = new Account(
            Name = 'Test Customer',
            Zip_Code__c = '10001'
        );
        insert acc;

        WorkOrder wo = new WorkOrder(
            Subject = 'Test WO',
            Status = 'New',
            AccountId = acc.Id
        );
        insert wo;
    }

    @isTest
    static void testBatchExecution() {

        Test.setMock(HttpCalloutMock.class, new ZipApiMock());

        Test.startTest();
            Database.executeBatch(
                new ServiceTerritoryFixBatch(),
                1
            );
        Test.stopTest();

        WorkOrder updated = [
            SELECT Service_Territory__c
            FROM WorkOrder
            LIMIT 1
        ];

        System.assertEquals('NY', updated.Service_Territory__c);
    }
}
