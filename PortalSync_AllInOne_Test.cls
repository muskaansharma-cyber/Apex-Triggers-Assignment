@IsTest
public class PortalSync_AllInOne_Test {

    private class PortalSyncMock implements HttpCalloutMock {

        private Integer statusCode;

        PortalSyncMock(Integer statusCode) {
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);

            if (statusCode >= 200 && statusCode < 300) {
                res.setBody('{"success":true}');
            } else {
                res.setBody('{"success":false}');
            }
            return res;
        }
    }

    private static Opportunity createProperty(String syncStatus) {
        Opportunity opp = new Opportunity(
            Name = 'Test Property',
            StageName = 'Sold',
            CloseDate = Date.today(),
            Sync_Status__c = syncStatus,
            Sync_Retry_Count__c = 0
        );
        insert opp;
        return opp;
    }


    @IsTest
    static void testQueueableSuccess() {

        Opportunity opp = createProperty('Pending');

        Test.setMock(HttpCalloutMock.class, new PortalSyncMock(201));

        Test.startTest();
        System.enqueueJob(new PortalSyncQueueable(opp.Id));
        Test.stopTest();

        Opportunity updated = [
            SELECT Sync_Status__c, Sync_Retry_Count__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals('Success', updated.Sync_Status__c,
            'Property should be marked Success');
        System.assertEquals(0, updated.Sync_Retry_Count__c);
    }

    @IsTest
    static void testQueueableFailure() {

        Opportunity opp = createProperty('Pending');

        Test.setMock(HttpCalloutMock.class, new PortalSyncMock(500));

        Test.startTest();
        System.enqueueJob(new PortalSyncQueueable(opp.Id));
        Test.stopTest();

        Opportunity updated = [
            SELECT Sync_Status__c, Sync_Retry_Count__c, Last_Sync_Error__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals('Retry', updated.Sync_Status__c,
            'Property should be marked Retry');
        System.assertEquals(1, updated.Sync_Retry_Count__c);
        System.assertNotEquals(null, updated.Last_Sync_Error__c);
    }

    @IsTest
    static void testBatchRetrySuccess() {

        Opportunity opp = createProperty('Retry');
        opp.Sync_Retry_Count__c = 1;
        update opp;

        Test.setMock(HttpCalloutMock.class, new PortalSyncMock(201));

        Test.startTest();
        Database.executeBatch(new PortalSyncRetryBatch(), 1);
        Test.stopTest();

        Opportunity updated = [
            SELECT Sync_Status__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals('Success', updated.Sync_Status__c,
            'Retry batch should sync successfully');
    }
}
