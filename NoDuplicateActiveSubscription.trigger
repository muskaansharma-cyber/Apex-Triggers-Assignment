trigger NoDuplicateActiveSubscription on Subscription__c (before insert) {

    // Collect Account + Product combinations from new records
    Set<Id> accountIds = new Set<Id>();
    Set<Id> productIds = new Set<Id>();

    for (Subscription__c sub : Trigger.new) {
        if (sub.Account__c != null && sub.Product__c != null && sub.Status__c == 'Active') {
            accountIds.add(sub.Account__c);
            productIds.add(sub.Product__c);
        }
    }

    // Query existing ACTIVE subscriptions
    List<Subscription__c> existingSubs = [
        SELECT Id, Account__c, Product__c
        FROM Subscription__c
        WHERE Account__c IN :accountIds
        AND Product__c IN :productIds
        AND Status__c = 'Active'
    ];

    // Create a lookup key: AccountId-ProductId
    Set<String> existingKeys = new Set<String>();
    for (Subscription__c sub : existingSubs) {
        existingKeys.add(sub.Account__c + '-' + sub.Product__c);
    }

    // Validate new records
    for (Subscription__c sub : Trigger.new) {
        if (sub.Account__c != null && sub.Product__c != null && sub.Status__c == 'Active') {

            String key = sub.Account__c + '-' + sub.Product__c;

            if (existingKeys.contains(key)) {
                sub.addError(
                    'An Active subscription already exists for this Account and Product.'
                );
            }
        }
    }
}