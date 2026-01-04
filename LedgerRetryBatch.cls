
public class LedgerRetryBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
            'SELECT Id FROM Subscription__c ' +
            'WHERE Ledger_Sync_Status__c = \'Retry\' ' +
            'AND Ledger_Sync_Attempts__c < 3'
        );
    }

    public void execute(Database.BatchableContext bc, List<Subscription__c> scope){
        for(Subscription__c sub : scope){
            System.enqueueJob(new LedgerSyncQueueable(sub.Id));
        }
    }

    public void finish(Database.BatchableContext bc){}
}
