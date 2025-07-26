global with sharing class LeadCalloutRetryQueue implements Queueable, Database.AllowsCallouts {
    
    private List<LeadBatchProcessor.CalloutRetry> retryJobs;
    private static final Integer MAX_RETRIES = 3;
    
    global LeadCalloutRetryQueue(List<LeadBatchProcessor.CalloutRetry> retryJobs) {
        this.retryJobs = retryJobs;
    }
    
    global void execute(QueueableContext context) {
        List<LeadBatchProcessor.CalloutRetry> jobsToRequeue = new List<LeadBatchProcessor.CalloutRetry>();
        
        for (LeadBatchProcessor.CalloutRetry job : retryJobs) {
            try {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:MockCRM_API/post');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(new Map<String, String>{'leadId' => job.leadId}));
                req.setTimeout(10000);
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                if (res.getStatusCode() != 200) {
                    throw new CalloutException('Status code: ' + res.getStatusCode());
                }
            } catch (Exception e) {
                LeadIntegrationService.logError('Retry Callout Error', e.getMessage(), JSON.serialize(job.leadData));
                if (job.attempt < MAX_RETRIES) {
                    jobsToRequeue.add(new LeadBatchProcessor.CalloutRetry(job.leadId, job.leadData, job.attempt + 1));
                }
            }
        }
        
        if (!jobsToRequeue.isEmpty()) {
            System.enqueueJob(new LeadCalloutRetryQueue(jobsToRequeue));
        }
    }
}