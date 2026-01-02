global class StaleListingAuditor implements Schedulable {

    global void execute(SchedulableContext sc) {

        DateTime cutoffDate = System.now().addDays(-60);

        List<AggregateResult> groupedResults = [
            SELECT OwnerId ownerId, COUNT(Id) total
            FROM Opportunity
            WHERE StageName = 'Available'
            AND LastModifiedDate < :cutoffDate
            GROUP BY OwnerId
        ];

        if (groupedResults.isEmpty()) {
            return;
        }

        List<Opportunity> staleProperties = [
            SELECT Id, Name, OwnerId
            FROM Opportunity
            WHERE StageName = 'Available'
            AND LastModifiedDate < :cutoffDate
        ];

        for (Opportunity opp : staleProperties) {
            opp.StageName = 'Review';
        }
        update staleProperties;

        String emailBody = 'Stale Property Review Summary (60+ days)\n\n';
        emailBody += 'Owner Name | Count of Properties\n';
        emailBody += '--------------------------------\n';

        Set<Id> ownerIds = new Set<Id>();
        for (AggregateResult ar : groupedResults) {
            ownerIds.add((Id) ar.get('ownerId'));
        }

        Map<Id, User> ownerMap = new Map<Id, User>(
            [SELECT Id, Name FROM User WHERE Id IN :ownerIds]
        );

        for (AggregateResult ar : groupedResults) {
            Id ownerId = (Id) ar.get('ownerId');
            Integer countProp = (Integer) ar.get('total');
            emailBody += ownerMap.get(ownerId).Name + ' | ' + countProp + '\n';
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(
            new List<String>{ System.Label.Property_Manager_Email }
        );
        email.setSubject('Weekly Stale Property Audit');
        email.setPlainTextBody(emailBody);

        Messaging.sendEmail(
            new List<Messaging.SingleEmailMessage>{ email }
        );
    }
}
