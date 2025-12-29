@IsTest
public class CustomerStatsTriggerTest {

    @IsTest
    static void testCustomerStatsAfterOrderInsert() {

        Id personRtId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Account'
            AND IsPersonType = true
            LIMIT 1
        ].Id;

        Account personAcc = new Account(
            RecordTypeId      = personRtId,
            LastName          = 'Test Customer',
            Lifetime_Spend__c = 100
        );
        insert personAcc;

        Order ord = new Order(
            AccountId     = personAcc.Id,
            Status        = 'Draft',
            EffectiveDate = Date.today(),
            Order_Date__c = Date.today(),
            TotalAmount   = 250
        );

        Test.startTest();
            insert ord;
        Test.stopTest();

        Account updatedAcc = [
            SELECT Lifetime_Spend__c, Last_Order_Date__c
            FROM Account
            WHERE Id = :personAcc.Id
        ];

        System.assertEquals(
            350,
            updatedAcc.Lifetime_Spend__c
        );

        System.assertEquals(
            Date.today(),
            updatedAcc.Last_Order_Date__c
        );
    }
}
