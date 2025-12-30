public class AccountCustomerEnrichmentBatch
    implements Database.Batchable<SObject>,
               Database.AllowsCallouts,
               Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name FROM Account WHERE Name != null'
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {

        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : scope) {
            try {
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint(
                    'https://api.agify.io/?name=' +
                    EncodingUtil.urlEncode(acc.Name, 'UTF-8')
                );

                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {
                    Map<String, Object> responseMap =
                        (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                    if (responseMap.containsKey('age') && responseMap.get('age') != null) {

                        Integer age = Integer.valueOf(responseMap.get('age'));

                        acc.Company_Age__c = age;

                        if (age < 5) {
                            acc.Company_Maturity__c = 'Startup';
                        } else if (age <= 15) {
                            acc.Company_Maturity__c = 'Growing';
                        } else {
                            acc.Company_Maturity__c = 'Established';
                        }

                        accountsToUpdate.add(acc);
                    }
                }

            } catch (Exception e) {
                System.debug('Enrichment error for Account ' + acc.Id + ': ' + e.getMessage());
            }
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Account Customer Enrichment Batch completed.');
    }
}
