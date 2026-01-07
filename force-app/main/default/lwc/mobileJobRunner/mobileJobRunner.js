import { LightningElement, track } from 'lwc';

export default class MobileJobRunner extends LightningElement {
    @track jobProgress = {
        safetyCheck: false,
        partsUsed: false,
        signature: false
    };

    get isCompleteEnabled() {
        return Object.values(this.jobProgress).every(Boolean);
    }

    handleStepCompleted(event) {
        const stepName = event.detail.step;
        this.jobProgress[stepName] = true;
    }

    handleCompleteJob() {
        console.log('Job Completed!');

    }
}
