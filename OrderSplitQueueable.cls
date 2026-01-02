public class OrderSplitQueueable implements Queueable {

    private Id orderId;
    private Integer startIndex;

    public OrderSplitQueueable(Id orderId, Integer startIndex) {
        this.orderId = orderId;
        this.startIndex = startIndex != null ? startIndex : 0;
    }

    public void execute(QueueableContext qc) {

        Integer batchSize = 50;

        List<Order_Product__c> lineItems = [
            SELECT Id, Product__c, Quantity__c, Weight__c, Price__c
            FROM Order_Product__c
            WHERE Order__c = :orderId
            ORDER BY Id
            LIMIT :batchSize OFFSET :startIndex
        ];

        if(lineItems.isEmpty()) return;

        Shipment__c shipment = new Shipment__c(
            Order__c = orderId,
            Name = 'Shipment for ' + String.valueOf(System.now().getTime()),
            Shipment_Date__c = Date.today(),
            Status__c = 'Pending'
        );
        insert shipment;

        List<Shipment_Line_Item__c> shipmentLines = new List<Shipment_Line_Item__c>();
        Decimal totalWeight = 0;

        for(Order_Product__c li: lineItems){
            shipmentLines.add(new Shipment_Line_Item__c(
                Shipment__c = shipment.Id,
                Product__c = li.Product__c,
                Quantity__c = li.Quantity__c,
                Weight__c = li.Weight__c,
                Price__c = li.Price__c
            ));
            totalWeight += li.Weight__c != null ? li.Weight__c : 0;
        }

        shipment.Total_Weight__c = totalWeight;
        update shipment;

        if(!shipmentLines.isEmpty()) insert shipmentLines;

        Integer totalLines = [SELECT COUNT() FROM Order_Product__c WHERE Order__c = :orderId];
        if(startIndex + batchSize < totalLines){
            System.enqueueJob(new OrderSplitQueueable(orderId, startIndex + batchSize));
        }
    }
}
