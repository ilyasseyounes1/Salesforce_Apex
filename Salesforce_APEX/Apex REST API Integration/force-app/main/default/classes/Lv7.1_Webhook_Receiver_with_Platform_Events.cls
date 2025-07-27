@RestResource(urlMapping = '/LeadWebhook/*')
global with sharing class LeadWebhookService {

    // --- DTO ---
    global class LeadWebhookRequest {
        public String leadId;
        public String status;
        public String eventTimestamp;
    }

    global class WebhookResponse {
        public String status;
        public String message;

        public WebhookResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }

    global class WebhookException extends Exception {}

    private static final String WEBHOOK_SECRET = label.WebhookSecret; // Ideally from Custom Metadata or Custom Label

    @HttpPost
    global static WebhookResponse processWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = req.requestBody?.toString();

        try {
            // Validate webhook signature
            String signature = req.headers.get('X-Webhook-Signature');
            if (!validateSignature(requestBody, signature)) {
                logError('Security Error', 'Invalid webhook signature.', requestBody);
                throw new WebhookException('Invalid webhook signature.');
            }

            // Parse JSON
            LeadWebhookRequest webhookData;
            try {
                webhookData = (LeadWebhookRequest) JSON.deserialize(requestBody, LeadWebhookRequest.class);
            } catch (Exception e) {
                logError('JSON Parsing Error', e.getMessage(), requestBody);
                throw new WebhookException('Invalid JSON: ' + e.getMessage());
            }

            // Validate input
            if (String.isBlank(webhookData.leadId) || String.isBlank(webhookData.status)) {
                logError('Validation Error', 'Lead ID and Status are required.', requestBody);
                throw new WebhookException('Lead ID and Status are required.');
            }

            // Enqueue async processing
            System.enqueueJob(new LeadWebhookProcessor(webhookData));

            return new WebhookResponse('Success', 'Webhook processing enqueued.');
        } catch (WebhookException e) {
            res.statusCode = 400;
            return new WebhookResponse('Error', e.getMessage());
        } catch (Exception e) {
            logError('Unexpected Error', e.getMessage(), requestBody);
            res.statusCode = 500;
            return new WebhookResponse('Error', 'Unexpected error: ' + e.getMessage());
        }
    }

    private static Boolean validateSignature(String requestBody, String providedSignature) {
        if (String.isBlank(requestBody) || String.isBlank(providedSignature)) {
            return false;
        }

        Blob mac = Crypto.generateMac('HmacSHA256', Blob.valueOf(requestBody), Blob.valueOf(WEBHOOK_SECRET));
        String computedSignature = EncodingUtil.base64Encode(mac);
        return computedSignature == providedSignature;
    }

    private static void logError(String errorType, String errorMessage, String requestBody) {
        try {
            Integration_Log__c log = new Integration_Log__c(
                Error_Type__c = errorType,
                Error_Message__c = errorMessage.abbreviate(255),
                Request_Body__c = requestBody?.abbreviate(32768),
                Timestamp__c = System.now()
            );
            insert log;
        } catch (Exception e) {
            System.debug('Failed to log error: ' + e.getMessage());
        }
    }

    // --- Queueable Inner Class ---
    global with sharing class LeadWebhookProcessor implements Queueable, Database.AllowsCallouts {
        private LeadWebhookRequest webhookData;

        global LeadWebhookProcessor(LeadWebhookRequest webhookData) {
            this.webhookData = webhookData;
        }

        global void execute(QueueableContext context) {
            try {
                List<Lead> leads = [SELECT Id, Status FROM Lead WHERE Id = :webhookData.leadId LIMIT 1];
                if (leads.isEmpty()) {
                    logError('Lead Not Found', 'Lead ID not found: ' + webhookData.leadId, JSON.serialize(webhookData));
                    return;
                }

                Lead lead = leads[0];
                lead.Status = webhookData.status;
                try {
                    update lead;
                } catch (DmlException e) {
                    logError('DML Error', e.getMessage(), JSON.serialize(webhookData));
                    return;
                }

                Boolean calloutSuccess = makeExternalCallout(webhookData);
                if (!calloutSuccess) {
                    logError('Callout Error', 'Failed to confirm sync for Lead: ' + webhookData.leadId, JSON.serialize(webhookData));
                }

                LeadUpdate__e event = new LeadUpdate__e(
                    Lead_Id__c = webhookData.leadId,
                    Status__c = webhookData.status,
                    Event_Timestamp__c = webhookData.eventTimestamp
                );
                Database.SaveResult result = EventBus.publish(event);
                if (!result.isSuccess()) {
                    logError('Event Publish Error', result.getErrors()[0].getMessage(), JSON.serialize(webhookData));
                }
            } catch (Exception e) {
                logError('Processing Error', e.getMessage(), JSON.serialize(webhookData));
            }
        }

        private Boolean makeExternalCallout(LeadWebhookRequest webhookData) {
            try {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:MockCRM_API/post');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(new Map<String, String>{
                    'leadId' => webhookData.leadId,
                    'status' => webhookData.status
                }));
                req.setTimeout(10000);

                Http http = new Http();
                HttpResponse res = http.send(req);

                return res.getStatusCode() == 200;
            } catch (Exception e) {
                logError('Callout Exception', e.getMessage(), JSON.serialize(webhookData));
                return false;
            }
        }
    }
}
