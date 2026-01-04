@isTest
private class LedgerSyncTest {

    @isTest
    static void testLedgerSyncRetryFlow(){

        Account acc = new Account(LastName='Test PA');
        insert acc;

        Subscription__c sub = new Subscription__c(
            Name = 'Test Sub',
            Account__c = acc.Id,
            Final_Invoice_Amount__c = 5000,
            Invoice_Finalized__c = true,
            Ledger_Sync_Status__c = 'Pending',
            Ledger_Sync_Attempts__c = 0,
            Start_Date_Actual__c = Date.today().addMonths(-1),
            End_Date_Actual__c = Date.today()
        );
        insert sub;

      Test.setMock(HttpCalloutMock.class, new LedgerSyncFailureMock());


        Test.startTest();
            System.enqueueJob(new LedgerSyncQueueable(sub.Id));
            Database.executeBatch(new LedgerRetryBatch(), 1);
        Test.stopTest();

        sub = [SELECT Ledger_Sync_Status__c, Ledger_Sync_Attempts__c
               FROM Subscription__c WHERE Id = :sub.Id];

        System.assert(sub.Ledger_Sync_Attempts__c > 0);
    }
}
