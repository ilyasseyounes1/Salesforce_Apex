// Exercise 4: Robust Error Handling
public class Lv4_ErrorHandling_Resilience {
    
    public static String makeRobustAPICall(String endpoint) {
        Integer maxRetries = 3;
        
        for (Integer i = 0; i < maxRetries; i++) {
            try {
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                req.setTimeout(60000);
                
                HttpResponse res = http.send(req);
                
                if (res.getStatusCode() == 200) {
                    return res.getBody();
                } else if (res.getStatusCode() == 429) {
                    // Rate limited - wait and retry
                    System.debug('Rate limited, retrying...');
                    continue;
                } else {
                    throw new CalloutException('API Error: ' + res.getStatusCode());
                }
            } catch (Exception e) {
                System.debug('Attempt ' + (i+1) + ' failed: ' + e.getMessage());
                if (i == maxRetries - 1) {
                    throw e;
                }
            }
        }
        return null;
    }
}