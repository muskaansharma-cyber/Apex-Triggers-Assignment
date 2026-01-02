public class MaintenancePlanGenerator implements Queueable, Database.AllowsCallouts {

    private List<Id> workOrderIds;

  
    public MaintenancePlanGenerator(List<Id> workOrderIds) {
        this.workOrderIds = workOrderIds;
    }

    public void execute(QueueableContext qc) {


        List<Work_Order__c> parentWOs = [
            SELECT Id, AccountId, OwnerId, Status, Subject, Technician__c, Service_Territory__c
            FROM Work_Order__c
            WHERE Id IN :workOrderIds
              AND Status = 'Closed'  
              AND Subject = 'New Install'
        ];

        List<Work_Order__c> newCheckups = new List<Work_Order__c>();

        for (Work_Order__c parent : parentWOs) {

            Date startDate = Date.today();

            for (Integer i = 1; i <= 4; i++) {
                Work_Order__c checkup = new Work_Order__c();
                checkup.Subject = 'Check-up';
                checkup.AccountId = parent.AccountId;
                checkup.OwnerId = parent.OwnerId;
                checkup.Technician__c = parent.Technician__c;
                checkup.Service_Territory__c = parent.Service_Territory__c;
                checkup.Status = 'Planned';
                checkup.ParentWorkOrderId = parent.Id;

                checkup.StartDate = startDate.addMonths(i * 3);

                checkup.EndDate = checkup.StartDate.addDays(1);

                newCheckups.add(checkup);
            }
        }

        if (!newCheckups.isEmpty()) {
            insert newCheckups;
            System.debug('Created ' + newCheckups.size() + ' quarterly check-up Work Orders.');
        }
    }
}
