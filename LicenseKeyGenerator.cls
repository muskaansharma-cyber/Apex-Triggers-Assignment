public class LicenseKeyGenerator implements Queueable {

    private Id subscriptionId;

    public LicenseKeyGenerator(Id subscriptionId){
        this.subscriptionId = subscriptionId;
    }

    public void execute(QueueableContext qc){
        Subscription__c sub = [SELECT Id, License_Key__c, License_Provisioned__c, Account__c, Status__c
                               FROM Subscription__c
                               WHERE Id = :subscriptionId
                               LIMIT 1];

        if(sub.Status__c != 'Active' || sub.License_Provisioned__c) return;

        // Generate License Key
        String key = 'LIC-' + String.valueOf(Math.abs(Crypto.getRandomInteger())).right(8);
        sub.License_Key__c = key;
        sub.License_Provisioned__c = true;
        update sub;

        // Chain email job
        System.enqueueJob(new LicenseEmailSender(sub.Id));
    }
}
