@isTest
private class OrderSplitQueueableTest {

    @isTest
    static void testOrderSplit() {

        Account acc = new Account(
            LastName='Person Test',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND Name='Person Account' LIMIT 1].Id
        );
        insert acc;

        Order__c order = new Order__c(
            Name='Test Order',
            AccountId=acc.Id,
            Status__c='Processing'
        );
        insert order;

        Product2 prod = new Product2(Name='Test Product', isActive=true);
        insert prod;

        List<Order_Product__c> lineItems = new List<Order_Product__c>();
        for(Integer i=0; i<120; i++){
            lineItems.add(new Order_Product__c(
                Order__c = order.Id,
                Product__c = prod.Id,
                Quantity__c = 1,
                Weight__c = 2,
                Price__c = 100
            ));
        }
        insert lineItems;

        Test.startTest();
            System.enqueueJob(new OrderSplitQueueable(order.Id, 0));
        Test.stopTest();

        List<Shipment__c> shipments = [SELECT Id, Total_Weight__c FROM Shipment__c WHERE Order__c = :order.Id];
        System.assert(shipments.size() == 3, 'Should create 3 shipments for 120 line items with batch size 50');

        List<Shipment_Line_Item__c> shipmentLines = [SELECT Id FROM Shipment_Line_Item__c WHERE Shipment__c IN :shipments];
        System.assert(shipmentLines.size() == 120, 'All line items should be cloned into shipments');
    }
}
