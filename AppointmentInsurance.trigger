/*
 * Trigger: AppointmentInsurance
 * Object: Appointment__c
 * Description: Prevents completing an Appointment when
 *              the patient’s insurance status is Pending.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger AppointmentInsurance on Appointment__c(before update) {
  // Store Patient Account Ids for validation
  Set<Id> patientIds = new Set<Id>();

  // Identify Appointments being marked as Completed
  for (Appointment__c newAppt : Trigger.new) {
    // Get the previous version of the Appointment
    Appointment__c oldAppt = Trigger.oldMap.get(newAppt.Id);

    // Check for status change to Completed
    if (
      newAppt.Status__c == 'Completed' &&
      oldAppt.Status__c != 'Completed' &&
      newAppt.Patient__c != null
    ) {
      patientIds.add(newAppt.Patient__c);
    }
  }

  // Exit early if no Patients need validation
  if (patientIds.isEmpty()) {
    return;
  }

  // Fetch Insurance status for Patients
  Map<Id, Account> patientMap = new Map<Id, Account>(
    [
      SELECT Id, Insurance_Status__c
      FROM Account
      WHERE Id IN :patientIds
    ]
  );

  // Validate insurance before allowing Appointment completion
  for (Appointment__c newAppt : Trigger.new) {
    // Check again for status change to Completed
    if (
      newAppt.Status__c == 'Completed' &&
      Trigger.oldMap.get(newAppt.Id).Status__c != 'Completed'
    ) {
      // Get related Patient Account
      Account patient = patientMap.get(newAppt.Patient__c);

      // Block update if insurance is still pending
      if (patient != null && patient.Insurance_Status__c == 'Pending') {
        newAppt.addError(
          'Cannot mark visit as Completed while patient insurance is Pending. Please verify insurance first.'
        );
      }
    }
  }
}
