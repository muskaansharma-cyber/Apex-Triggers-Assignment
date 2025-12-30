@isTest
public class OrderFraudDetectionBatchTest {

    private class ZipApiMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            res.setBody(
                '{' +
                '"post code": "90210",' +
                '"country": "United States",' +
                '"places": [' +
                '  {' +
                '    "place name": "Beverly Hills",' +
                '    "state": "California",' +
                '    "state abbreviation": "CA"' +
                '  }' +
                ']' +
                '}'
            );

            return res;
        }
    }

    @isTest
    static void testFraudDetectionMismatch() {

        Account acc = new Account(
            Name = 'Test Customer',
            Customer_Region__c = 'NY'
        );
        insert acc;

        Order ord = new Order(
            Name = 'Test Order',
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            BillingPostalCode = '90210'
        );
        insert ord;

        Test.setMock(HttpCalloutMock.class, new ZipApiMock());

        Test.startTest();
        Database.executeBatch(new OrderFraudDetectionBatch(), 1);
        Test.stopTest();

        Order updatedOrder = [
            SELECT Fraud_Flag__c, Fraud_Reason__c
            FROM Order
            WHERE Id = :ord.Id
        ];

        System.assertEquals(true, updatedOrder.Fraud_Flag__c);
        System.assert(updatedOrder.Fraud_Reason__c.contains('mismatch'));
    }
}
