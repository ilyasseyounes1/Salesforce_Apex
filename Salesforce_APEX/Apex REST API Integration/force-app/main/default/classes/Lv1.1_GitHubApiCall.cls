public class GitHubApiCall {
    public static void getGitHubUser() {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // Use Named Credential to handle authentication
        request.setEndpoint('callout:GitHubAPI/users/octocat');
        request.setMethod('GET');
        // Optional: Set headers (GitHub requires User-Agent for public API calls)
        request.setHeader('Accept', 'application/vnd.github.v3+json');
        
        try {
            HttpResponse response = http.send(request);
            
            // Check if the request was successful
            if (response.getStatusCode() == 200) {
                // Parse JSON response
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                System.debug('Username: ' + result.get('login'));
                System.debug('Name: ' + result.get('name'));
                System.debug('Public Repos: ' + result.get('public_repos'));
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
}