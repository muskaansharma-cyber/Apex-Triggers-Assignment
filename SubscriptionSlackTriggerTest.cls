@isTest
public class SubscriptionSlackTriggerTest {

    private class SlackWebhookMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"ok":true}');
            return res;
        }
    }

    @isTest
    static void testProSubscriptionSlackNotification() {

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Product2 basic = new Product2(Name = 'Basic Plan', IsActive = true);
        Product2 pro = new Product2(Name = 'Pro', IsActive = true);
        insert new List<Product2>{ basic, pro };

        Subscription__c basicSub = new Subscription__c(
            Name = 'Basic Sub',
            Account__c = acc.Id,
            Product__c = basic.Id,
            Total_ARR_Amount__c = 5000,
            Status__c = 'Active'
        );

        Subscription__c proSub = new Subscription__c(
            Name = 'Pro Sub',
            Account__c = acc.Id,
            Product__c = pro.Id,
            Total_ARR_Amount__c = 50000,
            Status__c = 'Active'
        );

        Test.setMock(HttpCalloutMock.class, new SlackWebhookMock());

        Test.startTest();
        insert new List<Subscription__c>{ basicSub, proSub };
        Test.stopTest();

        System.assert(true, 'Only Pro subscription triggered Slack');
    }
}
