@IsTest
public class DeletedAppointmentTriggerTest {

    @IsTest
    static void testAuditCreatedAfterAppointmentDelete() {

        Appointment__c appt = new Appointment__c(
            Status__c = 'Scheduled'
        );
        insert appt;

        Test.startTest();
            delete appt;
        Test.stopTest();

        List<Audit__c> audits = [
            SELECT Action__c, Appointment_Name__c, Deleted_By__c
            FROM Audit__c
            WHERE Appointment_Name__c = :appt.Id
        ];

        System.assertEquals(
            1,
            audits.size()
        );

        System.assertEquals(
            'Deleted',
            audits[0].Action__c
        );

        System.assertEquals(
            UserInfo.getUserId(),
            audits[0].Deleted_By__c
        );
    }
}
