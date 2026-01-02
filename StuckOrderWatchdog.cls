global class StuckOrderWatchdog implements Schedulable {
    global void execute(SchedulableContext sc) {
        DateTime cutoff = System.now().addDays(-5);

        List<Order__c> stuckOrders = [SELECT Id, Name, Account__c, Status__c
                                      FROM Order__c
                                      WHERE Status__c = 'Processing'
                                      AND CreatedDate <= :cutoff];

        if(stuckOrders.isEmpty()) return;

        List<Order__c> updates = new List<Order__c>();
        List<Case> cases = new List<Case>();

        for(Order__c ord: stuckOrders){
            ord.Status__c = 'Escalated';
            updates.add(ord);

            cases.add(new Case(
                Subject = 'Order Stuck – ' + ord.Name,
                Status = 'New',
                Origin = 'System',
                AccountId = ord.Account__c,
                Description = 'Order has been in Processing >5 days'
            ));
        }

        if(!updates.isEmpty()) update updates;
        if(!cases.isEmpty()) insert cases;
    }
}
