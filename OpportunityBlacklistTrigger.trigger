/*
 * Trigger: OpportunityBlacklistTrigger
 * Object: Opportunity
 * Description: Prevents Opportunity creation when the related Person Account
 *              is marked as blacklisted.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger OpportunityBlacklistTrigger on Opportunity(before insert) {
  // Collect all Account Ids from incoming Opportunities

  Set<Id> accountIds = new Set<Id>();

  for (Opportunity opp : Trigger.new) {
    if (opp.AccountId != null) {
      accountIds.add(opp.AccountId);
    }
  }

  // Exit early if no Accounts are related

  if (accountIds.isEmpty()) {
    return;
  }

  // fetch the blacklist flag needed for validation
  Map<Id, Account> accountMap = new Map<Id, Account>(
    [
      SELECT Id, IsPersonAccount, Blacklisted__c
      FROM Account
      WHERE Id IN :accountIds AND IsPersonAccount = TRUE
    ]
  );

  // Validate each Opportunity against its related Account
  for (Opportunity opp : Trigger.new) {
    // Get the related Account (seller)
    Account seller = accountMap.get(opp.AccountId);

    // If the seller(Person Account) exists, marked as blacklisted -> Block the Opportunity creation

    if (
      seller != null &&
      seller.IsPersonAccount &&
      seller.Blacklisted__c == true
    ) {
      opp.addError(
        'This seller is blacklisted. Property listings cannot be created for this client.'
      );
    }
  }
}
