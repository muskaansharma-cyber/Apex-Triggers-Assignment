@RestResource(urlMapping='/usage')
global with sharing class UsageDataRest {

    @HttpPost
    global static void pushUsage() {

        RestRequest req = RestContext.request;
        Map<String, Object> body =
            (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());

        Id subId = (Id) body.get('subId');
        Integer dailyLogins = (Integer) body.get('dailyLogins');

        if(subId == null || dailyLogins == null) {
            throw new AuraHandledException('Invalid payload');
        }

        Subscription__c sub = [
            SELECT Id, Latest_Health_Score__c
            FROM Subscription__c
            WHERE Id = :subId
            LIMIT 1
        ];

        Date today = Date.today();

        Usage_Stats__c stats;
        List<Usage_Stats__c> existing = [
            SELECT Id, Total_Logins__c
            FROM Usage_Stats__c
            WHERE Subscription__c = :subId
            AND Usage_Date__c = :today
            LIMIT 1
        ];

        if(existing.isEmpty()) {
            stats = new Usage_Stats__c(
                Subscription__c = subId,
                Usage_Date__c = today,
                Daily_Logins__c = dailyLogins,
                Total_Logins__c = dailyLogins
            );
        } else {
            stats = existing[0];
            stats.Daily_Logins__c = dailyLogins;
            stats.Total_Logins__c += dailyLogins;
        }

        if(stats.Total_Logins__c < 50) {
            stats.Health_Score__c = 'Low';
        } else if(stats.Total_Logins__c < 200) {
            stats.Health_Score__c = 'Medium';
        } else {
            stats.Health_Score__c = 'High';
        }

        stats.Last_Updated_From_App__c = System.now();
        upsert stats;

        sub.Latest_Health_Score__c = stats.Health_Score__c;
        update sub;
    }
}
