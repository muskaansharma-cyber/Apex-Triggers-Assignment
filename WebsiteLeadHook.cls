@RestResource(urlMapping='/LeadCreate/*')
global with sharing class WebsiteLeadHook {

    global class LeadRequest {
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        public Id propertyId;
    }

    global class LeadResponse {
        public Boolean success;
        public String message;
        public Id accountId;
    }

    @HttpPost
    global static LeadResponse createOrUpdatePersonAccount() {

        LeadResponse res = new LeadResponse();

        LeadRequest input = (LeadRequest)
            JSON.deserialize(RestContext.request.requestBody.toString(), LeadRequest.class);

        if (String.isBlank(input.email)) {
            res.success = false;
            res.message = 'Email is required';
            return res;
        }

        Id personRtId = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Person Account')
            .getRecordTypeId();

        List<Account> existing = [
            SELECT Id, FirstName, LastName, PersonEmail, Phone, Property__c
            FROM Account
            WHERE IsPersonAccount = true
            AND PersonEmail = :input.email
            LIMIT 1
        ];

        Account acc;

        if (!existing.isEmpty()) {

            acc = existing[0];
            acc.FirstName  = input.firstName;
            acc.LastName   = String.isBlank(input.lastName) ? acc.LastName : input.lastName;
            acc.Phone      = input.phone;
            acc.Property__c = input.propertyId;
            update acc;

            res.message = 'Person Account updated';
        } else {

            acc = new Account(
                RecordTypeId = personRtId,
                FirstName    = input.firstName,
                LastName     = String.isBlank(input.lastName) ? 'Website Lead' : input.lastName,
                PersonEmail  = input.email,
                Phone        = input.phone,
                Property__c  = input.propertyId
            );
            insert acc;

            res.message = 'Person Account created';
        }

        res.success = true;
        res.accountId = acc.Id;
        return res;
    }
}
