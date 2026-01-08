/*
 * Trigger: InventoryDecrementTrigger
 * Object: Order
 * Description: Decreases Product inventory when an Order
 *              status changes to Shipped.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger InventoryDecrementTrigger on Order(after update) {
  // Store Order Ids that were just marked as Shipped
  Set<Id> shippedOrderIds = new Set<Id>();

  // Identify Orders whose status changed to Shipped
  for (Order newOrd : Trigger.new) {
    // Get the previous version of the Order
    Order oldOrd = Trigger.oldMap.get(newOrd.Id);

    // Check for status change to Shipped
    if (
      newOrd.Order_Status__c == 'Shipped' &&
      oldOrd.Order_Status__c != 'Shipped'
    ) {
      shippedOrderIds.add(newOrd.Id);
    }
  }

  // Exit early if no Orders were shipped
  if (shippedOrderIds.isEmpty()) {
    return;
  }

  // Fetch Order Items for shipped Orders
  List<OrderItem> orderItems = [
    SELECT Product2Id, Quantity
    FROM OrderItem
    WHERE OrderId IN :shippedOrderIds
  ];

  // Store total ordered quantity per Product
  Map<Id, Decimal> productQtyMap = new Map<Id, Decimal>();

  // Calculate total quantity ordered per Product
  for (OrderItem oi : orderItems) {
    if (!productQtyMap.containsKey(oi.Product2Id)) {
      productQtyMap.put(oi.Product2Id, oi.Quantity);
    } else {
      productQtyMap.put(
        oi.Product2Id,
        productQtyMap.get(oi.Product2Id) + oi.Quantity
      );
    }
  }

  // Fetch Products to update inventory
  List<Product2> productsToUpdate = [
    SELECT Id, Quantity_On_Hand__c
    FROM Product2
    WHERE Id IN :productQtyMap.keySet()
  ];

  // Reduce inventory based on ordered quantity
  for (Product2 p : productsToUpdate) {
    Decimal orderedQty = productQtyMap.get(p.Id);
    p.Quantity_On_Hand__c = p.Quantity_On_Hand__c - orderedQty;
  }

  // Update Product inventory
  update productsToUpdate;
}
