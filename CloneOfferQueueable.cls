public class CloneOfferQueueable implements Queueable {

    private Id sourceOfferId;
    private Id targetOfferId;
    private Id lastClauseId;

    public CloneOfferQueueable(
        Id sourceOfferId,
        Id targetOfferId,
        Id lastClauseId
    ) {
        this.sourceOfferId = sourceOfferId;
        this.targetOfferId = targetOfferId;
        this.lastClauseId = lastClauseId;
    }

    public void execute(QueueableContext qc) {

        if (targetOfferId == null) {

            Offer__c source = [
                SELECT Name, Buyer__c, Offer_Date__c,
                       Offer_Price__c, Property__c
                FROM Offer__c
                WHERE Id = :sourceOfferId
                LIMIT 1
            ];

            Offer__c cloned = source.clone(false, true, false, false);
            cloned.Name = source.Name + ' (Clone)';
            cloned.Outcome__c = 'Open'; 

            insert cloned;

            System.enqueueJob(
                new CloneOfferQueueable(
                    sourceOfferId,
                    cloned.Id,
                    null
                )
            );
            return;
        }

        List<Clause__c> clauses = [
            SELECT Id, Name, Clause_Type__c,
                   Clause_Text__c, Sort_Order__c
            FROM Clause__c
            WHERE Offer__c = :sourceOfferId
            AND (:lastClauseId = NULL OR Id > :lastClauseId)
            ORDER BY Id
            LIMIT 100
        ];
            WHERE Offer__c = :sourceOfferId
            AND (:lastClauseId = NULL OR Id > :lastClauseId)
            ORDER BY Id
            LIMIT 100
        ];

        if (clauses.isEmpty()) {
            return;
        }

        List<Clause__c> clones = new List<Clause__c>();
        for (Clause__c c : clauses) {
            Clause__c clone = c.clone(false, true, false, false);
            clone.Offer__c = targetOfferId;
            clones.add(clone);
        }

        insert clones;

        if (clauses.size() == 100) {
            System.enqueueJob(
                new CloneOfferQueueable(
                    sourceOfferId,
                    targetOfferId,
                    clauses[clauses.size() - 1].Id
                )
            );
        }
    }
}
