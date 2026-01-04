@IsTest
private class UsageDataRestTest {

    @IsTest
    static void testUsagePush() {

        Account acc = new Account(
            RecordTypeId = Schema.SObjectType.Account
                .getRecordTypeInfosByName()
                .get('PersonAccount')
                .getRecordTypeId(),
            LastName = 'Test User'
        );
        insert acc;

        Subscription__c sub = new Subscription__c(
            Name = 'Test Sub',
            Account__c = acc.Id,
            Status__c = 'Active',
            RecordTypeId = [SELECT Id FROM RecordType
                            WHERE SObjectType='Subscription__c'
                            LIMIT 1].Id
        );
        insert sub;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/usage';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{"subId":"' + sub.Id + '","dailyLogins":60}'
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            UsageDataRest.pushUsage();
        Test.stopTest();

        Usage_Stats__c stats = [
            SELECT Daily_Logins__c, Total_Logins__c, Health_Score__c
            FROM Usage_Stats__c
            WHERE Subscription__c = :sub.Id
            LIMIT 1
        ];

        System.assertEquals(60, stats.Daily_Logins__c);
        System.assertEquals('Medium', stats.Health_Score__c);
    }
}
