global class NoShowPredictor implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        Date tomorrow = Date.today().addDays(1);

        List<Appointment__c> tomorrowsAppointments = [
            SELECT Id, Patient__c, Status__c
            FROM Appointment__c
            WHERE Appointment_Date__c = :tomorrow
        ];

        if(tomorrowsAppointments.isEmpty()) return;

        Map<Id, Integer> patientMissedMap = new Map<Id, Integer>();
        for(Appointment__c app : [
            SELECT Patient__c
            FROM Appointment__c
            WHERE Patient__c IN :tomorrowsAppointments.Patient__c
            AND Status__c = 'No-Show'
            AND Appointment_Date__c = LAST_N_DAYS:365
        ]) {
            if(!patientMissedMap.containsKey(app.Patient__c)){
                patientMissedMap.put(app.Patient__c, 0);
            }
            patientMissedMap.put(app.Patient__c, patientMissedMap.get(app.Patient__c) + 1);
        }

        List<Appointment__c> updates = new List<Appointment__c>();
        for(Appointment__c app : tomorrowsAppointments){
            Integer missedCount = patientMissedMap.get(app.Patient__c);
            if(missedCount != null && missedCount > 3){
                app.Risk_Level__c = 'High Risk';
                updates.add(app);
            }
        }

        if(!updates.isEmpty()) update updates;
    }
}
