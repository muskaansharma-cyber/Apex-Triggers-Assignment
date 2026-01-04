
public class LedgerSyncQueueable implements Queueable, Database.AllowsCallouts {

    private Id subId;

    public LedgerSyncQueueable(Id subId){
        this.subId = subId;
    }

    public void execute(QueueableContext qc){
        Subscription__c sub = [
            SELECT Id, Account__c, Final_Invoice_Amount__c, Start_Date_Actual__c,
                   End_Date_Actual__c, Product__c, Ledger_Sync_Status__c,
                   Ledger_Sync_Attempts__c, Invoice_Finalized__c
            FROM Subscription__c
            WHERE Id = :subId
            LIMIT 1
        ];

        if(!sub.Invoice_Finalized__c) return;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Ledger_Named_Credential');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        req.setBody(JSON.serialize(new Map<String,Object>{
            'subscriptionId' => sub.Id,
            'accountId' => sub.Account__c,
            'amount' => sub.Final_Invoice_Amount__c,
            'startDate' => sub.Start_Date_Actual__c,
            'endDate' => sub.End_Date_Actual__c,
            'productId' => sub.Product__c
        }));

        try{
            HttpResponse res = new Http().send(req);

            if(res.getStatusCode() == 200){
                sub.Ledger_Sync_Status__c = 'Success';
            } else {
                sub.Ledger_Sync_Attempts__c++;
                sub.Ledger_Sync_Status__c =
                    sub.Ledger_Sync_Attempts__c >= 3 ? 'Failed' : 'Retry';
            }
        } catch(Exception e){
            sub.Ledger_Sync_Attempts__c++;
            sub.Ledger_Sync_Status__c =
                sub.Ledger_Sync_Attempts__c >= 3 ? 'Failed' : 'Retry';
        }

        sub.Last_Ledger_Sync_Date__c = System.now();
        update sub;
    }
}
