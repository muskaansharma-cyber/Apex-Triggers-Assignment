import { LightningElement } from 'lwc';
import getWeeklyRoster from '@salesforce/apex/RosterExporterController.getWeeklyRoster';
import { loadScript } from 'lightning/platformResourceLoader';
import SHEETJS from '@salesforce/resourceUrl/SheetJS';

export default class RosterExporter extends LightningElement {
    sheetJsInitialized = false;

    renderedCallback() {
        if (this.sheetJsInitialized) return;

        loadScript(this, SHEETJS)
            .then(() => {
                this.sheetJsInitialized = true;
                console.log('SheetJS loaded');
            })
            .catch(error => {
                console.error('Error loading SheetJS', error);
            });
    }

    async downloadRoster() {
        if (!this.sheetJsInitialized) {
            console.error('SheetJS not loaded yet');
            return;
        }

        try {
            const appointments = await getWeeklyRoster();

            if (!appointments || appointments.length === 0) {
                alert('No appointments this week');
                return;
            }

            const data = appointments.map(app => ({
                Doctor: app.Doctor__c,
                Patient: app.Patient__r ? app.Patient__r.Name : '',
                'Start Time': app.Start_Time__c,
                'End Time': app.End_Time__c
            }));

            const ws = XLSX.utils.json_to_sheet(data);

            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Weekly Roster');

            XLSX.writeFile(wb, 'Weekly_Roster.xlsx');

        } catch (error) {
            console.error(error);
            alert('Error generating roster: ' + error.body?.message || error.message);
        }
    }
}
