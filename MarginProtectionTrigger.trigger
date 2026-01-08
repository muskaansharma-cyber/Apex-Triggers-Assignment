/*
 * Trigger: MarginProtectionTrigger
 * Object: OrderItem
 * Description: Prevents creating Order Items with a Unit Price
 *              below the Product’s Floor Price.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger MarginProtectionTrigger on OrderItem(before insert) {
  // Store Product Ids from incoming Order Items
  Set<Id> productIds = new Set<Id>();

  // Collect Product Ids for validation
  for (OrderItem oi : Trigger.new) {
    if (oi.Product2Id != null) {
      productIds.add(oi.Product2Id);
    }
  }

  // Exit early if no Products are related
  if (productIds.isEmpty()) {
    return;
  }

  // Fetch Floor Price for related Products
  Map<Id, Product2> productMap = new Map<Id, Product2>(
    [
      SELECT Id, Floor_Price__c
      FROM Product2
      WHERE Id IN :productIds
    ]
  );

  // Validate Unit Price against Floor Price
  for (OrderItem oi : Trigger.new) {
    // Get related Product
    Product2 p = productMap.get(oi.Product2Id);

    // Block insert if Unit Price is below Floor Price
    if (
      p != null &&
      p.Floor_Price__c != null &&
      oi.UnitPrice < p.Floor_Price__c
    ) {
      oi.addError(
        'Unit Price cannot be below the Floor Price (' + p.Floor_Price__c + ').'
      );
    }
  }
}
