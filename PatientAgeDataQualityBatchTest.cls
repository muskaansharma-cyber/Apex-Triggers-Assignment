@isTest
public class PatientAgeDataQualityBatchTest {

    private class AgifyMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"name":"john","age":45}');
            return res;
        }
    }

    @testSetup
    static void setupPatients() {

        Id personRtId = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Person Account')
            .getRecordTypeId();

        List<Account> patients = new List<Account>();

        for (Integer i = 0; i < 50; i++) {
            patients.add(new Account(
                RecordTypeId = personRtId,
                LastName = 'Patient ' + i,
                PersonFirstName = 'John',
                PersonBirthdate = Date.today().addYears(-30)
            ));
        }

        insert patients;
    }

    @isTest
    static void testBatchExecution() {

        Test.setMock(HttpCalloutMock.class, new AgifyMock());

        Test.startTest();
            Database.executeBatch(
                new PatientAgeDataQualityBatch(),
                25
            );
        Test.stopTest();

        List<Account> results = [
            SELECT Calculated_Age__c,
                   API_Estimated_Age__c,
                   Age_Mismatch__c
            FROM Account
            WHERE IsPersonAccount = TRUE
        ];

        System.assertEquals(50, results.size());

        for (Account a : results) {
            System.assertEquals(30, a.Calculated_Age__c);
            System.assertEquals(45, a.API_Estimated_Age__c);
            System.assertEquals(true, a.Age_Mismatch__c);
        }
    }
}
