@IsTest
public class PersonAccountAgeVerificationBatchTest {

    private class AgifySuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"name":"John","age":35,"count":100}');
            return res;
        }
    }

    private class AgifyNullAgeMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"name":"Jane","age":null,"count":50}');
            return res;
        }
    }

    private class AgifyErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('API failure');
        }
    }

    private static Account createPersonAccount(String firstName) {
        Id personRtId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Account'
            AND IsPersonType = TRUE
            LIMIT 1
        ].Id;

        Account acc = new Account();
        acc.RecordTypeId = personRtId;
        acc.FirstName = firstName;
        acc.LastName = 'Test';
        acc.PersonEmail = firstName + '@test.com';
        insert acc;

        return acc;
    }

    @IsTest
    static void testAgePredictionSuccess() {

        Account acc = createPersonAccount('John');

        Test.setMock(HttpCalloutMock.class, new AgifySuccessMock());

        Test.startTest();
        Database.executeBatch(new PersonAccountAgeVerificationBatch(), 1);
        Test.stopTest();

        Account updatedAcc = [
            SELECT Predicted_Age__c, Age_Verified__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(35, updatedAcc.Predicted_Age__c);
        System.assertEquals(true, updatedAcc.Age_Verified__c);
    }

    @IsTest
    static void testNullAgeResponse() {

        Account acc = createPersonAccount('Jane');

        Test.setMock(HttpCalloutMock.class, new AgifyNullAgeMock());

        Test.startTest();
        Database.executeBatch(new PersonAccountAgeVerificationBatch(), 1);
        Test.stopTest();

        Account updatedAcc = [
            SELECT Predicted_Age__c, Age_Verified__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(null, updatedAcc.Predicted_Age__c);
        System.assertEquals(false, updatedAcc.Age_Verified__c);
    }

    @IsTest
    static void testApiExceptionHandling() {

        Account acc = createPersonAccount('ErrorUser');

        Test.setMock(HttpCalloutMock.class, new AgifyErrorMock());

        Test.startTest();
        Database.executeBatch(new PersonAccountAgeVerificationBatch(), 1);
        Test.stopTest();

        Account updatedAcc = [
            SELECT Age_API_Error__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertNotEquals(null, updatedAcc.Age_API_Error__c);
    }
}
