global class AutoCloseWorkOrdersSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
        Date today = Date.today();

        List<Work_Order__c> workOrders = [
            SELECT Id, Status,
                   (SELECT Id, Status, Visit_Date__c 
                    FROM Work_Order_Line_Items__r)  
            FROM Work_Order__c
            WHERE Status != 'Closed'
        ];

        List<Work_Order__c> toClose = new List<Work_Order__c>();

        for (Work_Order__c wo : workOrders) {
            if (wo.Work_Order_Line_Items__r == null || wo.Work_Order_Line_Items__r.isEmpty()) {
                continue;
            }

            Boolean allCompleted7DaysAgo = true;

            for (Work_Order_Line_Item__c lineItem : wo.Work_Order_Line_Items__r) {
                if (lineItem.Status != 'Completed' 
                    || lineItem.Visit_Date__c == null 
                    || lineItem.Visit_Date__c > today.addDays(-7)) {
                    allCompleted7DaysAgo = false;
                    break;
                }
            }

            if (allCompleted7DaysAgo) {
                wo.Status = 'Closed';
                toClose.add(wo);
            }
        }

        if (!toClose.isEmpty()) {
            update toClose;
            System.debug('Auto-closed ' + toClose.size() + ' Work Orders.');
        }
    }
}
