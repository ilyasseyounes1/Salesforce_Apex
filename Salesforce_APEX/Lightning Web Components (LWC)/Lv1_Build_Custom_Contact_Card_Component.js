// File: lv1BuildCustomContactCardComponent.js

import { LightningElement } from 'lwc';

export default class Lv1_Build_Custom_Contact_Card_Component extends LightningElement {
    contactName = 'Ilyasse younes';
    contactTitle = 'Sales manager';
}

/* 
Template (HTML):
<template>
    <lightning-card title="Contact card " icon-name="standard:contact">
        <div class="slds-p-around_medium">
            <p class="slds-text-heading_small">Name:{contactName}</p>
            <p>Title: {contactTitle}</p>
        </div>
    </lightning-card>
</template>

CSS (styles.css):
.slds-text-heading_small {
    color: #006dcc;
    font-weight: bold;
}
p {
    color: #333;
}

XML Configuration (lv1BuildCustomContactCardComponent.js-meta.xml):
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>64.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__RecordPage</target>
    </targets>
</LightningComponentBundle>
*/
