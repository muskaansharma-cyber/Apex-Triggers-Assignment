/*
 * Trigger: WorkOrderEnforceSLATrigger
 * Object: WorkOrder
 * Description: Sets Work Order SLA end time based on
 *              the Customer Type.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger WorkOrderEnforceSLATrigger on WorkOrder(before insert) {
  // Store Account Ids from incoming Work Orders
  Set<Id> accountIds = new Set<Id>();

  // Collect Account Ids for SLA evaluation
  for (WorkOrder wo : Trigger.new) {
    if (wo.AccountId != null) {
      accountIds.add(wo.AccountId);
    }
  }

  // Exit early if no Accounts are related
  if (accountIds.isEmpty()) {
    return;
  }

  // Fetch Customer Type for related Accounts
  Map<Id, Account> accountMap = new Map<Id, Account>(
    [
      SELECT Id, Customer_Type__c
      FROM Account
      WHERE Id IN :accountIds
    ]
  );

  // Apply SLA rules based on Customer Type
  for (WorkOrder wo : Trigger.new) {
    // Get related Account
    Account acc = accountMap.get(wo.AccountId);
    if (acc == null || acc.Customer_Type__c == null) {
      continue;
    }

    // Set SLA end time based on customer tier
    if (acc.Customer_Type__c == 'Gold VIP') {
      wo.EndDate = System.now().addHours(4);
    } else if (acc.Customer_Type__c == 'Silver') {
      wo.EndDate = System.now().addHours(24);
    }
  }
}
