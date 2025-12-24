trigger OpportunityBeforeUpdate on Opportunity (before update) {

    for (Opportunity opp : Trigger.new) {

        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

        if (opp.Status__c == 'Sold' && oldOpp.Status__c != 'Sold') {

            Integer acceptedOffers = [
                SELECT COUNT()
                FROM Offer__c
                WHERE Property__c = :opp.Id
                AND Outcome__c = 'Accepted'
            ];

            if (acceptedOffers == 0) {
                opp.addError(
                    'You can’t sell a house without an accepted offer.'
                );
            }
        }
    }
}