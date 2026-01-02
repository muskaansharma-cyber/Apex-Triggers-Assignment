@isTest
private class NoShowPredictorTest {
    
    @isTest
    static void testNoShowPredictor() {
        Account patient = new Account(
            LastName = 'TestPatient',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND Name='Person Account' LIMIT 1].Id
        );
        insert patient;

        List<Appointment__c> pastAppointments = new List<Appointment__c>();
        for(Integer i = 1; i <= 4; i++){
            pastAppointments.add(new Appointment__c(
                Name = 'Missed Appt ' + i,
                Appointment_Date__c = Date.today().addDays(-30*i),
                Patient__c = patient.Id,
                Status__c = 'No-Show'
            ));
        }
        insert pastAppointments;

        Appointment__c tomorrowAppt = new Appointment__c(
            Name = 'Tomorrow Appt',
            Appointment_Date__c = Date.today().addDays(1),
            Patient__c = patient.Id,
            Status__c = 'Scheduled'
        );
        insert tomorrowAppt;

        Test.startTest();
            String cronExp = '0 0 0 * * ?'; 
            NoShowPredictor job = new NoShowPredictor();
            System.schedule('Test No-Show Predictor', cronExp, job);
        Test.stopTest();

        Appointment__c updatedAppt = [SELECT Id, Risk_Level__c FROM Appointment__c WHERE Id = :tomorrowAppt.Id];
        System.assertEquals('High Risk', updatedAppt.Risk_Level__c, 'Appointment should be marked High Risk');
    }
}
