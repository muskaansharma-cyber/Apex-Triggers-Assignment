public with sharing class OpportunityGeoFuture {
   @future(callout=true)
    public static void populateCityState(Set<Id> oppIds) {

        List<Opportunity> oppList = [
            SELECT Id, Zip_Code__c
            FROM Opportunity
            WHERE Id IN :oppIds
        ];

        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for (Opportunity opp : oppList) {

            if (opp.Zip_Code__c == null) continue;

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.zippopotam.us/us/' + opp.Zip_Code__c);
            req.setMethod('GET');

            Http http = new Http();

            try {
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {

                    Map<String, Object> responseMap =
                        (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                    List<Object> places =
                        (List<Object>) responseMap.get('places');

                    if (!places.isEmpty()) {

                        Map<String, Object> place =
                            (Map<String, Object>) places[0];

                        Opportunity updateOpp = new Opportunity(
                            Id = opp.Id,
                            City__c = (String) place.get('place name'),
                            State__c = (String) place.get('state')
                        );

                        oppsToUpdate.add(updateOpp);
                    }
                }
            } catch (Exception e) {
                System.debug('Zip API error: ' + e.getMessage());
            }
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}