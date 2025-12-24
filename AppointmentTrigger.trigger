trigger AppointmentTrigger on Appointment__c (before insert, before update) {
    
    for (Appointment__c newAppt : Trigger.new) {
        
        if (newAppt.Appointment_Date__c == null ||
            newAppt.Appointment_from__c == null ||
            newAppt.Appointment_to__c == null ||
            (newAppt.Doctor__c == null && newAppt.Assigned_Doctor__c == null)) {
            continue;
        }
        
        List<Appointment__c> existingAppts = [
            SELECT Id, Appointment_from__c, Appointment_to__c
            FROM Appointment__c
            WHERE Appointment_Date__c = :newAppt.Appointment_Date__c
            AND Status__c != 'Cancelled'
            AND (Doctor__c = :newAppt.Doctor__c
                 OR Assigned_Doctor__c = :newAppt.Assigned_Doctor__c)
        ];
        for (Appointment__c existAppt : existingAppts) {
            
            if (newAppt.Id != null && newAppt.Id == existAppt.Id) {
                continue;
            }

            Boolean overlaps = newAppt.Appointment_from__c < existAppt.Appointment_to__c
                               && newAppt.Appointment_to__c > existAppt.Appointment_from__c;

            if (overlaps) {
                newAppt.Appointment_from__c.addError(
                    'This doctor already has an appointment during this time.'
                );
                break;
            }
        }
    }
}