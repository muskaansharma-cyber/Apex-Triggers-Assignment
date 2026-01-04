global class PortalSyncRetryBatch
    implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id
            FROM Opportunity
            WHERE Sync_Status__c = 'Retry'
            AND (Sync_Retry_Count__c = NULL OR Sync_Retry_Count__c < 3)
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {

        for (Opportunity opp : scope) {
            System.enqueueJob(new PortalSyncQueueable(opp.Id));
        }
    }

    global void finish(Database.BatchableContext bc) {
       
    }
}
