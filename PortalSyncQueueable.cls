public class PortalSyncQueueable implements Queueable, Database.AllowsCallouts {

    private Id opportunityId;

    public PortalSyncQueueable(Id opportunityId) {
        this.opportunityId = opportunityId;
    }

    public void execute(QueueableContext qc) {

        Opportunity opp = [
            SELECT Id, Name, StageName,
                   Sync_Status__c,
                   Sync_Retry_Count__c
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];

        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://jsonplaceholder.typicode.com/posts');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            Map<String, Object> payload = new Map<String, Object>{
                'propertyId' => opp.Id,
                'propertyName' => opp.Name,
                'status' => opp.StageName
            };

            req.setBody(JSON.serialize(payload));

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                opp.Sync_Status__c = 'Success';
                opp.Last_Sync_Error__c = null;
            } else {
                throw new CalloutException('HTTP Error: ' + res.getStatus());
            }

        } catch (Exception e) {
            opp.Sync_Status__c = 'Retry';
            opp.Sync_Retry_Count__c =
                (opp.Sync_Retry_Count__c == null ? 1 : opp.Sync_Retry_Count__c + 1);
            opp.Last_Sync_Error__c = e.getMessage();
        }

        opp.Last_Sync_Date__c = System.now();
        update opp;
    }
}
