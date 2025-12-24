trigger MarginProtectionTrigger on OrderItem (before insert) {

    // Step 1: Collect Product Ids
    Set<Id> productIds = new Set<Id>();

    for (OrderItem oi : Trigger.new) {
        if (oi.Product2Id != null) {
            productIds.add(oi.Product2Id);
        }
    }

    if (productIds.isEmpty()) {
        return;
    }

    // Step 2: Query Products with Floor Price
    Map<Id, Product2> productMap = new Map<Id, Product2>([
        SELECT Id, Floor_Price__c
        FROM Product2
        WHERE Id IN :productIds
    ]);

    // Step 3: Validate price
    for (OrderItem oi : Trigger.new) {
        Product2 p = productMap.get(oi.Product2Id);

        if (p != null &&
            p.Floor_Price__c != null &&
            oi.UnitPrice < p.Floor_Price__c) {

            oi.addError(
                'Unit Price cannot be below the Floor Price (' +
                p.Floor_Price__c + ').'
            );
        }
    }
}