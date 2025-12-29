@IsTest
public class InventoryDecrementTriggerTest {

    @IsTest
    static void testInventoryDecrementOnOrderShipped() {

        Product2 prod = new Product2(
            Name                 = 'Test Product',
            IsActive             = true,
            Quantity_On_Hand__c  = 50
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
            UnitPrice    = 100,
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
            EffectiveDate = Date.today(),
            Order_Status__c = 'Processing'
        );
        insert ord;

        OrderItem oi = new OrderItem(
            OrderId        = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity       = 5,
            UnitPrice      = 100
        );
        insert oi;

        ord.Order_Status__c = 'Shipped';

        Test.startTest();
            update ord;
        Test.stopTest();

        Product2 updatedProd = [
            SELECT Quantity_On_Hand__c
            FROM Product2
            WHERE Id = :prod.Id
        ];

        System.assertEquals(
            45,
            updatedProd.Quantity_On_Hand__c
        );
    }
}
