trigger DeletedAppointmentTrigger on Appointment__c (after delete) {

    List<Audit__c> auditLogs = new List<Audit__c>();

    for (Appointment__c appt : Trigger.old) {

        Audit__c audit = new Audit__c();
        audit.Action__c = 'Deleted';
        audit.Appointment_Name__c = appt.Id;
        audit.Deleted_By__c = UserInfo.getUserId();
        audit.Deleted_On__c = System.now();

        auditLogs.add(audit);
    }

    if (!auditLogs.isEmpty()) {
        try {
            insert auditLogs;
        } catch (Exception e) {
            System.debug('Audit logging failed: ' + e.getMessage());
        }
    }
}