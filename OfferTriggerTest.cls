@IsTest
public class OfferTriggerTest {

    @IsTest
    static void testOtherOffersRejectedWhenOneAccepted() {

        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name       = 'Test Property',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10)
        );
        insert opp;

        Offer__c offer1 = new Offer__c(
            Property__c = opp.Id,
            Outcome__c  = 'Open'
        );

        Offer__c offer2 = new Offer__c(
            Property__c = opp.Id,
            Outcome__c  = 'Open'
        );

        insert new List<Offer__c>{ offer1, offer2 };

        offer1.Outcome__c = 'Accepted';

        Test.startTest();
            update offer1;
        Test.stopTest();

        Map<Id, Offer__c> offerMap = new Map<Id, Offer__c>(
            [
                SELECT Outcome__c
                FROM Offer__c
                WHERE Id IN :new List<Id>{ offer1.Id, offer2.Id }
            ]
        );

        System.assertEquals(
            'Accepted',
            offerMap.get(offer1.Id).Outcome__c
        );

        System.assertEquals(
            'Rejected',
            offerMap.get(offer2.Id).Outcome__c
        );
    }
}
