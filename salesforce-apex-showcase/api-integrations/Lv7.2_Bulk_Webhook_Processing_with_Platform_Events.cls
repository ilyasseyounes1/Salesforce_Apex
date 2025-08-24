@RestResource(urlMapping='/LeadWebhook/Bulk/*')
global with sharing class LeadWebhookServiceBulk {
    
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
    
    private static final String WEBHOOK_SECRET = lable.WebhookSecret; // Org Custom label
    
    @HttpPost
    global static WebhookResponse processBulkWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Validate signature
            String signature = req.headers.get('X-Webhook-Signature');
            String requestBody = req.requestBody?.toString();
            if (!validateSignature(requestBody, signature)) {
                logError('Security Error', 'Invalid webhook signature.', requestBody);
                throw new WebhookException('Invalid webhook signature.');
            }
            
            // Parse JSON
            List<LeadWebhookRequest> webhookDataList;
            try {
                webhookDataList = (List<LeadWebhookRequest>) JSON.deserialize(requestBody, List<LeadWebhookRequest>.class);
            } catch (JSONException e) {
                logError('JSON Parsing Error', e.getMessage(), requestBody);
                throw new WebhookException('Invalid JSON: ' + e.getMessage());
            }
            
            // Validate input
            if (webhookDataList.isEmpty()) {
                throw new WebhookException('No webhook data provided.');
            }
            
            // Enqueue async processing
            System.enqueueJob(new LeadWebhookBulkProcessor(webhookDataList));
            
            return new WebhookResponse('Success', 'Bulk webhook processing enqueued.');
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
        Blob hmac = Crypto.generateMac('HmacSHA256', Blob.valueOf(requestBody), Blob.valueOf(WEBHOOK_SECRET));
        String computedSignature = EncodingUtil.base64Encode(hmac);
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



    global with sharing class LeadWebhookBulkProcessor implements Queueable, Database.AllowsCallouts {
    
    private List<LeadWebhookServiceBulk.LeadWebhookRequest> webhookDataList;
    
    global LeadWebhookBulkProcessor(List<LeadWebhookServiceBulk.LeadWebhookRequest> webhookDataList) {
        this.webhookDataList = webhookDataList;
    }
    
    global void execute(QueueableContext context) {
        List<Lead> leadsToUpdate = new List<Lead>();
        List<LeadWebhookServiceBulk.LeadWebhookRequest> eventQueue = new List<LeadWebhookServiceBulk.LeadWebhookRequest>();
        
        // Validate and prepare updates
        for (LeadWebhookServiceBulk.LeadWebhookRequest webhookData : webhookDataList) {
            try {
                if (String.isBlank(webhookData.leadId) || String.isBlank(webhookData.status)) {
                    LeadWebhookServiceBulk.logError('Validation Error', 'Lead ID and Status are required.', JSON.serialize(webhookData));
                    continue;
                }
                
                List<Lead> leads = [SELECT Id, Status FROM Lead WHERE Id = :webhookData.leadId LIMIT 1];
                if (leads.isEmpty()) {
                    LeadWebhookServiceBulk.logError('Lead Not Found', 'Lead ID not found: ' + webhookData.leadId, JSON.serialize(webhookData));
                    continue;
                }
                
                Lead lead = leads[0];
                lead.Status = webhookData.status;
                leadsToUpdate.add(lead);
                eventQueue.add(webhookData);
            } catch (Exception e) {
                LeadWebhookServiceBulk.logError('Processing Error', e.getMessage(), JSON.serialize(webhookData));
            }
        }
        
        // Bulk update Leads
        if (!leadsToUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(leadsToUpdate, false);
            for (Integer i = 0; i < results.size(); i++) {
                Database.SaveResult result = results[i];
                LeadWebhookServiceBulk.LeadWebhookRequest webhookData = eventQueue[i];
                
                if (result.isSuccess()) {
                    // Make callout
                    Boolean calloutSuccess = makeExternalCallout(webhookData);
                    if (!calloutSuccess) {
                        LeadWebhookServiceBulk.logError('Callout Error', 'Failed to confirm sync for Lead: ' + webhookData.leadId, JSON.serialize(webhookData));
                    }
                    
                    // Publish Platform Event
                    LeadUpdate__e event = new LeadUpdate__e(
                        Lead_Id__c = webhookData.leadId,
                        Status__c = webhookData.status,
                        Event_Timestamp__c = webhookData.eventTimestamp
                    );
                    Database.SaveResult eventResult = EventBus.publish(event);
                    if (!eventResult.isSuccess()) {
                        LeadWebhookServiceBulk.logError('Event Publish Error', eventResult.getErrors()[0].getMessage(), JSON.serialize(webhookData));
                    }
                } else {
                    LeadWebhookServiceBulk.logError('DML Error', result.getErrors()[0].getMessage(), JSON.serialize(webhookData));
                }
            }
        }
    }
    
    private Boolean makeExternalCallout(LeadWebhookServiceBulk.LeadWebhookRequest webhookData) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:MockCRM_API/post');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(new Map<String, String>{'leadId' => webhookData.leadId, 'status' => webhookData.status}));
            req.setTimeout(10000);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            return res.getStatusCode() == 200;
        } catch (Exception e) {
            LeadWebhookServiceBulk.logError('Callout Exception', e.getMessage(), JSON.serialize(webhookData));
            return false;
        }
    }
}
}