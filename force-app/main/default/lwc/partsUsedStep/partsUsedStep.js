import { LightningElement } from 'lwc';

export default class PartsUsedStep extends LightningElement {
    handlePartsUsedComplete() {
        this.dispatchEvent(new CustomEvent('completed', {
            detail: { step: 'partsUsed' }
        }));
    }
}
