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

/*
| **Category**              | **PushTopic Events**                                                            | **Change Data Capture (CDC)**                                              | **Platform Events**                                                                  | **Generic Events**                                                       |
| ------------------------- | ------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| **Purpose**               | Push notifications for record changes based on a SOQL query.                    | Automatically capture record-level DML (create, update, delete, undelete). | Custom-defined event structure for app-to-app messaging.                             | Lightweight event messages without schema or object backing.             |
| **Use Case**              | UI updates, legacy dashboards, real-time monitoring of filtered record changes. | Synchronizing Salesforce data to external systems in near real-time.       | Publish/Subscribe between Salesforce apps and external systems with custom payloads. | Internal event bus or low-overhead app signaling, no persistence needed. |
| **Channel Format**        | `/topic/{PushTopicName}`                                                        | `/data/{ObjectName}ChangeEvent`                                            | `/event/{EventName}__e`                                                              | `/u/{CustomChannelName}`                                                 |
| **Schema Required**       | No, just SOQL query.                                                            | No, uses standard/custom object structure.                                 | Yes – must define fields in Setup.                                                   | No. Just send raw payloads.                                              |
| **How to Define**         | Create a `PushTopic` record with SOQL and flags.                                | Enabled via Setup → “Change Data Capture”.                                 | Create a Platform Event object with custom fields.                                   | Define channel and publish using REST API.                               |
| **Trigger Source**        | Changes to records matching the SOQL query.                                     | Any change to the selected object(s).                                      | Explicit publish action from Apex, Flow, API, or External App.                       | REST API or JavaScript API publish.                                      |
| **Supported Events**      | Create, Update (based on Notify flags).                                         | Create, Update, Delete, Undelete.                                          | Published events only.                                                               | Published messages only.                                                 |
| **Replay Support**        | ✅ Yes                                                                          | ✅ Yes                                                                    | ✅ Yes                                                                               | ❌ No                                                                   |
| **Order Guaranteed**      | No strict order guarantee.                                                      | Yes (within object type).                                                  | Yes (based on replayId).                                                             | No                                                                       |
| **Durability**            | Stored for 72 hours (replayable).                                               | Stored for 72 hours (replayable).                                          | Stored for 72 hours (replayable).                                                    | Not stored.                                                              |
| **Delivery Mechanism**    | CometD (long polling)                                                           | CometD                                                                     | CometD, also REST API to publish.                                                    | CometD                                                                   |
| **Field-Level Filtering** | Yes – via `NotifyForFields` in PushTopic.                                       | No filtering – all field changes are included.                             | Controlled by defined schema.                                                        | None – entire payload is passed.                                         |
| **Apex Triggers**         | ❌ Not supported.                                                               | ✅ Supported (on ChangeEvent objects).                                    | ✅ Supported (on Platform Event objects).                                            | ❌ Not supported.                                                       |
| **Flow Support**          | ❌ Not available.                                                               | ✅ Available via Flow Triggers.                                           | ✅ Available via Flow Triggers.                                                      | ❌ Not supported.                                                       |
| **Publish Method**        | Not applicable – passive listening.                                             | Not applicable – automatic.                                                | `EventBus.publish()` in Apex, Flow, or REST API.                                     | REST POST to `/u/GenericChannel`.                                        |
| **Subscribe With**        | Workbench, CometD, JS, Node, MuleSoft.                                          | Workbench, CometD, External Apps.                                          | Workbench, LWC, Apex, MuleSoft, External Clients.                                    | CometD or REST listeners.                                                |
| **Limits**                | Limited to 10 PushTopics/org (default).                                         | Up to 10,000 change events per object/hour (subject to org limits).        | Platform Event allocation based on license.                                          | Max 1,000 concurrent CometD clients/org.                                 |
| **Security & Auth**       | Follows field-level & object-level security.                                    | Same as the object’s CRUD & FLS.                                           | Event-level permissions.                                                             | Depends on channel & auth method.                                        |
| **Best For**              | Real-time UI components, filtered change monitoring.                            | Data replication, system sync, external data lakes.                        | Decoupled messaging, orchestrations, integrations.                                   | Internal low-latency event signals or chatty integrations.               |
| **Sample Channel**        | `/topic/OpportunityUpdates`                                                     | `/data/OpportunityChangeEvent`                                             | `/event/Order_Alert__e`                                                              | `/u/SystemEvents`                                                        |
| **Sample Apex**           | `PushTopic t = new PushTopic(); t.Name='Opp'; ... insert t;`                    | None – handled by platform                                                 | `MyEvent__e evt = new MyEvent__e(...); EventBus.publish(evt);`                       | Not applicable in Apex                                                   |
| **When to Use**           | Simple SOQL-based real-time monitoring.                                         | Data sync, analytics updates.                                              | Custom event-driven apps.                                                            | Fire-and-forget notifications.                                           |
| **When *Not* to Use**     | Complex multi-object events, Apex needed.                                       | If filtering or customization needed.                                      | If full schema not needed.                                                           | When reliability or replay is required.                                  |

*/