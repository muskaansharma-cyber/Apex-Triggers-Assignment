import { LightningElement } from 'lwc';

export default class PatientIntakeForm extends LightningElement {

    async handleSaveAll() {
        try {
            const patientInfo = this.template.querySelector('c-patient-info-form');
            const insurance = this.template.querySelector('c-insurance-form');
            const vitals = this.template.querySelector('c-vitals-form');

            // Call submit() on all children
            await Promise.all([
                patientInfo.submit(),
                insurance.submit(),
                vitals.submit()
            ]);

            // Optional toast
            this.showToast('Success', 'All data saved successfully', 'success');

        } catch (error) {
            this.showToast('Error', error.message, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}
