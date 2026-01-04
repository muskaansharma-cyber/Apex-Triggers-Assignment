@isTest
private class ReturnRequestAPITest {

    @isTest
    static void testReturnRequest() {

        Account acc = new Account(
            LastName = 'Person',
            RecordTypeId = [
                SELECT Id FROM RecordType
                WHERE SObjectType='Account'
                AND Name='Person Account'
                LIMIT 1
            ].Id
        );
        insert acc;

        Product2 prod = new Product2(Name='Test Product', IsActive=true);
        insert prod;

        Pricebook2 stdPb = [SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1];
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPb.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        Order ord = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = stdPb.Id
        );
        insert ord;

        OrderItem oi = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert oi;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/return-request/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            JSON.serialize(new Map<String,Object>{
                'orderId' => ord.Id,
                'itemId' => oi.Id,
                'reason' => 'Damaged'
            })
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            ReturnRequestAPI.createReturn();
        Test.stopTest();

        Case c = [
            SELECT Id, Return_Type__c, Return_Reason__c, Order__c, Order_Product__c
            FROM Case
            WHERE Order__c = :ord.Id
            LIMIT 1
        ];

        System.assertEquals('Return', c.Return_Type__c);
        System.assertEquals('Damaged', c.Return_Reason__c);

        oi = [SELECT Return_Requested__c FROM OrderItem WHERE Id = :oi.Id];
        System.assertEquals(true, oi.Return_Requested__c);
    }
}
