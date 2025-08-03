// ilyasse younes 03/08/2025 11:14 PM


public class Lv13_Connect_API_for_Communities{
    //Replace with your community ID 
    private static final String COMMUNITY_ID = '**********';
    private static final String BASE_URL = 'https://*******';

    // Method to retrive the current user's chatter feed :
    public static String getChatterFeed(){
        Http http = new Htpp();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/chatter/feeds/news/me/feed-elements');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer' + UserInfo.getSessionId());
        req.setHeader('Content-type', 'application/json');
        
        try {
            HttpResponse response = http.send(req);
            if (response.getStatusCode() == 200){
                return response.getBody();
            }else{
                System.debug('Error:' + response.getStatusCode());
                return null;
            }
        }catch(Exception e){
            System.debug('Exception: ' e.getMessage());
            return null;
        }
    }
    // method to post a new Chatter Feed item
    public static void posttoChatter (String message){
        Http http = new Http ();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/chtter/feed-element');
        req.setMethod('POST');
        req.setHeader('Authrization','Bearer'+UserInfo.getSessionId() );
        req.setHeader('Content-type', 'application/json');
        
        // JSON body for the new feed item
        String jsonbody = JSON.serialize(new Map<string,Object> {
            'body' => new Map<string,Object>{
                'messageSegments' => new List<Object>{
                    new Map<string ,Object> {
                        'type'=>'Text' , 'Text' => message }

                    }
                },

                'feedElementType' => 'FeedItem',
                'subjectId' => 'me' // Post to the user's own feed
        });
        req.setBody(jsonbody);
        try{
            HttpResponse res = http.send(req);
            Systme.debug('Successfully posted to chatter:' + res.getBody());
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
        }catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
     }
    }
}

/*
| **Aspect**             | **Details**                                                                                                                                                                                                                                                                                                                   |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Purpose**            | Enables programmatic interaction with Salesforce Experience Cloud (Communities) for building custom interfaces, mobile apps, or integrations with community features like Chatter, user profiles, and content.                                                                                                                |
| **Key Features**       | - Chatter Integration: Manage posts, comments, likes, and messages.<br>- User/Group Management: Access user profiles and group data.<br>- Recommendations: Provide personalized content.<br>- Files/Content: Handle file uploads and sharing.<br>- Custom REST Endpoints: Extend with Apex REST for community-specific logic. |
| **Use Cases**          | - Custom community dashboards for Chatter feeds.<br>- Mobile apps for community interactions.<br>- Integrating external systems with community data (e.g., syncing user activity to a third-party app).                                                                                                                       |
| **Key Endpoints**      | - `GET /connect/communities/<communityId>/chatter/feeds/news/me/feed-elements`: Retrieve current user's news feed.<br>- `POST /connect/communities/<communityId>/chatter/feed-elements`: Post a new feed item.<br>- Other: `/connect/users` (profiles), `/connect/communities/<communityId>/groups`, `/connect/files`.        |
| **Authentication**     | - Requires OAuth 2.0 or session ID (e.g., `UserInfo.getSessionId()` in Apex).<br>- Use **Connected App** for external integrations.<br>- Community user must have permissions (e.g., “Chatter Contributor”).                                                                                                                  |
| **Data Format**        | Supports **JSON** and XML (JSON preferred).                                                                                                                                                                                                                                                                                   |
| **Prerequisites**      | - Experience Cloud site enabled in the org.<br>- Familiarity with REST API, JSON, and OAuth 2.0.<br>- Community ID (found in Setup > Experience Workspaces).                                                                                                                                                                  |
| **Error Handling**     | - `403 Forbidden`: Invalid permissions.<br>- `404 Not Found`: Wrong community ID or missing endpoint.<br>- `401 Unauthorized`: Invalid or expired token.<br>- Check debug logs for error messages.                                                                                                                            |
| **Best Practices**     | - Use `try-catch` in Apex for API calls.<br>- Validate community ID and permissions before making requests.<br>- Paginate feed results using `nextPageUrl` for performance.                                                                                                                                                   |
| **Practical Example**  | - Use `HttpRequest` in Apex to `GET /chatter/feeds/news/me/feed-elements`.<br>- `POST /chatter/feed-elements` with JSON body.<br>- Use Lightning Web Components (LWC) to display/post content.                                                                                                                                |
| **Tools for Testing**  | - Salesforce Developer Console (Execute Anonymous).<br>- Workbench / Postman for API testing.<br>- Experience Builder for deploying LWC.                                                                                                                                                                                      |
| **Limitations**        | - Requires Experience Cloud license.<br>- API call limits apply (standard quotas).<br>- Some features (e.g., recommendations) need specific editions.                                                                                                                                                                         |
| **Learning Resources** | - [Connect API Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.chatterapi.meta/chatterapi/connect_resources_intro.htm)<br>- Salesforce Trailhead: *Experience Cloud Basics*<br>- Postman for hands-on testing                                                                                              |
| **Next Steps**         | - Build an LWC to display/post to community feed.<br>- Explore additional endpoints (groups, files, users).<br>- Prepare for Level 14: GraphQL & Composite APIs.                                                                                                                                                              |


*/