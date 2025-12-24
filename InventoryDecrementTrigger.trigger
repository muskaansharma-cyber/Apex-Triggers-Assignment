trigger InventoryDecrementTrigger on Order (after update) {

    Set<Id> shippedOrderIds = new Set<Id>();

    for (Order newOrd : Trigger.new) {
        Order oldOrd = Trigger.oldMap.get(newOrd.Id);

        if (newOrd.Order_Status__c == 'Shipped' &&
            oldOrd.Order_Status__c != 'Shipped') {

            shippedOrderIds.add(newOrd.Id);
        }
    }

    if (shippedOrderIds.isEmpty()) {
        return;
    }

    List<OrderItem> orderItems = [
        SELECT Product2Id, Quantity
        FROM OrderItem
        WHERE OrderId IN :shippedOrderIds
    ];
   
    Map<Id, Decimal> productQtyMap = new Map<Id, Decimal>();

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

  
    List<Product2> productsToUpdate = [
        SELECT Id, Quantity_On_Hand__c
        FROM Product2
        WHERE Id IN :productQtyMap.keySet()
    ];

    for (Product2 p : productsToUpdate) {
        Decimal orderedQty = productQtyMap.get(p.Id);
        p.Quantity_On_Hand__c =
            p.Quantity_On_Hand__c - orderedQty;
    }

    update productsToUpdate;
}