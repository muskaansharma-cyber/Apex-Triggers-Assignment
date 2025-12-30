public class ServiceTerritoryFixBatch
    implements Database.Batchable<SObject>,
               Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            'SELECT Id, AccountId, Service_Territory__c' +
            ' FROM WorkOrder' +
            ' WHERE Status != \'Closed\'' +
            ' AND AccountId != NULL'
        );
    }

    public void execute(Database.BatchableContext bc, List<WorkOrder> scope) {

        Set<Id> accountIds = new Set<Id>();
        for (WorkOrder wo : scope) {
            accountIds.add(wo.AccountId);
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(
            [
                SELECT Id, Zip_Code__c
                FROM Account
                WHERE Id IN :accountIds
                AND Zip_Code__c != NULL
            ]
        );

        List<WorkOrder> updates = new List<WorkOrder>();

        for (WorkOrder wo : scope) {

            Account acc = accountMap.get(wo.AccountId);
            if (acc == null) continue;

            try {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(
                    'https://api.zippopotam.us/us/' +
                    EncodingUtil.urlEncode(acc.Zip_Code__c, 'UTF-8')
                );
                req.setMethod('GET');

                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {

                    Map<String, Object> data =
                        (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                    List<Object> places =
                        (List<Object>) data.get('places');

                    if (!places.isEmpty()) {

                        Map<String, Object> place =
                            (Map<String, Object>) places[0];

                        String state =
                            (String) place.get('state abbreviation');

                        wo.Service_Territory__c = mapStateToTerritory(state);
                        updates.add(wo);
                    }
                }
            }
            catch (Exception e) {
                System.debug('Service Territory API error: ' + e.getMessage());
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Service Territory Fix batch completed');
    }

    private static String mapStateToTerritory(String state) {

        if (state == 'NY') return 'NY';
        if (state == 'CA') return 'CA';
        if (state == 'TX') return 'TX';

        return 'OTHER';
    }
}
