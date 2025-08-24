@RestResource(urlMapping='/LeadService/*')
global with sharing class LeadIntegrationService {
    //Wrapper for incoming JSON
    global class LeaadRequest {
        public String firstName;
        public String lastName ;
        public  String email;
        public String company;
        public String phone;
    }
    //Response wrapper
    global class LeadResponse {
        public String LeadId;
        public String status;
        public String errorMassage;

        public LeadResponse(String Id,Sring status,String error){
            this.LeadId = Id;
            this.status = status;
            this.errorMassage = error;
        }
    }
    //Custom exception 
    global class LeadIntegrationException extends Exception {}

    //retry constants
    private static final Integer MAX_RETRIES = 3;
    private static final Integer RETRY_DELAY_MS = 2000;

    @HttpPost
    global static LeadResponse createLead(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            if (req.requestBody == null){
                throw new LeadIntegrationException('Request body is empty');
            }
            String requestBody = req.requestBody.toString();
            LeadRequest leadDate;
            
            //Parse JSON 
            try {
                leadDate = (LeadRequest) JSON.deserialize(requestBody ,LeadRequest.class);

            }catch (Exception e){
                logError ('JSON Parsing Error'+ e.getMessage() ,requestBody);
                throw new LeadIntegrationException('Invalid JSON :'+ e.getMessage());
            }
            //validate input 
            if (String.isBlank(leadDate.email) || String.isBlank(leadDate.lastName)){
                logError('Validation Error', 'Email and Last Name are required.', requestBody);
                throw new LeadIntegrationException('Email and Last Name are required.');
            }
            //create Lead
            Lead newLead = new Lead (
                FirstName = leadData.firstName,
                LastName = leadData.lastName,
                Email = leadData.email,
                Company = leadData.company,
                Phone = leadData.phone
            );
            try {
                insert newLead;
            } catch (DmlException e) {
                logError('DML Error', e.getMessage(), requestBody);
                throw new LeadIntegrationException('Failed to create Lead: ' + e.getMessage());
            }
            
            // External callout with retry
            Boolean calloutSuccess = makeExternalCallout(newLead.Id, leadData, 0);
            if (!calloutSuccess) {
                logError('Callout Error', 'External API call failed after retries.', requestBody);
                throw new LeadIntegrationException('External API call failed.');
            }
            
            return new LeadResponse(newLead.Id, 'Success', null);
        } catch (LeadIntegrationException e) {
            res.statusCode = 400;
            return new LeadResponse(null, 'Error', e.getMessage());
        } catch (Exception e) {
            logError('Unexpected Error', e.getMessage(), requestBody);
            res.statusCode = 500;
            return new LeadResponse(null, 'Error', 'Unexpected error: ' + e.getMessage());
        }
    }
    
    // Retry logic for callout
    private static Boolean makeExternalCallout(String leadId, LeadRequest leadData, Integer attempt) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://postman-echo.com/post'); // Replace with your mock API
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(new Map<String, String>{'leadId' => leadId}));
            req.setTimeout(8000);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                return true;
            } else {
                throw new CalloutException('Status code: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            if (attempt < MAX_RETRIES) {
                // Simulate delay (in production, use async or Queueable)
                for (Integer i = 0; i < RETRY_DELAY_MS * 1000; i++) {}
                return makeExternalCallout(leadId, leadData, attempt + 1);
            }
            logError('Callout Retry Exhausted', e.getMessage(), JSON.serialize(leadData));
            return false;
        }
    }
    
    // Log errors to Integration_Log__c
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
}

