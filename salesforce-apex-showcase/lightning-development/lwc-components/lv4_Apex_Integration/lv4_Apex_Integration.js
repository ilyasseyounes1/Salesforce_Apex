import { LightningElement, track } from 'lwc';
import getContacts from '@salesforce/apex/ContactController.getContacts';

export default class ContactListImperative extends LightningElement {
    @track contacts;
    @track error;
    isLoading = false;

    handleLoadContacts() {
        this.isLoading = true;
        getContacts()
            .then(result => {
                this.contacts = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.contacts = undefined;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}
