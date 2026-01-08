/*
 * Trigger: OpportunityBeforeUpdate
 * Object: Opportunity
 * Description: Prevents marking an Opportunity as Sold
 *              if there is no accepted Offer related to it.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger OpportunityBeforeUpdate on Opportunity(before update) {
  // Iterate through Opportunities being updated
  for (Opportunity opp : Trigger.new) {
    // Get the old version of the Opportunity
    Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

    // Check if Status is changing to 'Sold'
    if (opp.Status__c == 'Sold' && oldOpp.Status__c != 'Sold') {
      // Count accepted Offers related to this Opportunity
      Integer acceptedOffers = [
        SELECT COUNT()
        FROM Offer__c
        WHERE Property__c = :opp.Id AND Outcome__c = 'Accepted'
      ];

      // Block update if no accepted Offer exists
      if (acceptedOffers == 0) {
        opp.addError('You can’t sell a house without an accepted offer.');
      }
    }
  }
}
