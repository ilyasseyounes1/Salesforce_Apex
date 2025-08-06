import { LightningElement, track } from 'lwc';

export default class Lv1_Build_Custom_Contact_Card_Component extends LightningElement {
    @track greeting = 'Ilyasse younes';
    @track message = '';

    //Getter for computed property 
    get currentDate(){
        return new Date().toLocaleDateString();
    }
    //Event handler for name input change 
    handleNameChange(event){
        this.greeting = event.target.value;
    }
    // Event handler for button
    handleSayHello(){
        if (this.greeting){
            this.message = 'Hello ${this.greeting}! Welcom to LWC development';
        }else{
            this.message = 'please enter your name first.';
        }
    }
    handleReset(){
        this.greeting ='World ';
        this.message = '';
        //Rest the input field 
        const inputField = this.template.querySelector('lightning-input');
        if (inputField){
            inputField = '';
        }
    }
}