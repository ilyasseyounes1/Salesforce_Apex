// Bulk Processing with Queueable
public class Lv6_BulkOperations_AsyncProccessing implements Queueable, Database.AllowsCallouts {
    
    private Integer currentPage;
    private List<Account> accountsToProcess;
    
    public Level6Exercise(Integer page) {
        this.currentPage = page;
        this.accountsToProcess = new List<Account>();
    }
    
    public void execute(QueueableContext context) {
        String endpoint = 'https://api.example.com/accounts?page=' + currentPage + '&limit=50';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> accounts = (List<Object>) responseData.get('accounts');
            
            // Process accounts...
            
            Boolean hasMore = (Boolean) responseData.get('hasMore');
            if (hasMore && currentPage < 10) { // Limit to prevent infinite loop
                System.enqueueJob(new Level6Exercise(currentPage + 1));
            }
        }
    }
}