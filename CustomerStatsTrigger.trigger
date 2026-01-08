/*
 * Trigger: CustomerStatsTrigger
 * Object: Order
 * Description: Updates customer lifetime spend and
 *              last order date when a new Order is created.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger CustomerStatsTrigger on Order(after insert) {
  // Store Person Account Ids from new Orders
  Set<Id> personAccountIds = new Set<Id>();

  // Collect Account Ids from Orders
  for (Order ord : Trigger.new) {
    if (ord.AccountId != null) {
      personAccountIds.add(ord.AccountId);
    }
  }

  // Exit early if no Accounts are related
  if (personAccountIds.isEmpty()) {
    return;
  }

  // Track total spend and last order date per Account
  Map<Id, Decimal> accountSpendMap = new Map<Id, Decimal>();
  Map<Id, Date> accountLastOrderDateMap = new Map<Id, Date>();

  // Aggregate Order data per Account
  for (Order ord : Trigger.new) {
    Id accId = ord.AccountId;
    Decimal orderAmt = ord.TotalAmount != null ? ord.TotalAmount : 0;
    Date orderDate = ord.Order_Date__c;

    // Accumulate lifetime spend
    accountSpendMap.put(
      accId,
      accountSpendMap.containsKey(accId)
        ? accountSpendMap.get(accId) + orderAmt
        : orderAmt
    );

    // Track most recent order date
    if (
      !accountLastOrderDateMap.containsKey(accId) ||
      orderDate > accountLastOrderDateMap.get(accId)
    ) {
      accountLastOrderDateMap.put(accId, orderDate);
    }
  }

  // Fetch Person Accounts to update statistics
  List<Account> accountsToUpdate = [
    SELECT Id, Lifetime_Spend__c, Last_Order_Date__c
    FROM Account
    WHERE Id IN :accountSpendMap.keySet() AND IsPersonAccount = TRUE
  ];

  // Update lifetime spend and last order date
  for (Account acc : accountsToUpdate) {
    Decimal existingSpend = acc.Lifetime_Spend__c != null
      ? acc.Lifetime_Spend__c
      : 0;

    acc.Lifetime_Spend__c = existingSpend + accountSpendMap.get(acc.Id);
    acc.Last_Order_Date__c = accountLastOrderDateMap.get(acc.Id);
  }

  // Save Account updates
  update accountsToUpdate;
}
