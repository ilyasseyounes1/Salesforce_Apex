import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import ACCOUNT_INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import ACCOUNT_REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';

export default class RecordDisplay extends LightningElement {
    @api recordId; // Public property to receive Account ID
    @track annualRevenue = 0; // Reactive property for user input
    @track error; // Store errors from @wire

    // Wire adapter to fetch Account data
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [ACCOUNT_NAME_FIELD, ACCOUNT_INDUSTRY_FIELD, ACCOUNT_REVENUE_FIELD]
    })
    account;

    // Initialize annualRevenue from fetched data
    connectedCallback() {
        this.account = {
            data: null,
            error: null
        };
        this.account = new Proxy(this.account, {
            set: (target, key, value) => {
                target[key] = value;
                if (key === 'data' && value) {
                    this.annualRevenue = getFieldValue(value, ACCOUNT_REVENUE_FIELD) || 0;
                }
                if (key === 'error' && value) {
                    this.error = value;
                }
                return true;
            }
        });
    }

    // Handle input changes
    handleRevenueChange(event) {
        const value = event.target.value;
        this.annualRevenue = Number.isFinite(Number(value)) ? Number(value) : this.annualRevenue;
    }
}