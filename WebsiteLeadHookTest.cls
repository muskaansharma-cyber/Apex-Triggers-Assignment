@IsTest
public class WebsiteLeadHookTest {

    private static Id getPersonRtId() {
        return Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Person Account')
            .getRecordTypeId();
    }

    @IsTest
    static void testCreatePersonAccount() {

        Property__c prop = new Property__c(Name = 'Test Property');
        insert prop;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/LeadCreate/';
        req.requestBody = Blob.valueOf(
            '{"firstName":"Amit","lastName":"Sharma","email":"amit@test.com","phone":"9999999999","propertyId":"' +
            prop.Id + '"}'
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WebsiteLeadHook.LeadResponse response =
            WebsiteLeadHook.createOrUpdatePersonAccount();
        Test.stopTest();

        Account acc = [
            SELECT PersonEmail, Property__c
            FROM Account
            WHERE PersonEmail = 'amit@test.com'
            LIMIT 1
        ];

        System.assertEquals(prop.Id, acc.Property__c);
        System.assertEquals(true, response.success);
    }

    @IsTest
    static void testUpdatePersonAccount() {

        Id rtId = getPersonRtId();

        Account acc = new Account(
            RecordTypeId = rtId,
            FirstName = 'Old',
            LastName = 'Name',
            PersonEmail = 'existing@test.com'
        );
        insert acc;

        Property__c prop = new Property__c(Name = 'Updated Property');
        insert prop;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/LeadCreate/';
        req.requestBody = Blob.valueOf(
            '{"firstName":"New","lastName":"Name","email":"existing@test.com","propertyId":"' +
            prop.Id + '"}'
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WebsiteLeadHook.createOrUpdatePersonAccount();
        Test.stopTest();

        Account updated = [
            SELECT FirstName, Property__c
            FROM Account
            WHERE PersonEmail = 'existing@test.com'
            LIMIT 1
        ];

        System.assertEquals('New', updated.FirstName);
        System.assertEquals(prop.Id, updated.Property__c);
    }
}
