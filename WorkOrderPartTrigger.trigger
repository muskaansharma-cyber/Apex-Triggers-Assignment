trigger WorkOrderPartTrigger on WorkOrder(after update) {
  Set<Id> woIds = new Set<Id>();

  for (WorkOrder wo : Trigger.new) {
    WorkOrder oldWo = Trigger.oldMap.get(wo.Id);

    if (wo.Parts_Used__c != oldWo.Parts_Used__c && wo.Parts_Used__c != null) {
      woIds.add(wo.Id);
    }
  }

  if (!woIds.isEmpty()) {
    PartReorderFuture.checkInventory(woIds);
  }
}
