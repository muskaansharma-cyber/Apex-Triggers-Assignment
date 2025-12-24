trigger AppointmentInsurance on Appointment__c (before update) {

    Set<Id> patientIds = new Set<Id>();
    for (Appointment__c newAppt : Trigger.new) {
        Appointment__c oldAppt = Trigger.oldMap.get(newAppt.Id);

        if (
            newAppt.Status__c == 'Completed' &&
            oldAppt.Status__c != 'Completed' &&
            newAppt.Patient__c != null
        ) {
            patientIds.add(newAppt.Patient__c);
        }
    }

    if (patientIds.isEmpty()) {
        return;
    }

    Map<Id, Account> patientMap = new Map<Id, Account>(
        [
            SELECT Id, Insurance_Status__c
            FROM Account
            WHERE Id IN :patientIds
        ]
    );

    for (Appointment__c newAppt : Trigger.new) {
        if (
            newAppt.Status__c == 'Completed' &&
            Trigger.oldMap.get(newAppt.Id).Status__c != 'Completed'
        ) {
            Account patient = patientMap.get(newAppt.Patient__c);

            if (patient != null && patient.Insurance_Status__c == 'Pending') {
                newAppt.addError(
                    'Cannot mark visit as Completed while patient insurance is Pending. Please verify insurance first.'
                );
            }
        }
    }
}