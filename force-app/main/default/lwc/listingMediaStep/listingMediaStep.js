import { LightningElement, api } from 'lwc';

export default class ListingMediaStep extends LightningElement {

    @api draft;

    submit() {
        this.dispatchEvent(new CustomEvent('submit', { detail: this.draft }));
    }

    back() {
        this.dispatchEvent(new CustomEvent('back'));
    }
}
