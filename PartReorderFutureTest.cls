@isTest
public class PartReorderFutureTest {

    private class InventoryApiMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"stock":5}');
            return res;
        }
    }

    @testSetup
    static void setupData() {

        Account acc = new Account(Name = 'Test Customer');
        insert acc;

        WorkOrder wo = new WorkOrder(
            Subject = 'Repair Job',
            Status = 'New',
            AccountId = acc.Id
        );
        insert wo;
    }

    @isTest
    static void testLowStockReorder() {

        Test.setMock(HttpCalloutMock.class, new InventoryApiMock());

        WorkOrder wo = [
            SELECT Id, Parts_Used__c
            FROM WorkOrder
            LIMIT 1
        ];

        Test.startTest();
            wo.Parts_Used__c = 'Brake Pad';
            update wo;
        Test.stopTest();

        WorkOrder updatedWo = [
            SELECT Reorder_Required__c, Stock_Level__c
            FROM WorkOrder
            WHERE Id = :wo.Id
        ];

        System.assertEquals(true, updatedWo.Reorder_Required__c);
        System.assertEquals(5, updatedWo.Stock_Level__c);

        Task t = [
            SELECT Subject, WhatId
            FROM Task
            WHERE WhatId = :wo.Id
            LIMIT 1
        ];

        System.assertEquals('Low Stock - Reorder Parts', t.Subject);
    }
}
