trigger CustomerStatsTrigger on Order (after insert) {

    // Collect Person Account IDs
    Set<Id> personAccountIds = new Set<Id>();
    for (Order ord : Trigger.new) {
        if (ord.AccountId != null) {
            personAccountIds.add(ord.AccountId);
        }
    }

    if (personAccountIds.isEmpty()) return;

    Map<Id, Decimal> accountSpendMap = new Map<Id, Decimal>();
    Map<Id, Date> accountLastOrderDateMap = new Map<Id, Date>();

    for (Order ord : Trigger.new) {
        Id accId = ord.AccountId;
        Decimal orderAmt = ord.TotalAmount != null ? ord.TotalAmount : 0;
        Date orderDate = ord.Order_Date__c;

        accountSpendMap.put(accId,
            accountSpendMap.containsKey(accId) 
                ? accountSpendMap.get(accId) + orderAmt
                : orderAmt
        );

        if (!accountLastOrderDateMap.containsKey(accId) || orderDate > accountLastOrderDateMap.get(accId)) {
            accountLastOrderDateMap.put(accId, orderDate);
        }
    }

    List<Account> accountsToUpdate = [
        SELECT Id, Lifetime_Spend__c, Last_Order_Date__c
        FROM Account
        WHERE Id IN :accountSpendMap.keySet()
        AND IsPersonAccount = TRUE
    ];

    for (Account acc : accountsToUpdate) {
        Decimal existingSpend = acc.Lifetime_Spend__c != null ? acc.Lifetime_Spend__c : 0;
        acc.Lifetime_Spend__c = existingSpend + accountSpendMap.get(acc.Id);
        acc.Last_Order_Date__c = accountLastOrderDateMap.get(acc.Id);
    }

    update accountsToUpdate;
}