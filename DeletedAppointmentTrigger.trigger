/*
 * Trigger: DeletedAppointmentTrigger
 * Object: Appointment__c
 * Description: Creates an audit record whenever an
 *              Appointment is deleted.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger DeletedAppointmentTrigger on Appointment__c(after delete) {
  // Store audit records to be created
  List<Audit__c> auditLogs = new List<Audit__c>();

  // Create audit entry for each deleted Appointment
  for (Appointment__c appt : Trigger.old) {
    Audit__c audit = new Audit__c();
    audit.Action__c = 'Deleted';
    audit.Appointment_Name__c = appt.Id;
    audit.Deleted_By__c = UserInfo.getUserId();
    audit.Deleted_On__c = System.now();

    auditLogs.add(audit);
  }

  // Insert audit records
  if (!auditLogs.isEmpty()) {
    try {
      insert auditLogs;
    } catch (Exception e) {
      // Prevent audit failure from blocking the delete operation
      System.debug('Audit logging failed: ' + e.getMessage());
    }
  }
}
