/*
 * Trigger: AccountPatientIdTrigger
 * Object: Account
 * Description: Automatically generates a Patient ID for
 *              new Person Accounts.
 * Author: Muskaan Sharma
 * Created Date: Dec 17, 2025
 */
trigger AccountPatientIdTrigger on Account(before insert) {
  // Build Patient ID prefix using current year
  Integer currentYear = System.today().year();
  String prefix = 'PAT-' + currentYear + '-';

  // Fetch the latest Patient ID for the current year
  List<Account> lastPatients = [
    SELECT Patient_ID__c
    FROM Account
    WHERE Patient_ID__c LIKE :prefix + '%'
    ORDER BY Patient_ID__c DESC
    LIMIT 1
  ];

  Integer nextNumber = 1;

  // Determine next sequence number
  if (!lastPatients.isEmpty() && lastPatients[0].Patient_ID__c != null) {
    String lastNumberStr = lastPatients[0].Patient_ID__c.right(3);
    nextNumber = Integer.valueOf(lastNumberStr) + 1;
  }

  // Assign Patient ID to new Person Accounts
  for (Account acc : Trigger.new) {
    // Only generate ID if missing
    if (acc.IsPersonAccount && acc.Patient_ID__c == null) {
      String formattedNumber = String.valueOf(nextNumber).leftPad(3, '0');
      acc.Patient_ID__c = prefix + formattedNumber;

      nextNumber++;
    }
  }
}
