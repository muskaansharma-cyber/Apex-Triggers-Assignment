import { LightningElement, api, track } from 'lwc';

export default class VitalsForm extends LightningElement {

    @track height;
    @track weight;

    @api
    submit() {
        console.log('Saving Vitals', this.height, this.weight);
        return Promise.resolve();
    }
}
