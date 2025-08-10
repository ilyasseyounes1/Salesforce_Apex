public class Lv14_1_Composite_API {
    public static void executeCompositeRequest(){
        String endpoint = URL.getOrgDomainUrl().toExternalForm() +
                            '/services/data/v58.0/composite';
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint);
    req.setMethod('POST');
    req.setHeader('Authorization', 'Bearer'+ UserInfo.getSessionId());
    req.setHeader('Content-type', 'application/json');
    //Comnposite Request
    Map<String,Object> compsiteRequest = new Map<String,Object>();
    compositeRequest.put('allOrNone',false);
    
    List<Map<String,Object>> compositeRequest = new List<Map<String,Object>>();
    //Request 1 : Create Account
    Map<String,Object> createAccountReq = new Map<String,Object>();
    createAccountReq.put('methhod','Post');
    createAccountReq.put('url','/services/data/v58.0/sobject/Account/');
    createAccountReq.put('referenceId','NewAccount');

    Map<String,Object> accountData = new Map<String,Object>();
    accountData.put('Name','Composite Api Test Account');
    accountData.put('Industry','Technology');
    createAccountReq.put('body',accountData);
    compositeRequest.add(createAccountReq);

    //Request 2: Create Contact (referencing the account)
    Map<String,Object> createContactReq = new Map<String,Object>();
    createContactReq.put('method', 'POST');
    createContactReq.put('url','/services/data/v58.0/sobject/Contact/');
    createContactReq.put('referencedId','NewContact');

    Map<String,Object> contactData = new Map<String,Object>();
    contactData.put('FirstName', 'Ilyasse');
    contactData.put('LastName','Younes');
    contactDataa.put('Email','ilyasseyounes1@gamil.com');
    contactData.put('AccountId','@{NewAccount.id}'); //reference to first request
    createContactReq.put('body',contactData);
    compositeRequest.add(createContactReq);

    // Request 3: Query the created records
    Map<String,Object> queryReq = new Map<String,Object>();
    queryReq.put('method','GET');
    queryReq.put('url','/services/data/v58.0/query/?q=SELECT Id,Name FROM Account Where Id = \'@{NewAccount.id}\'');
    queryReq.put('referenceId','AccountQuery');
    compositeRequest.add(queryReq);

    compositeRequest.put('compositeRequest',compositeRequest);
    req.setBody(JSON.serialize(compositeRequest));

    Http http = new Http();
    HttpResponse res = http.send(req);

    System.debug('Composite api response:' + res.getBody());

    if(res.getStatusCode() == 200){
        Map<String,Object> response = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        List<Object> results = (List<Object>) response.get('compositeResponse');

        for (Object result: results){
            Map<String,Object> resultMap = (Map<String,Object>) result;
            System.debug('Reference Id : '+ result.get('referenceId'));
            system.debug('HTTP status: ' + result.get('httpStatusCode'));
            system.debug('Body:' + result.get('body'));
        }
    }
    
    } 
}
/*
| Aspect             | Explanation                                                                                                                                                                                                        |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Purpose**        | Allows executing multiple REST API requests in a single call, reducing round trips between client and server.                                                                                                      |
| **Key Benefit**    | Improves performance by bundling requests, maintains execution order, and can reference results of earlier requests.                                                                                               |
| **Main Resources** | `/services/data/vXX.X/composite/` – includes `batch`, `composite`, and `tree` sub-resources.                                                                                                                       |
| **Types**          | **Composite**: Multiple requests in one payload, supports result references.<br>**Batch**: Up to 25 sub-requests in one request, executed independently.<br>**Tree**: Create multiple related records in one call. |
| **Max Limits**     | Composite: Up to 25 sub-requests.<br>Batch: Up to 25 requests.<br>Tree: 200 records per request.                                                                                                                   |
| **Reference IDs**  | In `composite` requests, later requests can use `@{refId.fieldName}` to reference earlier responses.                                                                                                               |
| **Error Handling** | You can choose `allOrNone` (rollback all on error) or allow partial success.                                                                                                                                       |
| **Authentication** | Requires OAuth 2.0 or Session ID; same as other Salesforce REST APIs.                                                                                                                                              |
| **Use Cases**      | Creating parent & child records in one go, chaining dependent operations, reducing API call count in integrations.                                                                                                 |
| **Example**        | Create an Account, then create Contacts linked to that Account in a single request.                                                                                                                                |
___________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
*/