@RestResource(urlMapping='/iot/failure')
global with sharing class IoTFailureAlertService {

    @HttpPost
    global static String receiveFailureAlert() {

        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();

        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(body);

        String serialNumber = (String) payload.get('serialNumber');
        String errorCode    = (String) payload.get('errorCode');

        if (String.isBlank(serialNumber) || String.isBlank(errorCode)) {
            throw new AuraHandledException('Missing serialNumber or errorCode');
        }

        Asset asset = [
            SELECT Id, AccountId, ContactId
            FROM Asset
            WHERE SerialNumber = :serialNumber
            LIMIT 1
        ];

  
        Case c = new Case(
            Subject = 'IoT Failure Alert - ' + errorCode,
            Status = 'New',
            Origin = 'IoT',
            Priority = 'High',
            AccountId = asset.AccountId,
            ContactId = asset.ContactId,
            AssetId = asset.Id,
            Error_Code__c = errorCode
        );
        insert c;

        Work_Order__c wo = new Work_Order__c(
            Subject = 'IoT Repair',
            Status = 'New',
            Priority = 'High',
            AccountId = asset.AccountId,
            AssetId = asset.Id,
            CaseId = c.Id,
            Diagnostic_Code__c = errorCode
        );
        insert wo;

        return 'SUCCESS: Case ' + c.Id + ' and Work Order ' + wo.Id + ' created';
    }
}
