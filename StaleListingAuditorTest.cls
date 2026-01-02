@IsTest
public class StaleListingAuditorTest {

    @IsTest
    static void testStaleListingsAreReviewedAndEmailed() {

        User ownerUser = [
            SELECT Id, Name
            FROM User
            WHERE IsActive = true
            LIMIT 1
        ];

        Opportunity staleOpp = new Opportunity(
            Name = 'Stale Property',
            StageName = 'Available',
            CloseDate = Date.today().addDays(30),
            OwnerId = ownerUser.Id
        );
        insert staleOpp;

        Test.setCreatedDate(staleOpp.Id, System.now().addDays(-61));

        Opportunity freshOpp = new Opportunity(
            Name = 'Fresh Property',
            StageName = 'Available',
            CloseDate = Date.today().addDays(30),
            OwnerId = ownerUser.Id
        );
        insert freshOpp;

        Test.startTest();

        StaleListingAuditor auditor = new StaleListingAuditor();
        auditor.execute(null);

        Test.stopTest();

        Opportunity updatedStaleOpp = [
            SELECT StageName
            FROM Opportunity
            WHERE Id = :staleOpp.Id
        ];
        System.assertEquals(
            'Review',
            updatedStaleOpp.StageName,
            'Stale property should be moved to Review'
        );

        Opportunity updatedFreshOpp = [
            SELECT StageName
            FROM Opportunity
            WHERE Id = :freshOpp.Id
        ];
        System.assertEquals(
            'Available',
            updatedFreshOpp.StageName,
            'Fresh property should remain Available'
        );
    }
}
