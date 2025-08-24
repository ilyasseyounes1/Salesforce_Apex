/*
Key Endpoints:
/services/data/v61.0/jobs/ingest: Create and manage jobs for creating, updating, or deleting records.
/services/data/v61.0/jobs/query: Create and manage query jobs.

Jobs have states: Open, UploadComplete, InProgress, JobComplete, etc.
Supported Operations:Create/Update/Delete: Upload CSV data for bulk operations.
Query: Retrieve large datasets using SOQL (returns results as CSV).

Authentication:
Uses OAuth 2.0 or Session ID (we’ll use Session ID for simplicity)
*/

//Create a CSV file named accounts.csv with the following content and upload it as a Static Resource (Setup > Static Resources > New):


public class Lv10_Bulk_API_20_to_Create_Account {
    private static final string BASE_URL = URL.getSalesforceBaseUrl().toExternalForm()+'/service/data/v61.0/jobs/ingest';
    // Method to create a Bulk API job
    public static string createBulkJob(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Beaere'+ UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');

        //JSON payload for job creation
        String payload = '{' +
            '"object": "Account",' +
            '"contentType": "CSV",' +
            '"operation": "insert",' +
            '"lineEnding": "LF"' +
            '}';
        req.setBody(payload);

        Http http = new Http();
        try {
            HttpResponse res = http(req);
            if (res.getStatusCode() == 200){
                Map<string,Object> responseMap = (Map<string,Object>) JSON.deserializeUntyped(res.getBody());
                system.debug('job Created :' + responseMap.get('id'));
                return (string ) responseMap.get('id');
            }else {
                system.debug('Error' +res.getStatusCode() +''+ res.getStatus());
                return null;
            }
        }catch(Exception e){
            system.debug('Exception : '+ e.getMessage());
            return null;
        }
    }

    // method to upload CSV data to the job 
    public static void uploadJobData(String jobId){
        //retrieve CSV from static resource 
        StaticResource csvResource = [SELECT body From StaticResource where
                                    Name = 'accouts' LIMIT 1];//StaticResource: A Salesforce object storing files (like our accounts.csv).
        Blob csvBlob = csvResource.Body; //Blob: A data type for binary data (like a file’s contents).
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/' + jobId + '/Batches');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearee' + UserInfo.getSessionId());
        req.setHeader('Content-type ', 'text/csv');
        req.setHeader('Accept', 'application/json');
        req.setBodyAsBlob(csvBlob); // req.setBodyAsBlob: Sets the request body to binary data (the CSV file).
        
        Http http = new Http();
        try {
            HttpResponse res = http(req);
            if (res.getStatusCode() == 201){
                system.debug ('CSV data Uploaded Successfuly ');
            }else {
                system.debug('Error ' + res.getStatusCode()+''+ res.getStatus());
            }
        }catch (Exception e){
            system.debug('Exception:' + e.getMessage());
        }
    }
    // Method to close the job and start processing
    public static void closeJob(string jobId){
        HttpRequest req = HttpRequest();
        req.setEndpoint(BASE_URL + '/' + jobId);
        req.setMethod('PATCH');
        req.setHeader('Authorization', 'Bearer' + UserInfo.getSessionId());
        req.setHeader('Content-Type ', 'application/json');
        req.setBody('{"state":"UploadComplete"}');

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                System.debug('Job Closed Successfully');
            } else {
                System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    // Method to check job status
    public static void checkJobStatus(String jobId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/' + jobId);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Accept', 'application/json');

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                System.debug('Job Status: ' + responseMap.get('state'));
                System.debug('Records Processed: ' + responseMap.get('numberRecordsProcessed'));
                System.debug('Records Failed: ' + responseMap.get('numberRecordsFailed'));
            } else {
                System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
}
