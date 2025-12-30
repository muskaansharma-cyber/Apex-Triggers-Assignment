public class OrderFraudDetectionBatch
    implements Database.Batchable<SObject>,
               Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            'SELECT Id, BillingPostalCode, AccountId, Account.Customer_Region__c ' +
            'FROM Order ' +
            'WHERE BillingPostalCode != null'
        );
    }

    public void execute(Database.BatchableContext bc, List<Order> scope) {

        List<Order> ordersToUpdate = new List<Order>();
        Http http = new Http();

        for (Order ord : scope) {

            try {
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint(
                    'https://api.zippopotam.us/us/' +
                    ord.BillingPostalCode
                );

                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {

                    Map<String, Object> body =
                        (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                    List<Object> places = (List<Object>) body.get('places');

                    if (!places.isEmpty()) {

                        Map<String, Object> place =
                            (Map<String, Object>) places[0];

                        String state = (String) place.get('state abbreviation');

                        if (ord.Account.Customer_Region__c != state) {

                            ord.Fraud_Flag__c = true;
                            ord.Fraud_Reason__c =
                                'Billing ZIP state mismatch. Expected: ' +
                                ord.Account.Customer_Region__c +
                                ', Found: ' + state;

                            ordersToUpdate.add(ord);
                        }
                    }
                }

            } catch (Exception e) {
                System.debug('Fraud check failed for Order ' + ord.Id);
            }
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Order Fraud Detection Batch Completed');
    }
}
