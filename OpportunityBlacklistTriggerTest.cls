@IsTest
public class OpportunityBlacklistTriggerTest {

    @IsTest
    static void testBlacklistedAccount_PreventsOpportunity() {
        Account blacklistedAcc = new Account(
            LastName = 'Blacklisted User',
            IsPersonAccount = true,
            Blacklisted__c = true
        );
        insert blacklistedAcc;

        Opportunity opp = new Opportunity(
            Name = 'Test Property',
            CloseDate = Date.today().addDays(10),
            StageName = 'Prospecting',
            AccountId = blacklistedAcc.Id
        );

        try {
            insert opp;
            System.assert(false, 'Insert should have thrown an error for blacklisted account');
        } catch (DmlException e) {
            String expectedMessage = 
                'This seller is blacklisted. Property listings cannot be created for this client.';
            System.assertEquals(true, e.getMessage().contains(expectedMessage));
        }
    }

    @IsTest
    static void testNonBlacklistedAccount_AllowsOpportunity() {
        Account normalAcc = new Account(
            LastName = 'Normal User',
            IsPersonAccount = true,
            Blacklisted__c = false
        );
        insert normalAcc;

        Opportunity opp = new Opportunity(
            Name = 'Test Property',
            CloseDate = Date.today().addDays(10),
            StageName = 'Prospecting',
            AccountId = normalAcc.Id
        );

        Test.startTest();
        insert opp;
        Test.stopTest();

        Opportunity insertedOpp = [
            SELECT Id, AccountId
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals(normalAcc.Id, insertedOpp.AccountId);
    }
}
