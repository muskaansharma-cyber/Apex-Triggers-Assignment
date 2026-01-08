/*
 * Trigger: OfferTrigger
 * Object: Offer__c
 * Description: Automatically rejects all other open Offers
 *              when an Offer is marked as Accepted.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger OfferTrigger on Offer__c(after update) {
  // Store Property Ids that have an accepted Offer
  Set<Id> propertyIds = new Set<Id>();

  // Store newly accepted Offer Ids
  Set<Id> acceptedOfferIds = new Set<Id>();

  // Identify Offers whose Outcome changed to Accepted
  for (Offer__c newOffer : Trigger.new) {
    // Get the previous version of the Offer
    Offer__c oldOffer = Trigger.oldMap.get(newOffer.Id);

    // Check if Offer is newly accepted
    if (
      newOffer.Outcome__c == 'Accepted' &&
      oldOffer.Outcome__c != 'Accepted'
    ) {
      propertyIds.add(newOffer.Property__c);
      acceptedOfferIds.add(newOffer.Id);
    }
  }

  // Exit early if no Offers were accepted
  if (propertyIds.isEmpty()) {
    return;
  }

  // Fetch all other open Offers for the same Properties
  List<Offer__c> offersToReject = [
    SELECT Id, Outcome__c
    FROM Offer__c
    WHERE
      Property__c IN :propertyIds
      AND Outcome__c = 'Open'
      AND Id NOT IN :acceptedOfferIds
  ];

  // Mark remaining Offers as Rejected
  for (Offer__c offer : offersToReject) {
    offer.Outcome__c = 'Rejected';
  }

  // Update rejected Offers
  if (!offersToReject.isEmpty()) {
    update offersToReject;
  }
}
