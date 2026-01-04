public class AppointmentBillingQueueable implements Queueable, Database.AllowsCallouts {

    private Id appointmentId;

    public AppointmentBillingQueueable(Id appointmentId){
        this.appointmentId = appointmentId;
    }

    public void execute(QueueableContext qc){
        Appointment__c appt = [
            SELECT Id, Status__c, Billing_Sync_Status__c, Billing_Sync_Attempts__c,
                   Billing_Amount__c
            FROM Appointment__c
            WHERE Id = :appointmentId
            LIMIT 1
        ];

        if(appt.Status__c != 'Completed' || appt.Billing_Sync_Status__c == 'Success'){
            return;
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Finance_System/billing');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        req.setBody(JSON.serialize(new Map<String,Object>{
            'appointmentId' => appt.Id,
            'amount' => appt.Billing_Amount__c
        }));

        Http http = new Http();
        try{
            HttpResponse res = http.send(req);

            if(res.getStatusCode() == 200){
                appt.Billing_Sync_Status__c = 'Success';
                appt.Billing_Sent__c = true;
            } else {
                appt.Billing_Sync_Status__c = 'Failed';
                appt.Billing_Sync_Attempts__c++;
                appt.Billing_Error_Message__c = res.getBody();
            }
        } catch(Exception e){
            appt.Billing_Sync_Status__c = 'Failed';
            appt.Billing_Sync_Attempts__c++;
            appt.Billing_Error_Message__c = e.getMessage();
        }

        appt.Last_Billing_Sync_Date__c = System.now();
        update appt;
    }
}
