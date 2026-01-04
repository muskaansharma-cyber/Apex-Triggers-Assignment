global class ERPInventoryRetryBatch
        implements Database.Batchable<SObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM WorkOrderLineItem
            WHERE ERP_Sync_Status__c = 'Failed'
            AND ERP_Sync_Attempts__c < 3
            AND Inventory_Synced__c = false
        ]);
    }

    global void execute(Database.BatchableContext bc, List<WorkOrderLineItem> scope) {
        List<Id> retryIds = new List<Id>();
        for (WorkOrderLineItem w : scope) {
            retryIds.add(w.Id);
        }

        if (!retryIds.isEmpty()) {
            System.enqueueJob(new ERPInventorySyncQueueable(retryIds));
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('ERP Inventory Retry Batch finished');
    }
}
