import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import AGENT_FILTER_CHANNEL
    from '@salesforce/messageChannel/agentFilterChannel__c';

export default class AgentFilterSidebar extends LightningElement {

    city;
    language;

    @wire(MessageContext)
    messageContext;

    languageOptions = [
        { label: 'English', value: 'English' },
        { label: 'Spanish', value: 'Spanish' },
        { label: 'Hindi', value: 'Hindi' }
    ];

    handleCityChange(event) {
        this.city = event.target.value;
        this.publishFilters();
    }

    handleLanguageChange(event) {
        this.language = event.detail.value;
        this.publishFilters();
    }

    publishFilters() {
        publish(this.messageContext, AGENT_FILTER_CHANNEL, {
            city: this.city,
            language: this.language
        });
    }
}
