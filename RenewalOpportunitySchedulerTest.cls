@isTest
private class RenewalOpportunitySchedulerTest {
    @isTest
    static void testRenewalOpportunityGeneration() {
        Account acc = new Account(
            LastName='Test Person', 
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND Name='Person Account' LIMIT 1].Id
        );
        insert acc;

        Product2 prod = new Product2(Name='Pro Plan', isActive=true);
        insert prod;

        Contact con = new Contact(LastName='Test', AccountId=acc.Id);
        insert con;

        Contract c = new Contract(AccountId=acc.Id, StartDate=Date.today(), Status='Activated');
        insert c;

        Subscription__c sub = new Subscription__c(
            Name = 'Test Subscription',
            Account__c = acc.Id,
            Contact__c = con.Id,
            Contract__c = c.Id,
            Product__c = prod.Id,
            Status__c = 'Active',
            End_Date_Actual__c = Date.today().addDays(90),
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Subscription__c' LIMIT 1].Id
        );
        insert sub;

        Test.startTest();
            String cronExp = '0 0 0 * * ?';
            System.schedule('Test Renewal Opp', cronExp, new RenewalOpportunityScheduler());
        Test.stopTest();

        Opportunity opp = [SELECT Id, Name, AccountId, Type, StageName, Subscription__c
                           FROM Opportunity
                           WHERE Subscription__c = :sub.Id
                           LIMIT 1];

        System.assertEquals('Renewal', opp.Type);
        System.assertEquals('Prospecting', opp.StageName);
        System.assertEquals(acc.Id, opp.AccountId);
        System.assert(opp.Name.contains(sub.Name));
    }
}
