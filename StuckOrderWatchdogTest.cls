@isTest
private class StuckOrderWatchdogTest {
    @isTest
    static void testStuckOrderEscalation() {
        Account acc = new Account(LastName='Person Test', 
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND Name='Person Account' LIMIT 1].Id);
        insert acc;

        Order__c ord = new Order__c(
            Name='Test Order 1',
            Account__c=acc.Id,
            Status__c='Processing'
        );
        insert ord;

        Test.setCreatedDate(ord.Id, System.now().addDays(-6));

        Test.startTest();
            String cronExp = '0 0 0 * * ?';
            System.schedule('Stuck Order Watchdog', cronExp, new StuckOrderWatchdog());
        Test.stopTest();

        ord = [SELECT Status__c FROM Order__c WHERE Id = :ord.Id];
        System.assertEquals('Escalated', ord.Status__c);

        Case c = [SELECT Id, Subject, AccountId FROM Case WHERE AccountId = :acc.Id LIMIT 1];
        System.assert(c.Subject.contains('Test Order 1'));
    }
}
