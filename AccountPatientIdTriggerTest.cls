@IsTest
public class AccountPatientIdTriggerTest {

    @IsTest
    static void testPatientIdGeneration_FirstRecord() {

        Id personRtId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Account'
            AND IsPersonType = true
            LIMIT 1
        ].Id;

        Account acc = new Account(
            RecordTypeId = personRtId,
            LastName     = 'Test Patient'
        );

        Test.startTest();
            insert acc;
        Test.stopTest();

        Account insertedAcc = [
            SELECT Patient_ID__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        Integer currentYear = System.today().year();
        String expectedPrefix = 'PAT-' + currentYear + '-';

        System.assertNotEquals(
            null,
            insertedAcc.Patient_ID__c
        );

        System.assert(
            insertedAcc.Patient_ID__c.startsWith(expectedPrefix)
        );

        System.assertEquals(
            expectedPrefix + '001',
            insertedAcc.Patient_ID__c
        );
    }

    @IsTest
    static void testPatientIdGeneration_IncrementLogic() {

        Id personRtId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Account'
            AND IsPersonType = true
            LIMIT 1
        ].Id;

        Integer currentYear = System.today().year();
        String prefix = 'PAT-' + currentYear + '-';

        Account existingAcc = new Account(
            RecordTypeId  = personRtId,
            LastName      = 'Existing Patient',
            Patient_ID__c = prefix + '005'
        );
        insert existingAcc;

        Account newAcc = new Account(
            RecordTypeId = personRtId,
            LastName     = 'New Patient'
        );

        Test.startTest();
            insert newAcc;
        Test.stopTest();

        Account insertedAcc = [
            SELECT Patient_ID__c
            FROM Account
            WHERE Id = :newAcc.Id
        ];

        System.assertEquals(
            prefix + '006',
            insertedAcc.Patient_ID__c
        );
    }
}
