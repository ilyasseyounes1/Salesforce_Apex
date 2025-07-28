public class Lv9_REST_Api_CRUD_with_SOQL {
    // Base URL for REST API
    private static final string BASE_URL = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v61.0/';

    //method to query accounts
    public static void queryAccounts(){
        HttpRequest req = new HttpResponse();
        req.setEndpoint(BASE_URL + 'query?q=SELECT+Id,Name+FROM+Account+WHERE+Industry=\'Technology\'');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer'+UserInfo.getSessionId());
        req.setHeader('Content-type', 'application/json');

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode()==200){
                System.debug('Query Response :'+ res.getBody());
            }else {
                System.debug('Error: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception'+e.getMessage());
        }
    }

    //Method to create an Account 
    public static string createAccount(Strin createAccount){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + 'sobject/Account/');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer'+ UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        
        // JSON payload for account 
        String payload = '{"Name": "' + accountName + '", "Industry": "Technology"}' }  ;  
        req.setBody(payload);

        Http http = new Http();
        try{
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 201){
                Map<String,Object> responseMap = (Map<string,Object>) JSON.deserializeUntyped(res.getBody());
                Systme.debug('create Account Id:' + responseMap.get('id'));
                return (string ) responseMap.get('id');
            }else{
                System.debug('Error'+ res.getStatusCode() + '' + res.getStatus());
                return null;
            }
        }catch(Exception e){
            System.debug('Exception :' +e.getMessage());
            return null;
        }
    }
    

        // Method to update Account
        public static void updateAccount(String accountId, String newName) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + 'sobjects/Account/' + accountId);
        req.setMethod('PATCH');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');

        // JSON payload for update
        String payload = '{"Name": "' + newName + '"}';
        req.setBody(payload);

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 204) {
                System.debug('Account updated successfully');
            } else {
                System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
    
            