import { LightningElement, wire } from 'lwc';
import getOpenWorkOrders from '@salesforce/apex/WorkOrderMapController.getOpenWorkOrders';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import LEAFLET from '@salesforce/resourceUrl/leaflet';

export default class TerritoryVisualizer extends LightningElement {
    mapInitialized = false;
    map;

    @wire(getOpenWorkOrders)
    wiredWorkOrders({ error, data }) {
        if (data) {
            this.plotMarkers(data);
        } else if (error) {
            console.error('Error fetching work orders', error);
        }
    }

    renderedCallback() {
        if (this.mapInitialized) return;

        Promise.all([
            loadScript(this, LEAFLET + '/leaflet.js'),
            loadStyle(this, LEAFLET + '/leaflet.css')
        ])
        .then(() => {
            this.initializeMap();
            this.mapInitialized = true;
        })
        .catch(error => console.error('Error loading Leaflet', error));
    }

    initializeMap() {
        const mapContainer = this.template.querySelector('.map');
        this.map = L.map(mapContainer).setView([37.7749, -122.4194], 10);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(this.map);
    }

    plotMarkers(workOrders) {
        if (!this.map) return;

        workOrders.forEach(wo => {
            const color = wo.Priority === 'High' ? 'red' : 'green';
            L.circleMarker([wo.Lat, wo.Lng], {
                color: color,
                radius: 8,
                fillOpacity: 0.7
            })
            .bindPopup(`WO Id: ${wo.Id}<br>Priority: ${wo.Priority}`)
            .addTo(this.map);
        });
    }
}
