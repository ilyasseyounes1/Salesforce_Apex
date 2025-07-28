// File: LeadWebhookServiceWithTests.apex

@RestResource(urlMapping='/LeadWebhook/*')
global with sharing class LeadWebhookService {
    
    global class LeadWebhookRequest {
        public String leadId;
        public String status;
        public String eventTimestamp;
        public String webhookType;
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
    private static final String WEBHOOK_SECRET = '************ :)';

    @HttpPost
    global static WebhookResponse processWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = req.requestBody?.toString();
        
        try {
            String signature = req.headers.get('X-Webhook-Signature');
            if (!validateSignature(requestBody, signature)) {
                logError('Security Error', 'Invalid webhook signature.', requestBody);
                throw new WebhookException('Invalid webhook signature.');
            }

            LeadWebhookRequest webhookData;
            try {
                webhookData = (LeadWebhookRequest) JSON.deserialize(requestBody, LeadWebhookRequest.class);
            } catch (JSONException e) {
                logError('JSON Parsing Error', e.getMessage(), requestBody);
                throw new WebhookException('Invalid JSON: ' + e.getMessage());
            }

            if (String.isBlank(webhookData.leadId) || String.isBlank(webhookData.status) || String.isBlank(webhookData.webhookType)) {
                logError('Validation Error', 'Lead ID, Status, and Webhook Type are required.', requestBody);
                throw new WebhookException('Lead ID, Status, and Webhook Type are required.');
            }

            WebhookProcessor processor = WebhookProcessorFactory.getProcessor(webhookData.webhookType);
            if (processor == null) {
                logError('Processor Error', 'Unsupported webhook type: ' + webhookData.webhookType, requestBody);
                throw new WebhookException('Unsupported webhook type.');
            }

            System.enqueueJob(new LeadWebhookProcessor(processor, webhookData));
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

    global static Boolean validateSignature(String requestBody, String providedSignature) {
        if (String.isBlank(requestBody) || String.isBlank(providedSignature)) return false;
        Blob hmac = Crypto.generateMac('HmacSHA256', Blob.valueOf(requestBody), Blob.valueOf(WEBHOOK_SECRET));
        String computedSignature = EncodingUtil.base64Encode(hmac);
        return computedSignature == providedSignature;
    }

    global static void logError(String errorType, String errorMessage, String requestBody) {
        try {
            Integration_Log__c log = new Integration_Log__c(
                Error_Type__c = errorType,
                Error_Message__c = errorMessage.abbreviate(255),
                Request_Body__c = requestBody?.abbreviate(32768),
                Timestamp__c = System.now()
            );
            insert log;
        } catch (Exception e) {
            System.debug('Log insert failed: ' + e.getMessage());
        }
    }
}
//This is an interface that allows you to:
//Add custom behavior by implementing process()
//Inject different logic for different environments or use cases


public interface WebhookProcessor {
    void process(LeadWebhookService.LeadWebhookRequest webhookData);
}

global with sharing class LeadUpdateProcessor implements WebhookProcessor {
    global void process(LeadWebhookService.LeadWebhookRequest webhookData) {
        try {
            List<Lead> leads = [SELECT Id, Status FROM Lead WHERE Id = :webhookData.leadId LIMIT 1];
            if (leads.isEmpty()) {
                LeadWebhookService.logError('Lead Not Found', 'Lead ID not found: ' + webhookData.leadId, JSON.serialize(webhookData));
                return;
            }

            Lead lead = leads[0];
            lead.Status = webhookData.status;

            try {
                update lead;
            } catch (DmlException e) {
                LeadWebhookService.logError('DML Error', e.getMessage(), JSON.serialize(webhookData));
                return;
            }

            Boolean calloutSuccess = makeExternalCallout(webhookData);
            if (!calloutSuccess) {
                LeadWebhookService.logError('Callout Error', 'Failed to confirm sync for Lead: ' + webhookData.leadId, JSON.serialize(webhookData));
            }
            /* This event can be subscribed to by other Salesforce automations:
            Flow , Apex Triggers , External systems via CometD
            It decouples logic even further, making it easier to scale.
            */
            
            LeadUpdate__e event = new LeadUpdate__e(
                Lead_Id__c = webhookData.leadId,
                Status__c = webhookData.status,
                Event_Timestamp__c = webhookData.eventTimestamp
            );
            Database.SaveResult result = EventBus.publish(event);
            if (!result.isSuccess()) {
                LeadWebhookService.logError('Event Publish Error', result.getErrors()[0].getMessage(), JSON.serialize(webhookData));
            }

        } catch (Exception e) {
            LeadWebhookService.logError('Processing Error', e.getMessage(), JSON.serialize(webhookData));
        }
    }

    private Boolean makeExternalCallout(LeadWebhookService.LeadWebhookRequest webhookData) {
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
            LeadWebhookService.logError('Callout Exception', e.getMessage(), JSON.serialize(webhookData));
            return false;
        }
    }
}

global with sharing class LeadWebhookProcessor implements Queueable, Database.AllowsCallouts {
    private WebhookProcessor processor;
    private LeadWebhookService.LeadWebhookRequest webhookData;

    global LeadWebhookProcessor(WebhookProcessor processor, LeadWebhookService.LeadWebhookRequest webhookData) {
        this.processor = processor;
        this.webhookData = webhookData;
    }

    global void execute(QueueableContext context) {
        processor.process(webhookData);
    }
}

global class WebhookProcessorFactory {
    global static WebhookProcessor getProcessor(String type) {
        if (type == 'update') {
            return new LeadUpdateProcessor();
        }
        return null;
    }
}

// =====================
// Test Class
// =====================
@isTest
private class LeadWebhookServiceTest {

    @TestSetup
    static void setup() {
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', Email = 'test@example.com', Company = 'TestCorp', Status = 'Open');
        insert lead;

        Integration_Log__c log = new Integration_Log__c(
            Error_Type__c = 'Test',
            Error_Message__c = 'Setup',
            Request_Body__c = '{}',
            Timestamp__c = System.now()
        );
        insert log;
    }

    @isTest
    static void testValidWebhook() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        LeadWebhookService.LeadWebhookRequest webhookData = new LeadWebhookService.LeadWebhookRequest();
        webhookData.leadId = lead.Id;
        webhookData.status = 'Qualified';
        webhookData.eventTimestamp = '2025-07-27T20:53:00Z';
        webhookData.webhookType = 'update';

        String requestBody = JSON.serialize(webhookData);
        String signature = EncodingUtil.base64Encode(Crypto.generateMac('HmacSHA256', Blob.valueOf(requestBody), Blob.valueOf('myWebhookSecret')));
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/LeadWebhook/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.addHeader('X-Webhook-Signature', signature);
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        RestContext.response = new RestResponse();

        Test.startTest();
        LeadWebhookService.WebhookResponse response = LeadWebhookService.processWebhook();
        Test.stopTest();

        System.assertEquals('Success', response.status);
        Lead updatedLead = [SELECT Status FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('Qualified', updatedLead.Status);
        List<LeadUpdate__e> events = (List<LeadUpdate__e>) Test.getEventBus().getPublishedEvents();
        System.assertEquals(1, events.size());
    }

    @isTest
    static void testInvalidSignature() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        LeadWebhookService.LeadWebhookRequest webhookData = new LeadWebhookService.LeadWebhookRequest();
        webhookData.leadId = lead.Id;
        webhookData.status = 'Qualified';
        webhookData.eventTimestamp = '2025-07-27T20:53:00Z';
        webhookData.webhookType = 'update';

        String requestBody = JSON.serialize(webhookData);

        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/LeadWebhook/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.addHeader('X-Webhook-Signature', 'bad_signature');
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        RestContext.response = new RestResponse();

        Test.startTest();
        LeadWebhookService.WebhookResponse response = LeadWebhookService.processWebhook();
        Test.stopTest();

        System.assertEquals('Error', response.status);
        System.assertEquals('Invalid webhook signature.', response.message);
    }

    @isTest
    static void testInvalidWebhookType() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        LeadWebhookService.LeadWebhookRequest webhookData = new LeadWebhookService.LeadWebhookRequest();
        webhookData.leadId = lead.Id;
        webhookData.status = 'Qualified';
        webhookData.eventTimestamp = '2025-07-27T20:53:00Z';
        webhookData.webhookType = 'invalid';

        String requestBody = JSON.serialize(webhookData);
        String signature = EncodingUtil.base64Encode(Crypto.generateMac('HmacSHA256', Blob.valueOf(requestBody), Blob.valueOf('myWebhookSecret')));

        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/LeadWebhook/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.addHeader('X-Webhook-Signature', signature);
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        RestContext.response = new RestResponse();

        Test.startTest();
        LeadWebhookService.WebhookResponse response = LeadWebhookService.processWebhook();
        Test.stopTest();

        System.assertEquals('Error', response.status);
        System.assertEquals('Unsupported webhook type.', response.message);
    }

    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status": "success"}');
            return res;
        }
    }
}
