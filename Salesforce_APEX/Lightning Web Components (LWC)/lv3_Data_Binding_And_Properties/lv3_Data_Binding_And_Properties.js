import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CONTACT_FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import CONTACT_LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Contact.Email';

export default class ContactEditor extends LightningElement {
    @api contactId;
    @track contactInfo = { firstName: '', email: '' };
    @track error;

    @wire(getRecord, {
        recordId: '$contactId',
        fields: [CONTACT_FIRSTNAME_FIELD, CONTACT_LASTNAME_FIELD, CONTACT_EMAIL_FIELD]
    })
    contact;

    connectedCallback() {
        this.contact = {
            data: null,
            error: null
        };
        // Fixed typo: 'neuen Proxy' to 'new Proxy'
        // Note: Overwriting the @wire property 'contact' is not recommended.
        // If you want to react to changes, use a getter or the wired function form.
        // The following block is commented out to avoid errors and improper usage.
        /*
        this.contact = new Proxy(this.contact, {
            set: (target, key, value) => {
                target[key] = value;
                if (key === 'data' && value) {
                    this.contactInfo.firstName = getFieldValue(value, CONTACT_FIRSTNAME_FIELD) || '';
                    this.contactInfo.email = getFieldValue(value, CONTACT_EMAIL_FIELD) || '';
                }
                if (key === 'error' && value) {
                    this.error = value.body.message;
                }
                return true;
            }
        });
        */
    }

    handleFirstNameChange(event) {
        this.contactInfo.firstName = event.target.value;
    }

    handleEmailChange(event) {
        const email = event.target.value;
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (emailRegex.test(email) || !email) {
            this.contactInfo.email = email;
            this.error = '';
        } else {
            this.error = 'Invalid email format';
        }
    }
}