/*
 * Trigger: OfferHighestBid
 * Object: Offer__c
 * Description: Updates the related Opportunity with the highest
 *              Offer price whenever an Offer is inserted or updated.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger OfferHighestBid on Offer__c(after insert, after update) {
  // Store Opportunity Ids related to Offers
  Set<Id> oppIds = new Set<Id>();

  // Collect Opportunity Ids from new Offers
  for (Offer__c offer : Trigger.new) {
    if (offer.Property__c != null) {
      oppIds.add(offer.Property__c);
    }
  }

  // Exit early if no related Opportunities exist
  if (oppIds.isEmpty()) {
    return;
  }

  // Fetch Opportunities to update highest bid value
  Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
    [
      SELECT Id, Highest_Bid__c
      FROM Opportunity
      WHERE Id IN :oppIds
    ]
  );

  // Compare Offer price with current highest bid
  for (Offer__c offer : Trigger.new) {
    // Get related Opportunity
    Opportunity opp = oppMap.get(offer.Property__c);
    if (opp == null) {
      continue;
    }

    // Update highest bid if this Offer is higher
    if (
      opp.Highest_Bid__c == null ||
      offer.Offer_Price__c > opp.Highest_Bid__c
    ) {
      opp.Highest_Bid__c = offer.Offer_Price__c;
    }
  }

  // Save updated Opportunity records
  update oppMap.values();
}
