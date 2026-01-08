trigger WorkOrderLineItemTrigger on WorkOrderLineItem(after update) {
  List<Id> toSync = new List<Id>();

  for (WorkOrderLineItem woli : Trigger.new) {
    WorkOrderLineItem old = Trigger.oldMap.get(woli.Id);

    if (
      woli.Status == 'Completed' &&
      old.Status != 'Completed' &&
      woli.Inventory_Synced__c == false
    ) {
      toSync.add(woli.Id);
    }
  }

  if (!toSync.isEmpty()) {
    System.enqueueJob(new ERPInventorySyncQueueable(toSync));
  }
}
