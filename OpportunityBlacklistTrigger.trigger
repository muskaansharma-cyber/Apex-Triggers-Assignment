trigger OpportunityBlacklistTrigger on Opportunity (before insert) {
Set<Id> accountIds = new Set<Id>();
  for (Opportunity opp : Trigger.new) {
      if (opp.AccountId != null) {
         accountIds.add(opp.AccountId);
      }
  }

    if (accountIds.isEmpty()) return;
    
    Map<Id, Account> accountMap = new Map<Id, Account>(
        [
            SELECT Id,IsPersonAccount,Blacklisted__c
            FROM Account
            WHERE Id IN :accountIds
            AND IsPersonAccount = true
        ]
    );

    for (Opportunity opp : Trigger.new) {
        Account seller = accountMap.get(opp.AccountId);

        if (seller != null &&
            seller.IsPersonAccount &&
            seller.Blacklisted__c == true) {

            opp.addError(
                'This seller is blacklisted. Property listings cannot be created for this client.'
            );
        }
    }
}