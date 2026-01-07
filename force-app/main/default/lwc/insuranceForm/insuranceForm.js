import { LightningElement, api, track } from 'lwc';

export default class InsuranceForm extends LightningElement {

    @track provider;
    @track policyNumber;

    @api
    submit() {
        if (!this.provider) {
            throw new Error('Insurance Provider required');
        }

        console.log('Saving Insurance', this.provider, this.policyNumber);
        return Promise.resolve();
    }
}
