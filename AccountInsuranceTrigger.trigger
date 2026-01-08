trigger AccountInsuranceTrigger on Account(after insert) {
  Set<Id> patientIds = new Set<Id>();

  for (Account acc : Trigger.new) {
    if (acc.IsPersonAccount && acc.Zip_Code__c != null) {
      patientIds.add(acc.Id);
    }
  }

  if (!patientIds.isEmpty()) {
    InsuranceVerificationFuture.verifyInsurance(patientIds);
  }
}
