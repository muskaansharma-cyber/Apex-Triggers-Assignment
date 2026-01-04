public class ERPInventorySyncQueueable
        implements Queueable, Database.AllowsCallouts {

    private List<Id> woliIds;

    public ERPInventorySyncQueueable(List<Id> ids) {
        this.woliIds = ids;
    }

    public void execute(QueueableContext qc) {

        List<WorkOrderLineItem> items = [
            SELECT Id, Quantity, Product2Id,
                   Inventory_Synced__c,
                   ERP_Sync_Attempts__c
            FROM WorkOrderLineItem
            WHERE Id IN :woliIds
            AND Inventory_Synced__c = false
        ];

        Http http = new Http();
        List<WorkOrderLineItem> updates = new List<WorkOrderLineItem>();

        for (WorkOrderLineItem item : items) {
            try {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://jsonplaceholder.typicode.com/posts');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');

                req.setBody(JSON.serialize(new Map<String, Object>{
                    'lineItemId' => item.Id,
                    'productId'  => item.Product2Id,
                    'quantity'   => item.Quantity
                }));

                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 201) {
                    item.Inventory_Synced__c = true;
                    item.ERP_Sync_Status__c = 'Success';
                } else {
                    throw new CalloutException('ERP error');
                }

            } catch (Exception e) {
                item.ERP_Sync_Status__c = 'Failed';
                item.ERP_Sync_Attempts__c =
                    (item.ERP_Sync_Attempts__c == null ? 1 : item.ERP_Sync_Attempts__c + 1);
                item.ERP_Sync_Error__c = e.getMessage();
            }

            updates.add(item);
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }
}
