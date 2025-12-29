@IsTest
public class OpportunityBeforeUpdateTest {

    @IsTest
    static void testSoldBlockedWithoutAcceptedOffer() {

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name       = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Status__c = 'Open'
        );
        insert opp;

        opp.Status__c = 'Sold';

        Test.startTest();
            Database.SaveResult sr = Database.update(opp, false);
        Test.stopTest();

        System.assertEquals(
            false,
            sr.isSuccess()
        );

        System.assertEquals(
            'You can’t sell a house without an accepted offer.',
            sr.getErrors()[0].getMessage()
        );
    }

    @IsTest
    static void testSoldAllowedWithAcceptedOffer() {

        Account acc = new Account(
            Name = 'Second Account'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name       = 'Second Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(15),
            Status__c = 'Open'
        );
        insert opp;

        Offer__c offer = new Offer__c(
            Property__c = opp.Id,
            Outcome__c  = 'Accepted'
        );
        insert offer;

        opp.Status__c = 'Sold';

        Test.startTest();
            Database.SaveResult sr = Database.update(opp, false);
        Test.stopTest();

        System.assertEquals(
            true,
            sr.isSuccess()
        );
    }
}
