public class PersonAccountAgeVerificationBatch
    implements Database.Batchable<SObject>,
               Database.AllowsCallouts,
               Database.Stateful {

    public Integer totalUpdated = 0;
    public Integer totalErrors = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            'SELECT Id, PersonFirstName' +
            ' FROM Account' +
            ' WHERE IsPersonAccount = TRUE' +
            ' AND PersonFirstName != NULL'
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {

        List<Account> updates = new List<Account>();

        for (Account acc : scope) {

            try {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(
                    'https://api.agify.io/?name=' +
                    EncodingUtil.urlEncode(acc.FirstName, 'UTF-8')
                );
                req.setMethod('GET');

                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {

                    Map<String, Object> data =
                        (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                    if (data.containsKey('age') && data.get('age') != null) {

                        acc.Predicted_Age__c = (Integer) data.get('age');
                        acc.Age_Verified__c = true;
                        updates.add(acc);
                        totalUpdated++;
                    }
                }
            }
            catch (Exception e) {
                acc.Age_API_Error__c = e.getMessage();
                updates.add(acc);
                totalErrors++;
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }

    public void finish(Database.BatchableContext bc) {

        System.debug('Total Updated: ' + totalUpdated);
        System.debug('Total Errors: ' + totalErrors);
    }
}