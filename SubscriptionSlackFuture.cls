public with sharing class SubscriptionSlackFuture {

    @future(callout=true)
    public static void notifyProSubscription(Set<Id> subscriptionIds) {

        List<Subscription__c> subs = [
            SELECT Id,
                   Name,
                   Total_ARR_Amount__c,
                   Status__c,
                   Product__r.Name,
                   Account__r.Name,
                   Account__r.total_ARR__c
            FROM Subscription__c
            WHERE Id IN :subscriptionIds
            AND Product__r.Name = 'Pro'
        ];

        Http http = new Http();

        for (Subscription__c sub : subs) {

            Map<String, Object> payload = new Map<String, Object>();
            payload.put(
                'text',
                '*PRO Subscription Sold!*\n' +
                '*Account:* ' + sub.Account__r.Name + '\n' +
                '*Subscription:* ' + sub.Name + '\n' +
                '*Product:* ' + sub.Product__r.Name + '\n' +
                '*ARR:* ' + sub.Total_ARR_Amount__c
            );

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint('https://jsonplaceholder.typicode.com/posts');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(payload));

            http.send(req);
        }
    }
}
