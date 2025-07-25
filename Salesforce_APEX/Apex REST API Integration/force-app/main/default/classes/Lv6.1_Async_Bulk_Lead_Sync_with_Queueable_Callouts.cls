global with sharing class LeadBatchProcessor implements Database.Batchable<LeadIntegrationService.LeadRequest>, Database.AllowsCallouts, Database.Stateful {
    
    private List<LeadIntegrationService.LeadRequest> leadDataList;
    private Integer processedRecords = 0;
    private Integer failedRecords = 0;
    private List<CalloutRetry> calloutRetries = new List<CalloutRetry>();
    
    global LeadBatchProcessor(List<LeadIntegrationService.LeadRequest> leadDataList) {
        this.leadDataList = leadDataList;
    }
    
    global Iterable<LeadIntegrationService.LeadRequest> start(Database.BatchableContext bc) {
        return leadDataList;
    }
    
    global void execute(Database.BatchableContext bc, List<LeadIntegrationService.LeadRequest> scope) {
        List<Lead> leadsToInsert = new List<Lead>();
        List<LeadIntegrationService.LeadRequest> calloutQueue = new List<LeadIntegrationService.LeadRequest>();
        
        for (LeadIntegrationService.LeadRequest leadData : scope) {
            try {
                if (String.isBlank(leadData.email) || String.isBlank(leadData.lastName)) {
                    LeadIntegrationService.logError('Validation Error', 'Email and Last Name are required.', JSON.serialize(leadData));
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
                LeadIntegrationService.logError('Processing Error', e.getMessage(), JSON.serialize(leadData));
                failedRecords++;
            }
        }
        
        if (!leadsToInsert.isEmpty()) {
            Database.SaveResult[] results = Database.insert(leadsToInsert, false);
            for (Integer i = 0; i < results.size(); i++) {
                Database.SaveResult result = results[i];
                LeadIntegrationService.LeadRequest leadData = calloutQueue[i];
                
                if (result.isSuccess()) {
                    processedRecords++;
                    Boolean calloutSuccess = makeExternalCallout(result.getId(), leadData);
                    if (!calloutSuccess) {
                        calloutRetries.add(new CalloutRetry(result.getId(), leadData, 0));
                    }
                } else {
                    LeadIntegrationService.logError('DML Error', result.getErrors()[0].getMessage(), JSON.serialize(leadData));
                    failedRecords++;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Enqueue Queueable job for retries
        if (!calloutRetries.isEmpty()) {
            System.enqueueJob(new LeadCalloutRetryQueue(calloutRetries));
        }
        
        // Log batch completion
        LeadIntegrationService.logError('Batch Completion', 
            'Processed: ' + processedRecords + ', Failed: ' + failedRecords, 
            'Batch Job Completed'
        );
    }
    
    private Boolean makeExternalCallout(String leadId, LeadIntegrationService.LeadRequest leadData) {
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
            LeadIntegrationService.logError('Callout Exception', e.getMessage(), JSON.serialize(leadData));
            return false;
        }
    }
    
    // Helper class for retries
    global class CalloutRetry {
        public String leadId;
        public LeadIntegrationService.LeadRequest leadData;
        public Integer attempt;
        
        public CalloutRetry(String leadId, LeadIntegrationService.LeadRequest leadData, Integer attempt) {
            this.leadId = leadId;
            this.leadData = leadData;
            this.attempt = attempt;
        }
    }
}