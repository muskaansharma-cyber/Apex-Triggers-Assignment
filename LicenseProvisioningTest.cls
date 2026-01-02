@isTest
private class LicenseProvisioningTest {

    @isTest
    static void testLicenseProvisioningPersonAccount() {
        Account acc = new Account(
            LastName='Person Test', 
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND Name='Person Account' LIMIT 1].Id
        );
        insert acc;

        Product2 prod = new Product2(Name='Pro Plan', isActive=true);
        insert prod;

        Contract c = new Contract(AccountId=acc.Id, StartDate=Date.today(), Status='Activated');
        insert c;

        Subscription__c sub = new Subscription__c(
            Name='Test Sub',
            Account__c=acc.Id,
            Product__c=prod.Id,
            Status__c='Active',
            RecordTypeId=[SELECT Id FROM RecordType WHERE SObjectType='Subscription__c' LIMIT 1].Id
        );
        insert sub;

        Test.startTest();
            System.enqueueJob(new LicenseKeyGenerator(sub.Id));
        Test.stopTest();

        sub = [SELECT License_Key__c, License_Provisioned__c FROM Subscription__c WHERE Id = :sub.Id];
        System.assert(sub.License_Provisioned__c, 'License should be provisioned');
        System.assertNotEquals(null, sub.License_Key__c, 'License key should be generated');
    }
}
