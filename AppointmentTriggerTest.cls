@IsTest
public class AppointmentTriggerTest {

    @IsTest
    static void testOverlappingAppointmentBlocked() {

        Account doctor = new Account(
            Name = 'Doctor One'
        );
        insert doctor;

        Date apptDate = Date.today();

        Appointment__c existingAppt = new Appointment__c(
            Appointment_Date__c = apptDate,
            Appointment_from__c = Time.newInstance(10, 0, 0, 0),
            Appointment_to__c   = Time.newInstance(11, 0, 0, 0),
            Doctor__c           = doctor.Id,
            Status__c           = 'Scheduled'
        );
        insert existingAppt;

        Appointment__c newAppt = new Appointment__c(
            Appointment_Date__c = apptDate,
            Appointment_from__c = Time.newInstance(10, 30, 0, 0),
            Appointment_to__c   = Time.newInstance(11, 30, 0, 0),
            Doctor__c           = doctor.Id,
            Status__c           = 'Scheduled'
        );

        Test.startTest();
            Database.SaveResult sr = Database.insert(newAppt, false);
        Test.stopTest();

        System.assertEquals(false, sr.isSuccess());
        System.assertEquals(
            'This doctor already has an appointment during this time.',
            sr.getErrors()[0].getMessage()
        );
    }

    @IsTest
    static void testNonOverlappingAppointmentAllowed() {

        Account doctor = new Account(
            Name = 'Doctor Two'
        );
        insert doctor;

        Date apptDate = Date.today();

        Appointment__c existingAppt = new Appointment__c(
            Appointment_Date__c = apptDate,
            Appointment_from__c = Time.newInstance(9, 0, 0, 0),
            Appointment_to__c   = Time.newInstance(10, 0, 0, 0),
            Doctor__c           = doctor.Id,
            Status__c           = 'Scheduled'
        );
        insert existingAppt;

        Appointment__c newAppt = new Appointment__c(
            Appointment_Date__c = apptDate,
            Appointment_from__c = Time.newInstance(10, 30, 0, 0),
            Appointment_to__c   = Time.newInstance(11, 30, 0, 0),
            Doctor__c           = doctor.Id,
            Status__c           = 'Scheduled'
        );

        Test.startTest();
            Database.SaveResult sr = Database.insert(newAppt, false);
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess());
    }
}
