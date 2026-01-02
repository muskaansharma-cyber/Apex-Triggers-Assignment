@RestResource(urlMapping='/BookAppointment/*')
global with sharing class BookAppointmentAPI {

    @HttpPost
    global static String bookAppointment(String patientId, String doctorId, String time) {
        try {
            if(String.isBlank(patientId) || String.isBlank(doctorId) || String.isBlank(time)) {
                throw new AuraHandledException('Missing required parameters');
            }

            Time apptTime;
            try {
                apptTime = Time.valueOf(time);
            } catch(Exception e) {
                throw new AuraHandledException('Invalid time format. Use HH:MM:SS');
            }

            Date today = Date.today();

            List<Appointment__c> existing = [
                SELECT Id
                FROM Appointment__c
                WHERE Assigned_Doctor__c = :doctorId
                AND Appointment_Date__c = :today
                AND Appointment_from__c = :apptTime
            ];

            if(!existing.isEmpty()) {
                throw new AuraHandledException('Doctor is already booked at this time');
            }

            Appointment__c newAppt = new Appointment__c(
                Patient__c = patientId,
                Assigned_Doctor__c = doctorId,
                Appointment_Date__c = today,
                Appointment_from__c = apptTime,
                Status__c = 'Scheduled',
                Name = 'Appointment ' + String.valueOf(DateTime.now().getTime())
            );

            insert newAppt;

            return JSON.serialize(new Map<String, Object>{
                'success' => true,
                'appointmentId' => newAppt.Id,
                'message' => 'Appointment booked successfully'
            });

        } catch(Exception e) {
            return JSON.serialize(new Map<String, Object>{
                'success' => false,
                'message' => e.getMessage()
            });
        }
    }
}
