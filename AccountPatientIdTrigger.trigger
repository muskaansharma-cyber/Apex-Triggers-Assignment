trigger AccountPatientIdTrigger on Account (before insert) {

    Integer currentYear = System.today().year();
    String prefix = 'PAT-' + currentYear + '-';

    List<Account> lastPatients = [
        SELECT Patient_ID__c
        FROM Account
        WHERE Patient_ID__c LIKE :prefix + '%'
        ORDER BY Patient_ID__c DESC
        LIMIT 1
    ];

    Integer nextNumber = 1;

    if (!lastPatients.isEmpty() && lastPatients[0].Patient_ID__c != null) {
        String lastNumberStr = lastPatients[0].Patient_ID__c.right(3);
        nextNumber = Integer.valueOf(lastNumberStr) + 1;
    }

    for (Account acc : Trigger.new) {

        if (acc.IsPersonAccount && acc.Patient_ID__c == null) {

            String formattedNumber =
                String.valueOf(nextNumber).leftPad(3, '0');

            acc.Patient_ID__c = prefix + formattedNumber;
            nextNumber++;
        }
    }
}