import { LightningElement, api, track } from 'lwc';

export default class PatientInfoForm extends LightningElement {

    @track name;
    @track phone;

    handleChange(event) {
        this[event.target.label.toLowerCase().replace(' ', '')] =
            event.target.value;
    }

    @api
    async submit() {
       
        if (!this.name) {
            throw new Error('Patient Name is required');
        }

        console.log('Saving Patient Info', {
            name: this.name,
            phone: this.phone
        });

        return Promise.resolve();
    }
}
