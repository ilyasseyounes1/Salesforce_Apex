@RestResource(urlMapping='/SecureLeadService/*')
global with sharing class LeadIntegrationService {
    
    global class LeadRequest {
        public String firstName;
        public String lastName;
        public String email;
        public String company;
        public String phone;
    }
    
    global class LeadResponse {
        public String leadId;
        public String status;
        public String errorMessage;
        
        public LeadResponse(String leadId, String status, String errorMessage) {
            this.leadId = leadId;
            this.status = status;
            this.errorMessage = errorMessage;
        }
    }
    
    global class LeadIntegrationException extends Exception {}
    
    @HttpPost
    global static LeadResponse createLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Validate session
            String sessionId = req.headers.get('Authorization')?.substringAfter('Bearer ');
            if (String.isBlank(sessionId) || !UserInfo.getSessionId().equals(sessionId)) {
                logError('Security Error', 'Invalid or missing session ID.', req.requestBody?.toString());
                throw new LeadIntegrationException('Unauthorized: Invalid session.');
            }
            
            // Parse JSON
            String requestBody = req.requestBody.toString();
            LeadRequest leadData;
            try {
                leadData = (LeadRequest) JSON.deserialize(requestBody, LeadRequest.class);
            } catch (JSONException e) {
                logError('JSON Parsing Error', e.getMessage(), requestBody);
                throw new LeadIntegrationException('Invalid JSON: ' + e.getMessage());
            }
            
            // Validate input
            if (String.isBlank(leadData.email) || String.isBlank(leadData.lastName)) {
                logError('Validation Error', 'Email and Last Name are required.', requestBody);
                throw new LeadIntegrationException('Email and Last Name are required.');
            }
            
            // Create Lead
            Lead newLead = new Lead(
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
            
            // Secure callout with Named Credential
            Boolean calloutSuccess = makeExternalCallout(newLead.Id, leadData);
            if (!calloutSuccess) {
                logError('Callout Error', 'External API call failed.', requestBody);
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
    
    private static Boolean makeExternalCallout(String leadId, LeadRequest leadData) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:MockCRM_API/post'); // Named Credential
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(new Map<String, String>{'leadId' => leadId}));
            req.setTimeout(10000);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                return true;
            } else {
                logError('Callout Error', 'Status code: ' + res.getStatusCode(), JSON.serialize(leadData));
                return false;
            }
        } catch (CalloutException e) {
            logError('Callout Exception', 'OAuth or network error: ' + e.getMessage(), JSON.serialize(leadData));
            return false;
        }
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
}


/* 
Send a POST request to /services/apexrest/SecureLeadService/ with:
Header: Authorization: Bearer <session_id> (get from UserInfo.getSessionId()).
Body:
{
  "firstName": "Alex",
  "lastName": "Taylor",
  "email": "alex.taylor@example.com",
  "company": "Acme Corp",
  "phone": "555-6789"
}
*/