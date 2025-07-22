@RestResource(urlMapping='/ContactService/Bulk/*')
global with sharing class ContactIntegrationService {
    
    global class ContactRequest {
        public String first_name;
        public String last_name;
        public String email_address;
        public String phone_number;
    }
    
    global class ContactResponse {
        public String contactId;
        public String email;
        public String status;
        public String errorMessage;
        
        public ContactResponse(String contactId, String email, String status, String errorMessage) {
            this.contactId = contactId;
            this.email = email;
            this.status = status;
            this.errorMessage = errorMessage;
        }
    }
    
    global class IntegrationException extends Exception {}
    
    private static final Integer MAX_RETRIES = 3;
    private static final Integer RETRY_DELAY_MS = 1000;
    
    @HttpPost
    global static List<ContactResponse> createOrUpdateContacts() {
        RestRequest req = RestContext.request;
        List<ContactResponse> responses = new List<ContactResponse>();
        
        try {
            // Parse JSON
            List<ContactRequest> contactDataList;
            try {
                contactDataList = (List<ContactRequest>) JSON.deserialize(
                    req.requestBody.toString(),
                    List<ContactRequest>.class
                );
            } catch (JSONException e) {
                logError('JSON Parsing Error', e.getMessage(), req.requestBody?.toString());
                throw new IntegrationException('Invalid JSON format: ' + e.getMessage());
            }
            
            List<Contact> contactsToInsert = new List<Contact>();
            for (ContactRequest contactData : contactDataList) {
                try {
                    if (String.isBlank(contactData.email_address)) {
                        logError('Validation Error', 'Email address is required for ' + contactData.first_name, JSON.serialize(contactData));
                        responses.add(new ContactResponse(null, contactData.email_address, 'Error', 'Email address is required.'));
                        continue;
                    }
                    
                    Contact newContact = new Contact(
                        FirstName = contactData.first_name,
                        LastName = contactData.last_name,
                        Email = contactData.email_address,
                        Phone = contactData.phone_number
                    );
                    contactsToInsert.add(newContact);
                    responses.add(new ContactResponse(null, contactData.email_address, 'Pending', null));
                } catch (Exception e) {
                    logError('Processing Error', e.getMessage(), JSON.serialize(contactData));
                    responses.add(new ContactResponse(null, contactData.email_address, 'Error', e.getMessage()));
                }
            }
            
            // Bulk insert contacts
            if (!contactsToInsert.isEmpty()) {
                Database.SaveResult[] results = Database.insert(contactsToInsert, false);
                for (Integer i = 0; i < results.size(); i++) {
                    Database.SaveResult result = results[i];
                    ContactResponse response = responses[i];
                    Contact contact = contactsToInsert[i];
                    
                    if (result.isSuccess()) {
                        response.contactId = result.getId();
                        response.status = 'Success';
                        
                        // Make external callout
                        Boolean calloutSuccess = makeExternalCallout(result.getId(), contact, 0);
                        if (!calloutSuccess) {
                            response.status = 'Error';
                            response.errorMessage = 'External API call failed after retries.';
                        }
                    } else {
                        response.status = 'Error';
                        response.errorMessage = result.getErrors()[0].getMessage();
                        logError('DML Error', response.errorMessage, JSON.serialize(contact));
                    }
                }
            }
            
            return responses;
        } catch (IntegrationException e) {
            RestContext.response.statusCode = 400;
            responses.add(new ContactResponse(null, null, 'Error', e.getMessage()));
            return responses;
        } catch (Exception e) {
            logError('Unexpected Error', e.getMessage(), req.requestBody?.toString());
            RestContext.response.statusCode = 500;
            responses.add(new ContactResponse(null, null, 'Error', 'Unexpected error: ' + e.getMessage()));
            return responses;
        }
    }
    
    private static Boolean makeExternalCallout(String contactId, Contact contact, Integer attempt) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://postman-echo.com/post');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(new Map<String, String>{'contactId' => contactId}));
            req.setTimeout(10000);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                return true;
            } else {
                throw new CalloutException('Received status code: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            if (attempt < MAX_RETRIES) {
                for (Integer i = 0; i < RETRY_DELAY_MS * 1000; i++) {} // Simulate delay
                return makeExternalCallout(contactId, contact, attempt + 1);
            }
            logError('Callout Retry Exhausted', e.getMessage(), JSON.serialize(contact));
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