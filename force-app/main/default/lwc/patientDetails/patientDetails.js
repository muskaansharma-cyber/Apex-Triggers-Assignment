import { LightningElement, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import PATIENT_CHANNEL from '@salesforce/messageChannel/patientChannel__c';
import getPatientDetails from '@salesforce/apex/WaitingListController.getPatientDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PatientDetails extends LightningElement {
    @track patient;

    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            PATIENT_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    async handleMessage(message) {
        const patientId = message.patientId;
        try {
            this.patient = await getPatientDetails({ patientId });
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    callPatient() {
        this.showToast('Info', `${this.patient.Name} called to room`, 'info');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}
