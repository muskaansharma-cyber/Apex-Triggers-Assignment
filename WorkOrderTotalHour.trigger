/*
 * Trigger: WorkOrderTotalHour
 * Object: WorkOrderLineItem
 * Description: Recalculates total work hours on the
 *              related Work Order when line items
 *              are updated, deleted, or restored.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger WorkOrderTotalHour on WorkOrderLineItem(
  after update,
  after delete,
  after undelete
) {
  // Store Work Order Ids affected by changes
  Set<Id> workOrderIds = new Set<Id>();

  if (Trigger.isAfter) {
    // Collect Work Order Ids for update or undelete
    if (Trigger.isUpdate || Trigger.isUndelete) {
      for (WorkOrderLineItem woli : Trigger.new) {
        if (woli.WorkOrderId != null) {
          workOrderIds.add(woli.WorkOrderId);
        }
      }
    }

    // Collect Work Order Ids for delete
    if (Trigger.isDelete) {
      for (WorkOrderLineItem woli : Trigger.old) {
        if (woli.WorkOrderId != null) {
          workOrderIds.add(woli.WorkOrderId);
        }
      }
    }

    // Exit early if no Work Orders are affected
    if (workOrderIds.isEmpty()) {
      return;
    }

    // Fetch all line items for affected Work Orders
    List<WorkOrderLineItem> listItem = [
      SELECT WorkOrderId, StartDate, EndDate
      FROM WorkOrderLineItem
      WHERE WorkOrderId IN :workOrderIds
    ];

    // Store total hours per Work Order
    Map<Id, Decimal> workOrderHoursMap = new Map<Id, Decimal>();

    // Calculate total hours for each Work Order
    for (WorkOrderLineItem woli : listItem) {
      Datetime startDateTime = woli.StartDate;
      Datetime endDateTime = woli.EndDate;

      // Handle overnight work
      if (startDateTime > endDateTime) {
        endDateTime = endDateTime.addDays(1);
      }

      Decimal totalHours =
        (endDateTime.getTime() - startDateTime.getTime()) / (1000 * 60 * 60);

      workOrderHoursMap.put(
        woli.WorkOrderId,
        workOrderHoursMap.containsKey(woli.WorkOrderId)
          ? workOrderHoursMap.get(woli.WorkOrderId) + totalHours
          : totalHours
      );
    }

    // Prepare Work Orders for update
    List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();

    for (Id woId : workOrderHoursMap.keySet()) {
      WorkOrder wo = new WorkOrder(Id = woId);
      wo.Total_Hours__c = workOrderHoursMap.get(woId);
      workOrdersToUpdate.add(wo);
    }

    // Update total hours on Work Orders
    if (!workOrdersToUpdate.isEmpty()) {
      update workOrdersToUpdate;
    }
  }
}
