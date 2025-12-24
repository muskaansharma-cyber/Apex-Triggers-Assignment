trigger OfferHighestBid on Offer__c (after insert, after update) {

    Set<Id> oppIds = new Set<Id>();

    for (Offer__c offer : Trigger.new) {
        if (offer.Property__c != null) {
            oppIds.add(offer.Property__c);
        }
    }

    if (oppIds.isEmpty()) {
        return;
    }

    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
        [SELECT Id, Highest_Bid__c
         FROM Opportunity
         WHERE Id IN :oppIds]
    );

    for (Offer__c offer : Trigger.new) {

        Opportunity opp = oppMap.get(offer.Property__c);
        if (opp == null) continue;

        if (
            opp.Highest_Bid__c == null ||
            offer.Offer_Price__c > opp.Highest_Bid__c
        ) {
            opp.Highest_Bid__c = offer.Offer_Price__c;
        }
    }

    update oppMap.values();
}