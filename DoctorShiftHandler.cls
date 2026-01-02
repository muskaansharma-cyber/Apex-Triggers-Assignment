public class DoctorShiftHandler implements Queueable {

    private Id doctorId;

    public DoctorShiftHandler(Id doctorId) {
        this.doctorId = doctorId;
    }

    public void execute(QueueableContext qc) {
        Date today = Date.today();

        List<Appointment__c> appointments = [
            SELECT Id, Status__c, Assigned_Doctor__c, Assigned_Doctor__r.Backup_Doctor__c
            FROM Appointment__c
            WHERE Assigned_Doctor__c = :doctorId
            AND Appointment_Date__c = :today
        ];

        if(appointments.isEmpty()) return;

        List<Appointment__c> updates = new List<Appointment__c>();

        for(Appointment__c appt : appointments){
 
            if(appt.Assigned_Doctor__r.Backup_Doctor__c != null){
                appt.Assigned_Doctor__c = appt.Assigned_Doctor__r.Backup_Doctor__c;
            } else {
                appt.Status__c = 'Holding Queue';
            }
            updates.add(appt);
        }

        if(!updates.isEmpty()){
            update updates;
        }
    }
}
