@IsTest
private class AppointmentBillingTest {

    @IsTest
    static void testBillingFlow(){

        Account acc = new Account(
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND IsPersonType=true LIMIT 1].Id,
            LastName = 'Test Patient'
        );
        insert acc;

        Appointment__c appt = new Appointment__c(
            Name = 'Test Appt',
            Patient__c = acc.Id,
            Status__c = 'Completed',
            Appointment_Date__c = Date.today(),
            Billing_Amount__c = 500,
            Billing_Sync_Status__c = 'Failed',
            Billing_Sync_Attempts__c = 0
        );
        insert appt;

        Test.setMock(HttpCalloutMock.class, new AppointmentBillingMock());

        Test.startTest();
            System.enqueueJob(new AppointmentBillingQueueable(appt.Id));
            Database.executeBatch(new AppointmentBillingRetryBatch(), 1);
        Test.stopTest();

        Appointment__c updated = [
            SELECT Billing_Sync_Status__c, Billing_Sent__c
            FROM Appointment__c
            WHERE Id = :appt.Id
        ];

        System.assertEquals('Success', updated.Billing_Sync_Status__c);
        System.assertEquals(true, updated.Billing_Sent__c);
    }
}
