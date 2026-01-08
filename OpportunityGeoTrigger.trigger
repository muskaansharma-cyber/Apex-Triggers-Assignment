trigger OpportunityGeoTrigger on Opportunity(after insert) {
  Set<Id> oppIds = new Set<Id>();

  for (Opportunity opp : Trigger.new) {
    if (opp.Zip_Code__c != null) {
      oppIds.add(opp.Id);
    }
  }

  if (!oppIds.isEmpty()) {
    OpportunityGeoFuture.populateCityState(oppIds);
  }
}
