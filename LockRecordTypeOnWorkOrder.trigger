/*
 * Trigger: LockRecordTypeOnWorkOrder
 * Object: WorkOrder
 * Description: Prevents changing Record Type once set
 *              (Repair stays Repair, Installation stays Installation)
 */
trigger LockRecordTypeOnWorkOrder on WorkOrder(before update) {
  // Get Record Type Ids by DeveloperName
  Map<String, Schema.RecordTypeInfo> rtMap = WorkOrder.SObjectType.getDescribe()
    .getRecordTypeInfosByDeveloperName();

  // Defensive check in case record types don’t exist
  if (!rtMap.containsKey('Repair') || !rtMap.containsKey('Installation')) {
    return;
  }

  Id repairId = rtMap.get('Repair').getRecordTypeId();
  Id installId = rtMap.get('Installation').getRecordTypeId();

  for (WorkOrder wo : Trigger.new) {
    WorkOrder oldWo = Trigger.oldMap.get(wo.Id);

    // Only run logic if Record Type is being changed
    if (wo.RecordTypeId == oldWo.RecordTypeId) {
      continue;
    }

    // If old Record Type is Repair, block change to anything else
    if (oldWo.RecordTypeId == repairId && wo.RecordTypeId != repairId) {
      wo.addError('Record Type can only be Repair.');
    }
    // If old Record Type is Installation, block change to anything else
    else if (oldWo.RecordTypeId == installId && wo.RecordTypeId != installId) {
      wo.addError('Record Type can only be Installation.');
    }
  }
}
