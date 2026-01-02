global class RenewalOpportunityScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date targetDate = Date.today().addDays(90);
        List<Subscription__c> subs = [SELECT Id, Name, Account__c, Product__c, End_Date_Actual__c
                                     FROM Subscription__c
                                     WHERE End_Date_Actual__c = :targetDate
                                     AND Status__c = 'Active'];

        if(subs.isEmpty()) return;

        Set<Id> subIds = new Set<Id>();
        for(Subscription__c s: subs) subIds.add(s.Id);

        Map<Id, Opportunity> existing = new Map<Id, Opportunity>();
        for(Opportunity o: [SELECT Id, Subscription__c
                            FROM Opportunity
                            WHERE Subscription__c IN :subIds
                            AND Type = 'Renewal']) {
            existing.put(o.Subscription__c, o);
        }

        List<Opportunity> oppsToInsert = new List<Opportunity>();
        for(Subscription__c s: subs){
            if(!existing.containsKey(s.Id)){
                oppsToInsert.add(new Opportunity(
                    Name = 'Renewal - ' + s.Name,
                    AccountId = s.Account__c,
                    StageName = 'Prospecting',
                    CloseDate = s.End_Date_Actual__c,
                    Type = 'Renewal',
                    Subscription__c = s.Id
                ));
            }
        }

        if(!oppsToInsert.isEmpty()) insert oppsToInsert;
    }
}
