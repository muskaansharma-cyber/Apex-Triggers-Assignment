import { LightningElement } from 'lwc';

export default class SafetyCheckStep extends LightningElement {
    completed = false;

    handleSafetyComplete() {
        this.completed = true;
        this.dispatchEvent(new CustomEvent('completed', {
            detail: { step: 'safetyCheck' }
        }));
    }
}
