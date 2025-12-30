public class PartReorderFuture {

    @future(callout=true)
    public static void checkInventory(Set<Id> workOrderIds) {

        List<WorkOrder> wos = [
            SELECT Id, Parts_Used__c, Reorder_Required__c
            FROM WorkOrder
            WHERE Id IN :workOrderIds
            AND Parts_Used__c != NULL
        ];

        List<Task> tasksToInsert = new List<Task>();
        List<WorkOrder> wosToUpdate = new List<WorkOrder>();

        for (WorkOrder wo : wos) {

            // Prevent duplicate reorder
            if (wo.Reorder_Required__c == true) {
                continue;
            }

            try {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(
                    'https://mock-inventory-api.com/parts?name=' +
                    EncodingUtil.urlEncode(wo.Parts_Used__c, 'UTF-8')
                );
                req.setMethod('GET');

                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {

                    Map<String, Object> data =
                        (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                    Integer stockLevel = (Integer) data.get('stock');

                    wo.Stock_Level__c = stockLevel;

                    // Low stock threshold
                    if (stockLevel < 10) {

                        wo.Reorder_Required__c = true;

                        Task t = new Task(
                            Subject = 'Low Stock – Reorder Parts',
                            Status = 'Not Started',
                            Priority = 'High',
                            WhatId = wo.Id
                        );

                        tasksToInsert.add(t);
                    }

                    wosToUpdate.add(wo);
                }
            }
            catch (Exception e) {
                wo.Inventory_API_Error__c = e.getMessage();
                wosToUpdate.add(wo);
            }
        }

        if (!wosToUpdate.isEmpty()) {
            update wosToUpdate;
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}
