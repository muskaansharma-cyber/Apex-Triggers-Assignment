trigger SubscriptionSlackTrigger on Subscription__c(after insert) {
  Set<Id> proSubscriptionIds = new Set<Id>();

  for (Subscription__c sub : Trigger.new) {
    if (sub.Product__c != null) {
      proSubscriptionIds.add(sub.Id);
    }
  }

  if (!proSubscriptionIds.isEmpty()) {
    SubscriptionSlackFuture.notifyProSubscription(proSubscriptionIds);
  }
}
