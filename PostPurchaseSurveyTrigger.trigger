trigger PostPurchaseSurveyTrigger on Order(after update) {
  List<Id> deliveredOrderIds = new List<Id>();

  for (Order ord : Trigger.new) {
    Order oldOrd = Trigger.oldMap.get(ord.Id);

    // Check if Order Status changed to Delivered
    if (
      (ord.Order_Status__c == 'Delivered' ||
      ord.Status == 'Delivered') &&
      oldOrd.Order_Status__c != 'Delivered' &&
      oldOrd.Status != 'Delivered'
    ) {
      deliveredOrderIds.add(ord.Id);
    }
  }

  if (!deliveredOrderIds.isEmpty()) {
    PostPurchaseSurveyService.sendSurvey(deliveredOrderIds);
  }
}
