trigger TypoProtectionTrigger on Offer__c(before update) {

  if (Trigger.isBefore && Trigger.isUpdate) {

    for (Offer__c offerRec : Trigger.new) {

      Offer__c oldOfferRec = Trigger.oldMap.get(offerRec.Id);
      Decimal amountLimit =
        oldOfferRec.Offer_Price__c + oldOfferRec.Offer_Price__c * 0.1;

      if (offerRec.Offer_Price__c > amountLimit) {
        offerRec.Offer_Price__c = oldOfferRec.Offer_Price__c;
        offerRec.addError(
          'Offer Price cannot be increased by more than 10% of the previous value.Create New Offer if you want to increase the price significantly.'
        );

      }

    }

  }
  
}
