import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import AGENT_FILTER_CHANNEL
    from '@salesforce/messageChannel/agentFilterChannel__c';

import getAgents
    from '@salesforce/apex/PublicAgentFinderController.getAgents';

export default class AgentResultsGrid extends LightningElement {

    agents;
    city;
    language;
    subscription;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            AGENT_FILTER_CHANNEL,
            (message) => this.handleFilterChange(message)
        );
    }

    handleFilterChange(message) {
        this.city = message.city;
        this.language = message.language;
        this.loadAgents();
    }

    loadAgents() {
        getAgents({ city: this.city, language: this.language })
            .then(result => {
                this.agents = result;
            })
            .catch(error => {
                console.error(error);
            });
    }
}
