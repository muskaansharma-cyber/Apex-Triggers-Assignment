import { LightningElement, track } from 'lwc';
import createProperty from '@salesforce/apex/PropertyWizardController.createProperty';

export default class ListingWizardContainer extends LightningElement {

    @track currentStep = 1;
    @track draft = {};

    get isStep1() { return this.currentStep === 1; }
    get isStep2() { return this.currentStep === 2; }
    get isStep3() { return this.currentStep === 3; }

    handleNext(event) {
        this.draft = { ...this.draft, ...event.detail };
        this.currentStep++;
    }

    handleBack() {
        this.currentStep--;
    }

    async handleSubmit(event) {
        this.draft = { ...this.draft, ...event.detail };
        await createProperty({ payload: this.draft });
        this.currentStep = 1;
        this.draft = {};
        alert('Property created successfully!');
    }
}
