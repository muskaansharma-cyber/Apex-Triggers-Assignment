@IsTest
public class MarginProtectionTriggerTest {

    @IsTest
    static void testOrderItemBlockedBelowFloorPrice() {

        Product2 prod = new Product2(
            Name            = 'Test Product',
            IsActive        = true,
            Floor_Price__c  = 100
        );
        insert prod;

        Pricebook2 stdPb = [
            SELECT Id
            FROM Pricebook2
            WHERE IsStandard = true
            LIMIT 1
        ];

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPb.Id,
            Product2Id   = prod.Id,
            UnitPrice    = 150,
            IsActive     = true
        );
        insert pbe;

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Order ord = new Order(
            AccountId     = acc.Id,
            Status        = 'Draft',
            EffectiveDate = Date.today()
        );
        insert ord;

        OrderItem oi = new OrderItem(
            OrderId          = ord.Id,
            PricebookEntryId = pbe.Id,
            Product2Id       = prod.Id,
            Quantity         = 1,
            UnitPrice        = 80
        );

        Test.startTest();
            Database.SaveResult sr = Database.insert(oi, false);
        Test.stopTest();

        System.assertEquals(
            false,
            sr.isSuccess()
        );

        System.assertEquals(
            'Unit Price cannot be below the Floor Price (100).',
            sr.getErrors()[0].getMessage()
        );
    }

    @IsTest
    static void testOrderItemAllowedAboveFloorPrice() {

        Product2 prod = new Product2(
            Name            = 'Valid Product',
            IsActive        = true,
            Floor_Price__c  = 100
        );
        insert prod;

        Pricebook2 stdPb = [
            SELECT Id
            FROM Pricebook2
            WHERE IsStandard = true
            LIMIT 1
        ];

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPb.Id,
            Product2Id   = prod.Id,
            UnitPrice    = 150,
            IsActive     = true
        );
        insert pbe;

        Account acc = new Account(
            Name = 'Valid Account'
        );
        insert acc;

        Order ord = new Order(
            AccountId     = acc.Id,
            Status        = 'Draft',
            EffectiveDate = Date.today()
        );
        insert ord;

        OrderItem oi = new OrderItem(
            OrderId          = ord.Id,
            PricebookEntryId = pbe.Id,
            Product2Id       = prod.Id,
            Quantity         = 1,
            UnitPrice        = 120
        );

        Test.startTest();
            Database.SaveResult sr = Database.insert(oi, false);
        Test.stopTest();

        System.assertEquals(
            true,
            sr.isSuccess()
        );
    }
}
