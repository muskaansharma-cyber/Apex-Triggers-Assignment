trigger OfferTrigger on Offer__c (after update) {

    Set<Id> propertyIds = new Set<Id>();
    Set<Id> acceptedOfferIds = new Set<Id>();

    for (Offer__c newOffer : Trigger.new) {
        Offer__c oldOffer = Trigger.oldMap.get(newOffer.Id);
        if (newOffer.Outcome__c == 'Accepted' &&
            oldOffer.Outcome__c != 'Accepted') {

            propertyIds.add(newOffer.Property__c);
            acceptedOfferIds.add(newOffer.Id);
        }
    }

    if (propertyIds.isEmpty()) {
        return;
    }

    List<Offer__c> offersToReject = [
        SELECT Id, Outcome__c
        FROM Offer__c
        WHERE Property__c IN :propertyIds
        AND Outcome__c = 'Open'
        AND Id NOT IN :acceptedOfferIds
    ];

    for (Offer__c offer : offersToReject) {
        offer.Outcome__c = 'Rejected';
    }
    
    if (!offersToReject.isEmpty()) {
        update offersToReject;
    }
}