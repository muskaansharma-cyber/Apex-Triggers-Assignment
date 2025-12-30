public class PatientAgeDataQualityBatch
    implements Database.Batchable<SObject>,
               Database.AllowsCallouts,
               Database.Stateful {

    public Integer totalChecked = 0;
    public Integer totalMismatched = 0;
    public Integer totalErrors = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            'SELECT Id, PersonFirstName, PersonBirthdate'+
            ' FROM Account '+ 
            'WHERE IsPersonAccount = TRUE'+
            ' AND PersonBirthdate != NULL'+
            ' AND PersonFirstName != NULL'
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {

        List<Account> updates = new List<Account>();

        for (Account acc : scope) {

            try {
                Integer sfAge = calculateAge(acc.PersonBirthdate);

                HttpRequest req = new HttpRequest();
                req.setEndpoint(
                    'https://api.agify.io/?name=' +
                    EncodingUtil.urlEncode(acc.PersonFirstName, 'UTF-8')
                );
                req.setMethod('GET');

                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {

                    Map<String, Object> data =
                        (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                    if (data.get('age') != null) {

                        Integer apiAge = (Integer) data.get('age');

                        acc.Calculated_Age__c = sfAge;
                        acc.API_Estimated_Age__c = apiAge;

                        if (Math.abs(sfAge - apiAge) > 3) {
                            acc.Age_Mismatch__c = true;
                            totalMismatched++;
                        } else {
                            acc.Age_Mismatch__c = false;
                        }

                        updates.add(acc);
                        totalChecked++;
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
        System.debug('Checked: ' + totalChecked);
        System.debug('Mismatches: ' + totalMismatched);
        System.debug('Errors: ' + totalErrors);
    }

    private Integer calculateAge(Date dob) {
        Date today = Date.today();
        Integer age = today.year() - dob.year();
        if (today < dob.addYears(age)) {
            age--;
        }
        return age;
    }
}
