public class OrderFulfillmentQueueable implements Queueable, Database.AllowsCallouts {

    private Id orderId;

    public OrderFulfillmentQueueable(Id orderId) {
        this.orderId = orderId;
    }

    public void execute(QueueableContext qc) {

        Order ord = [
            SELECT Id, OrderNumber, AccountId, TotalAmount,
                   Fulfillment_Status__c, Fulfillment_Attempts__c
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://jsonplaceholder.typicode.com/posts');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        req.setBody(JSON.serialize(new Map<String, Object>{
            'orderId' => ord.Id,
            'orderNumber' => ord.OrderNumber,
            'accountId' => ord.AccountId,
            'amount' => ord.TotalAmount
        }));

        try {
            HttpResponse res = new Http().send(req);

            if(res.getStatusCode() == 201 || res.getStatusCode() == 200){
                ord.Fulfillment_Status__c = 'Sent';
                ord.External_Fulfillment_Id__c = 'EXT-' + ord.OrderNumber;
            } else {
                ord.Fulfillment_Status__c = 'Failed';
                ord.Fulfillment_Attempts__c++;
                ord.Last_Fulfillment_Error__c = res.getBody();
            }

        } catch(Exception e) {
            ord.Fulfillment_Status__c = 'Failed';
            ord.Fulfillment_Attempts__c++;
            ord.Last_Fulfillment_Error__c = e.getMessage();
        }

        ord.Fulfillment_Requested_Date__c = System.now();
        update ord;
    }
}
