import { LightningElement } from 'lwc';

export default class SignatureStep extends LightningElement {
    handleSignatureComplete() {
        this.dispatchEvent(new CustomEvent('completed', {
            detail: { step: 'signature' }
        }));
    }
}
