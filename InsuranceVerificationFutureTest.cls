@isTest
public class InsuranceVerificationFutureTest {

    private class ZipApiMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(
                '{"places":[{"state abbreviation":"NY"}]}'
            );
            return res;
        }
    }

    @testSetup
    static void setupPatients() {

        Id personRtId = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Person Account')
            .getRecordTypeId();

        Account patient = new Account(
            RecordTypeId = personRtId,
            LastName = 'Patient One',
            PersonFirstName = 'John',
            Zip_Code__c = '10001',
            Insurance_Status__c = 'Pending'
        );

        insert patient;
    }

    @isTest
    static void testInsuranceVerification() {

        Test.setMock(HttpCalloutMock.class, new ZipApiMock());

        Account acc = [
            SELECT Id
            FROM Account
            WHERE IsPersonAccount = TRUE
            LIMIT 1
        ];

        Test.startTest();
            InsuranceVerificationFuture.verifyInsurance(
                new Set<Id>{ acc.Id }
            );
        Test.stopTest();

        Account updated = [
            SELECT State__c, Insurance_Status__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals('NY', updated.State__c);
        System.assertEquals('Verified', updated.Insurance_Status__c);
    }
}
