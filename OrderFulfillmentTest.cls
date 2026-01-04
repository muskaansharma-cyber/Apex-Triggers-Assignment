@isTest
private class OrderFulfillmentTest {

    @isTest
    static void testOutboundAndRetry() {

        Account acc = new Account(
            LastName = 'Person',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND Name='Person Account' LIMIT 1].Id
        );
        insert acc;

        Order ord = new Order(
            Name = 'Test Order',
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Fulfillment_Status__c = 'Pending',
            Fulfillment_Attempts__c = 0
        );
        insert ord;

        Test.setMock(HttpCalloutMock.class, new HttpMockSuccess());

        Test.startTest();
            System.enqueueJob(new OrderFulfillmentQueueable(ord.Id));
            Database.executeBatch(new FulfillmentRetryBatch(), 1);
        Test.stopTest();

        ord = [SELECT Fulfillment_Status__c FROM Order WHERE Id = :ord.Id];
        System.assertEquals('Sent', ord.Fulfillment_Status__c);
    }

    private class HttpMockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"id":"12345"}');
            return res;
        }
    }
}
