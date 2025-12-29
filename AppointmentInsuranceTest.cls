@IsTest
public class AppointmentInsuranceTest {

    @IsTest
    static void testCompletedBlockedWhenInsurancePending() {

        Account patient = new Account(
            Name                 = 'Test Patient',
            Insurance_Status__c  = 'Pending'
        );
        insert patient;

        Appointment__c appt = new Appointment__c(
            Patient__c = patient.Id,
            Status__c  = 'Scheduled'
        );
        insert appt;

        appt.Status__c = 'Completed';

        Test.startTest();
            Database.SaveResult sr = Database.update(appt, false);
        Test.stopTest();

        System.assertEquals(false, sr.isSuccess());
        System.assertEquals(
            'Cannot mark visit as Completed while patient insurance is Pending. Please verify insurance first.',
            sr.getErrors()[0].getMessage()
        );
    }

    @IsTest
    static void testCompletedAllowedWhenInsuranceApproved() {

        Account patient = new Account(
            Name                 = 'Approved Patient',
            Insurance_Status__c  = 'Approved'
        );
        insert patient;

        Appointment__c appt = new Appointment__c(
            Patient__c = patient.Id,
            Status__c  = 'Scheduled'
        );
        insert appt;

        appt.Status__c = 'Completed';

        Test.startTest();
            Database.SaveResult sr = Database.update(appt, false);
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess());
    }
}
