@IsTest
public class OfferHighestBidTest {

    @IsTest
    static void testHighestBidUpdatedOnInsert() {

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name        = 'Test Opportunity',
            StageName  = 'Prospecting',
            CloseDate = Date.today().addDays(10)
        );
        insert opp;

        Offer__c offer1 = new Offer__c(
            Property__c    = opp.Id,
            Offer_Price__c = 50000
        );

        Test.startTest();
            insert offer1;
        Test.stopTest();

        Opportunity updatedOpp = [
            SELECT Highest_Bid__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals(
            50000,
            updatedOpp.Highest_Bid__c
        );
    }

    @IsTest
    static void testHighestBidUpdatedOnUpdate() {

        Account acc = new Account(
            Name = 'Second Account'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name        = 'Second Opportunity',
            StageName  = 'Prospecting',
            CloseDate = Date.today().addDays(15),
            Highest_Bid__c = 40000
        );
        insert opp;

        Offer__c offer = new Offer__c(
            Property__c    = opp.Id,
            Offer_Price__c = 45000
        );
        insert offer;

        offer.Offer_Price__c = 60000;

        Test.startTest();
            update offer;
        Test.stopTest();

        Opportunity updatedOpp = [
            SELECT Highest_Bid__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals(
            60000,
            updatedOpp.Highest_Bid__c
        );
    }
}
