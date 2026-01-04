@RestResource(urlMapping='/return-request/*')
global with sharing class ReturnRequestAPI {

    @HttpPost
    global static void createReturn() {

        RestRequest req = RestContext.request;
        Map<String, Object> body =
            (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());

        Id orderId = (Id) body.get('orderId');
        Id itemId  = (Id) body.get('itemId');
        String reason = (String) body.get('reason');

        Order ord = [
            SELECT Id, AccountId
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];

        OrderItem oi = [
            SELECT Id, OrderId
            FROM OrderItem
            WHERE Id = :itemId
            AND OrderId = :orderId
            LIMIT 1
        ];

        Case c = new Case(
            Subject = 'Return Request - Order ' + ord.OrderNumber,
            Status = 'New',
            Origin = 'Web',
            Return_Type__c = 'Return',
            Return_Reason__c = reason,
            Order__c = ord.Id,
            Order_Product__c = oi.Id,
            AccountId = ord.AccountId
        );
        insert c;

        oi.Return_Requested__c = true;
        update oi;
    }
}
