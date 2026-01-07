import { LightningElement, api } from 'lwc';

export default class ListingInfoStep extends LightningElement {

    @api draft={};

    get name() { return this.draft?.Name; }
    get amount() { return this.draft?.Amount; }
    get closeDate() { return this.draft?.CloseDate; }
    get stage() { return this.draft?.StageName; }

    stageOptions = [
        { label: 'Prospecting', value: 'Prospecting' },
        { label: 'Qualification', value: 'Qualification' },
        { label: 'Proposal', value: 'Proposal' }
    ];

  handleChange(event) {
    const field = event.target.dataset.field;

    const temp = Object.assign({}, this.draft);
    temp[field] = event.target.value;

    this.draft = temp;
}

    next() {
        this.dispatchEvent(
            new CustomEvent('next', { detail: this.draft })
        );
    }
}
