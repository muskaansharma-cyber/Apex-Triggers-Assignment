@IsTest
public class CloneOfferQueueableTest {

    @IsTest
    static void testDeepCloneOfferWithClauses() {

        Account buyer = new Account(Name = 'Test Buyer');
        insert buyer;

        Opportunity property = new Opportunity(
            Name = 'Test Property',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert property;

        Offer__c offer = new Offer__c(
            Name = 'Original Offer',
            Buyer__c = buyer.Id,
            Property__c = property.Id,
            Offer_Date__c = Date.today(),
            Offer_Price__c = 800000,
            Outcome__c = 'Open'
        );
        insert offer;

        List<Clause__c> clauses = new List<Clause__c>();
        for (Integer i = 0; i < 120; i++) {
            clauses.add(new Clause__c(
                Name = 'Clause ' + i,
                Offer__c = offer.Id,
                Clause_Type__c = 'Legal',
                Clause_Text__c = 'Clause text ' + i,
                Sort_Order__c = i
            ));
        }
        insert clauses;

        Test.startTest();
        System.enqueueJob(
            new CloneOfferQueueable(offer.Id, null, null)
        );
        Test.stopTest();

        Offer__c clonedOffer = [
            SELECT Id, Buyer__c, Property__c, Outcome__c
            FROM Offer__c
            WHERE Name LIKE '%Clone%'
            LIMIT 1
        ];

        System.assertNotEquals(null, clonedOffer);
        System.assertEquals('Open', clonedOffer.Outcome__c);
        System.assertEquals(offer.Buyer__c, clonedOffer.Buyer__c);
        System.assertEquals(offer.Property__c, clonedOffer.Property__c);

        Integer clonedClauseCount = [
            SELECT COUNT()
            FROM Clause__c
            WHERE Offer__c = :clonedOffer.Id
        ];

        System.assertEquals(120, clonedClauseCount);
    }
}
