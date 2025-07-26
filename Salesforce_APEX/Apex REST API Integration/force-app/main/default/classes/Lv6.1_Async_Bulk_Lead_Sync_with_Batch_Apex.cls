@RestResource(urlMapping='/BulkLeadService/*')
global with sharing class LeadIntegrationService {

    // Data structure for incoming lead request
    global class LeadRequest {
        public String firstName;
        public String lastName;
        public String email;
        public String company;
        public String phone;
    }

    // Data structure for outgoing response
    global class LeadResponse {
        public String leadId;
        public String email;
        public String status;
        public String errorMessage;

        public LeadResponse(String leadId, String email, String status, String errorMessage) {
            this.leadId = leadId;
            this.email = email;
            this.status = status;
            this.errorMessage = errorMessage;
        }
    }

    // Custom exception
    global class LeadIntegrationException extends Exception {}

    // POST endpoint handler
    @HttpPost
    global static LeadResponse enqueueBulkLeads() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            // Security check
            String sessionId = req.headers.get('Authorization')?.substringAfter('Bearer ');
            if (String.isBlank(sessionId) || !UserInfo.getSessionId().equals(sessionId)) {
                logError('Security Error', 'Invalid or missing session ID.', req.requestBody?.toString());
                throw new LeadIntegrationException('Unauthorized: Invalid session.');
            }

            // Deserialize input
            List<LeadRequest> leadDataList;
            try {
                leadDataList = (List<LeadRequest>) JSON.deserialize(req.requestBody.toString(), List<LeadRequest>.class);
            } catch (JSONException e) {
                logError('JSON Parsing Error', e.getMessage(), req.requestBody?.toString());
                throw new LeadIntegrationException('Invalid JSON: ' + e.getMessage());
            }

            // Validate content
            if (leadDataList.isEmpty()) {
                throw new LeadIntegrationException('No leads provided.');
            }

            // Launch batch process
            LeadBatchProcessor batchJob = new LeadBatchProcessor(leadDataList);
            Id batchId = Database.executeBatch(batchJob, 200);

            return new LeadResponse(batchId, null, 'Success', 'Batch job enqueued with ID: ' + batchId);

        } catch (LeadIntegrationException e) {
            res.statusCode = 400;
            return new LeadResponse(null, null, 'Error', e.getMessage());
        } catch (Exception e) {
            logError('Unexpected Error', e.getMessage(), req.requestBody?.toString());
            res.statusCode = 500;
            return new LeadResponse(null, null, 'Error', 'Unexpected error: ' + e.getMessage());
        }
    }

    // Error logging utility
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

    // Internal Batch Apex class
    global with sharing class LeadBatchProcessor implements Database.Batchable<LeadRequest>, Database.AllowsCallouts, Database.Stateful {

        private List<LeadRequest> leadDataList;
        private Integer processedRecords = 0;
        private Integer failedRecords = 0;

        global LeadBatchProcessor(List<LeadRequest> leadDataList) {
            this.leadDataList = leadDataList;
        }

        global Iterable<LeadRequest> start(Database.BatchableContext bc) {
            return leadDataList;
        }

        global void execute(Database.BatchableContext bc, List<LeadRequest> scope) {
            List<Lead> leadsToInsert = new List<Lead>();
            List<LeadRequest> calloutQueue = new List<LeadRequest>();

            for (LeadRequest leadData : scope) {
                try {
                    if (String.isBlank(leadData.email) || String.isBlank(leadData.lastName)) {
                        logError('Validation Error', 'Email and Last Name are required.', JSON.serialize(leadData));
                        failedRecords++;
                        continue;
                    }

                    Lead newLead = new Lead(
                        FirstName = leadData.firstName,
                        LastName = leadData.lastName,
                        Email = leadData.email,
                        Company = leadData.company,
                        Phone = leadData.phone
                    );
                    leadsToInsert.add(newLead);
                    calloutQueue.add(leadData);
                } catch (Exception e) {
                    logError('Processing Error', e.getMessage(), JSON.serialize(leadData));
                    failedRecords++;
                }
            }

            // Insert Leads
            if (!leadsToInsert.isEmpty()) {
                Database.SaveResult[] results = Database.insert(leadsToInsert, false);
                for (Integer i = 0; i < results.size(); i++) {
                    SaveResult result = results[i];
                    LeadRequest leadData = calloutQueue[i];

                    if (result.isSuccess()) {
                        processedRecords++;
                        Boolean calloutSuccess = makeExternalCallout(result.getId(), leadData);
                        if (!calloutSuccess) {
                            logError('Callout Error', 'External API call failed for Lead: ' + result.getId(), JSON.serialize(leadData));
                            failedRecords++;
                        }
                    } else {
                        logError('DML Error', result.getErrors()[0].getMessage(), JSON.serialize(leadData));
                        failedRecords++;
                    }
                }
            }
        }

        global void finish(Database.BatchableContext bc) {
            logError('Batch Completion', 
                'Processed: ' + processedRecords + ', Failed: ' + failedRecords, 
                'Batch Job Completed'
            );
            System.debug('Batch job completed. Processed: ' + processedRecords + ', Failed: ' + failedRecords);
        }

        private Boolean makeExternalCallout(String leadId, LeadRequest leadData) {
            try {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:MockCRM_API/post');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(new Map<String, String>{'leadId' => leadId}));
                req.setTimeout(10000);

                Http http = new Http();
                HttpResponse res = http.send(req);

                return res.getStatusCode() == 200;
            } catch (Exception e) {
                logError('Callout Exception', e.getMessage(), JSON.serialize(leadData));
                return false;
            }
        }
    }
}
