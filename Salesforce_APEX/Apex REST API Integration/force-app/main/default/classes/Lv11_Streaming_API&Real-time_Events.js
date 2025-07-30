/*
PushTopic pushtopic = new PushTopic();
pushtopic.Name = 'AccountUpdates';
PushTopic.Query = 'SELECT Id,Name FROM Account ';
pushTopic.ApiVersion = 59.0;
pushTopic.NotifyFroOperationCreate = true ;
pushTopic.NotifyFroOperationUpdate = true ;
pushTopic.NotifyFroOperationDelete = true ;
pushTopic.NotifyForFields = 'referenced ';
insert pushTopic;
system.debug('PushTopic created :' + pushTopic.Id);  */
const cometd = require('cometd');
const NodeCometD = require('cometd-nodejs-client').adapt();
const request = require('request');

// Salesforce OAuth 2.0 credentials
const clientId = 'YOUR_CONNECTED_APP_CLIENT_ID';
const clientSecret = 'YOUR_CONNECTED_APP_CLIENT_SECRET';
const username = 'YOUR_SALESFORCE_USERNAME';
const password = 'YOUR_SALESFORCE_PASSWORD_PLUS_SECURITY_TOKEN';
const loginUrl = 'https://login.salesforce.com';

// Step 1: Authenticate with Salesforce
const oauth2 = require('salesforce-oauth2');
oauth2.clientCredentialsFlow({
    clientId: clientId,
    clientSecret: clientSecret,
    username: username,
    password: password,
    loginUrl: loginUrl
}, (err, token) => {
    if (err) {
        console.error('Authentication failed:', err);
        return;
    }

    // Step 2: Initialize CometD
    const cometdClient = new cometd.CometD();
    cometdClient.configure({
        url: `${token.instance_url}/cometd/59.0`,
        requestHeaders: { Authorization: `Bearer ${token.access_token}` },
        appendMessageTypeToURL: false
    });

    // Step 3: Handshake with Salesforce
    cometdClient.handshake((handshake) => {
        if (handshake.successful) {
            console.log('Connected to Salesforce Streaming API');

            // Step 4: Subscribe to the PushTopic
            cometdClient.subscribe('/topic/AccountUpdates', (message) => {
                console.log('Received event:', JSON.stringify(message, null, 2));
            });
        } else {
            console.error('Handshake failed:', handshake);
        }
    });
});