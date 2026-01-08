/*
 * Trigger: NoDuplicateActiveSubscription
 * Object: Subscription__c
 * Description: Prevents creating duplicate Active subscriptions
 *              for the same Account and Product.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger NoDuplicateActiveSubscription on Subscription__c(before insert) {
  // Store Account and Product Ids from incoming Subscriptions
  Set<Id> accountIds = new Set<Id>();
  Set<Id> productIds = new Set<Id>();

  // Collect Account/Product combinations for Active subscriptions
  for (Subscription__c sub : Trigger.new) {
    if (
      sub.Account__c != null &&
      sub.Product__c != null &&
      sub.Status__c == 'Active'
    ) {
      accountIds.add(sub.Account__c);
      productIds.add(sub.Product__c);
    }
  }

  // Query existing Active subscriptions for same Account and Product
  List<Subscription__c> existingSubs = [
    SELECT Id, Account__c, Product__c
    FROM Subscription__c
    WHERE
      Account__c IN :accountIds
      AND Product__c IN :productIds
      AND Status__c = 'Active'
  ];

  // Build a lookup key for existing subscriptions
  Set<String> existingKeys = new Set<String>();
  for (Subscription__c sub : existingSubs) {
    existingKeys.add(sub.Account__c + '-' + sub.Product__c);
  }

  // Validate new Subscriptions before insert
  for (Subscription__c sub : Trigger.new) {
    if (
      sub.Account__c != null &&
      sub.Product__c != null &&
      sub.Status__c == 'Active'
    ) {
      String key = sub.Account__c + '-' + sub.Product__c;

      // Block insert if an Active subscription already exists
      if (existingKeys.contains(key)) {
        sub.addError(
          'An Active subscription already exists for this Account and Product.'
        );
      }
    }
  }
}
