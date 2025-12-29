@IsTest
public class NoDuplicateActiveSubscriptionTest {

    @IsTest
    static void testDuplicateActiveSubscriptionBlocked() {

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Product2 prod = new Product2(
            Name     = 'Test Product',
            IsActive = true
        );
        insert prod;

        Subscription__c existingSub = new Subscription__c(
            Account__c = acc.Id,
            Product__c = prod.Id,
            Status__c  = 'Active'
        );
        insert existingSub;

        Subscription__c newSub = new Subscription__c(
            Account__c = acc.Id,
            Product__c = prod.Id,
            Status__c  = 'Active'
        );

        Test.startTest();
            Database.SaveResult sr = Database.insert(newSub, false);
        Test.stopTest();

        System.assertEquals(
            false,
            sr.isSuccess()
        );

        System.assertEquals(
            'An Active subscription already exists for this Account and Product.',
            sr.getErrors()[0].getMessage()
        );
    }

    @IsTest
    static void testActiveSubscriptionAllowedForDifferentProduct() {

        Account acc = new Account(
            Name = 'Another Account'
        );
        insert acc;

        Product2 prod1 = new Product2(
            Name     = 'Product One',
            IsActive = true
        );
        insert prod1;

        Product2 prod2 = new Product2(
            Name     = 'Product Two',
            IsActive = true
        );
        insert prod2;

        Subscription__c sub1 = new Subscription__c(
            Account__c = acc.Id,
            Product__c = prod1.Id,
            Status__c  = 'Active'
        );
        insert sub1;

        Subscription__c sub2 = new Subscription__c(
            Account__c = acc.Id,
            Product__c = prod2.Id,
            Status__c  = 'Active'
        );

        Test.startTest();
            Database.SaveResult sr = Database.insert(sub2, false);
        Test.stopTest();

        System.assertEquals(
            true,
            sr.isSuccess()
        );
    }
}
