public class InsuranceVerificationFuture {

    @future(callout=true)
    public static void verifyInsurance(Set<Id> accountIds) {

        List<Account> patients = [
            SELECT Id, Zip_Code__c
            FROM Account
            WHERE Id IN :accountIds
            AND IsPersonAccount = TRUE
            AND Zip_Code__c != NULL
        ];

        List<Account> updates = new List<Account>();

        for (Account acc : patients) {

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

                        acc.State__c = state;

                        if (state == 'NY') {
                            acc.Insurance_Status__c = 'Verified';
                        } else {
                            acc.Insurance_Status__c = 'Expired';
                        }

                        updates.add(acc);
                    }
                }
            }
            catch (Exception e) {
                acc.Insurance_Status__c = 'Pending';
                acc.Insurance_API_Error__c = e.getMessage();
                updates.add(acc);
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }
}
