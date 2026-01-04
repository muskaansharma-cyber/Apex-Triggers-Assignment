global class AppointmentBillingRetryBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
            'SELECT Id FROM Appointment__c ' +
            'WHERE Billing_Sync_Status__c = \'Failed\' ' +
            'AND Billing_Sync_Attempts__c < 3'
        );
    }

    global void execute(Database.BatchableContext bc, List<Appointment__c> scope){
        for(Appointment__c appt : scope){
            System.enqueueJob(new AppointmentBillingQueueable(appt.Id));
        }
    }

    global void finish(Database.BatchableContext bc){}
}
