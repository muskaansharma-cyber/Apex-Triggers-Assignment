import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import PATIENT_CHANNEL from '@salesforce/messageChannel/patientChannel__c';
import getCheckedInPatients from '@salesforce/apex/WaitingListController.getCheckedInPatients';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Patient Name', fieldName: 'Name' },
    { label: 'Check-In Time', fieldName: 'Check_In_Time__c', type: 'date' },
    {
        type: 'button',
        typeAttributes: { label: 'Select', name: 'select', variant: 'brand' }
    }
];

export default class WaitingList extends LightningElement {
    patients = [];
    columns = COLUMNS;

    @wire(MessageContext)
    messageContext;

    @wire(getCheckedInPatients)
    wiredPatients({ data, error }) {
        if (data) {
            this.patients = data;
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    handleRowAction(event) {
        const patientId = event.detail.row.Id;
        publish(this.messageContext, PATIENT_CHANNEL, { patientId });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}
