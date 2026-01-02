public class LicenseEmailSender implements Queueable {
    private Id subscriptionId;

    public LicenseEmailSender(Id subscriptionId){
        this.subscriptionId = subscriptionId;
    }

    public void execute(QueueableContext qc){
        Subscription__c sub = [SELECT Id, License_Key__c, Account__c
                               FROM Subscription__c
                               WHERE Id = :subscriptionId
                               LIMIT 1];

        if(String.isBlank(sub.License_Key__c)) return;

        Account acc = [SELECT Id, PersonContactId FROM Account WHERE Id = :sub.Account__c LIMIT 1];

        if(acc.PersonContactId == null) return;

        Contact con = [SELECT Id, Email, FirstName FROM Contact WHERE Id = :acc.PersonContactId LIMIT 1];

        if(String.isBlank(con.Email)) return;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {con.Email});
        mail.setSubject('Your License Key');
        mail.setPlainTextBody('Hello ' + con.FirstName + ',\n\nYour license key is: ' + sub.License_Key__c + '\n\nThank you.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}
