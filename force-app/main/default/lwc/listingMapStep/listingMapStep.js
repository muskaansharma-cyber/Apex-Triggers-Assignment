import { LightningElement, api } from 'lwc';

export default class ListingMapStep extends LightningElement {

    @api draft;

    handleChange(event) {
        const field = event.target.dataset.field;
        this.draft = { ...this.draft, [field]: event.target.value };
    }

    next() {
        this.dispatchEvent(new CustomEvent('next', { detail: this.draft }));
    }

    back() {
        this.dispatchEvent(new CustomEvent('back'));
    }
}
