import { LightningElement, track } from 'lwc';
import getWorkOrderStatus from '@salesforce/apex/TrackMyTechController.getWorkOrderStatus';

export default class TrackMyTech extends LightningElement {

    @track data;
    @track error;

    connectedCallback() {
        const params = new URLSearchParams(window.location.search);
        const workOrderId = params.get('orderId');

        if (!workOrderId) {
            this.error = 'Invalid tracking link';
            return;
        }

        getWorkOrderStatus({ workOrderId })
            .then(result => {
                this.data = result;
            })
            .catch(err => {
                this.error = err.body?.message || 'Unable to load status';
            });
    }

    get orderedDone() {
        return this.data && ['New','Dispatched','On Site'].includes(this.data.status);
    }

    get dispatchedDone() {
        return this.data && ['Dispatched','On Site'].includes(this.data.status);
    }

    get arrivingDone() {
        return this.data && this.data.status === 'On Site';
    }
}
