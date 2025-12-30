@isTest
public class AccountCustomerEnrichmentBatchTest {

    private class AgifyApiMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            res.setBody(
                '{"name":"company","age":12,"count":500}'
            );

            return res;
        }
    }

    @isTest
    static void testAccountCustomerEnrichmentBatch() {

        List<Account> accounts = new List<Account>{
            new Account(Name = 'Infosys'),
            new Account(Name = 'TCS')
        };
        insert accounts;

        Test.setMock(HttpCalloutMock.class, new AgifyApiMock());

        Test.startTest();
        Database.executeBatch(new AccountCustomerEnrichmentBatch(), 5);
        Test.stopTest();

        List<Account> updatedAccounts = [
            SELECT Company_Age__c, Company_Maturity__c
            FROM Account
            WHERE Id IN :accounts
        ];

        System.assertEquals(2, updatedAccounts.size());

        for (Account acc : updatedAccounts) {
            System.assertEquals(12, acc.Company_Age__c);
            System.assertEquals('Growing', acc.Company_Maturity__c);
        }
    }
}
