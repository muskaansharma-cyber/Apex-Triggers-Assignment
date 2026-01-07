import { LightningElement, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';

import chartJs from '@salesforce/resourceUrl/ChartJS';
import getSoldPriceTrend from
    '@salesforce/apex/MarketAnalyticsController.getSoldPriceTrend';

export default class PriceTrendChart extends LightningElement {

    chart;
    chartJsInitialized = false;
    chartData;

    @wire(getSoldPriceTrend)
    wiredData({ data, error }) {
        if (data) {
            this.chartData = data;
            this.renderChart();
        } else if (error) {
            console.error(error);
        }
    }

    renderedCallback() {
        if (this.chartJsInitialized) {
            return;
        }
        this.chartJsInitialized = true;

        loadScript(this, chartJs)
            .then(() => {
                if (this.chartData) {
                    this.renderChart();
                }
            })
            .catch(error => {
                console.error('ChartJS load error', error);
            });
    }

    renderChart() {
        if (this.chart) {
            return;
        }

        const ctx =
            this.template.querySelector('canvas').getContext('2d');

        const labels = this.chartData.map(
            item => `${item.month}/${item.year}`
        );

        const values = this.chartData.map(
            item => item.total
        );

        this.chart = new window.Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Sold Property Price',
                    data: values,
                    fill: false
                }]
            },
            options: {
                responsive: true
            }
        });
    }
}
