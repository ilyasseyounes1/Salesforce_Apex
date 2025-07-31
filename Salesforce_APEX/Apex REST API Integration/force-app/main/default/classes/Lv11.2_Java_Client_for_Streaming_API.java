/*
PushTopic pushtopic = new PushTopic();
pushtopic.Name = 'AccountUpdate';
pushtopic.Query = 'SELECT Id,Name FORM Account WHERE  Name LIKE \'Test%\;
pushtopic.NotifyForOperationCreate = true ;
pushtopic.NotifyForOperationUpdate = true ;
pushtopic.NotifyForOperationDelete = true ;
pushtopic.NotifyForFields = 'referenced';
pushtopic.ApiVersion = 59.0;
    insert pushtopic;
    Systme.debug('PushTopic created: ' + pushtopic.Id);
 */
//----------------------------------------------------------------------------------------------
//  Update pom.xml with dependencies:
/*
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>salesforce-streaming</artifactId>
    <version>1.0-SNAPSHOT</version>
    <dependencies>
        <!-- CometD Java Client -->
        <dependency>
            <groupId>org.cometd.java</groupId>
            <artifactId>cometd-java-client</artifactId>
            <version>4.0.2</version>
        </dependency>
        <!-- OkHttp for OAuth -->
        <dependency>
            <groupId>com.squareup.okhttp3</groupId>
            <artifactId>okhttp</artifactId>
            <version>4.10.0</version>
        </dependency>
        <!-- JSON Processing -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.14.0</version>
        </dependency>
    </dependencies>
</project>
 */
//---------------------------------------------------------------------------------------------------------------
package com.example;

import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.*;
import org.cometd.bayeux.client.ClientSessionChannel;
import org.cometd.client.BayeuxClient;
import org.cometd.client.transport.ClientTransport;
import org.cometd.client.transport.LongPollingTransport;
import org.eclipse.jetty.client.HttpClient;
import org.eclipse.jetty.util.ssl.SslContextFactory;

import java.util.HashMap;
import java.util.Map;
/**
Library used: CometD Java Client
HTTP client: OkHttp for OAuth login, and Jetty HTTP client for CometD transport
Data mapping: Jackson ObjectMapper to parse JSON
Streaming target: PushTopic → /topic/AccountUpdates (can be OpportunityUpdates, etc.)

 */
public class StreamingClient {
    private static final String LOGIN_URL = "https://login.salesforce.com/services/oauth2/token";
    private static final String CLIENT_ID = "YOUR_CONNECTED_APP_CLIENT_ID"; //From your Connected App.
    private static final String CLIENT_SECRET = "YOUR_CONNECTED_APP_CLIENT_SECRET"; //From your Connected App.
    private static final String USERNAME = "YOUR_SALESFORCE_USERNAME";
    private static final String PASSWORD = "YOUR_SALESFORCE_PASSWORD_PLUS_SECURITY_TOKEN";//Password + security token (reset via Setup > My Personal Information > Reset My Security Token).
    private static final String API_VERSION = "59.0";

    public static void main(String[] args) throws Exception {
        // Step 1: Authenticate with Salesforce
        OkHttpClient httpClient = new OkHttpClient();
        RequestBody formBody = new FormBody.Builder()
                .add("grant_type", "password")
                .add("client_id", CLIENT_ID)
                .add("client_secret", CLIENT_SECRET)
                .add("username", USERNAME)
                .add("password", PASSWORD)
                .build();

        Request request = new Request.Builder()
                .url(LOGIN_URL)
                .post(formBody)
                .build();
        Response response = httpClient.newCall(request).execute();
        ObjectMapper mapper = new ObjectMapper();
        Map < String, String> oauthResponse = mapper.readValue(response.body().string(), Map.class);
        String accessToken = oauthResponse.get("access_token");
        String instanceUrl = oauthResponse.get("instance_url");

        // Step 2: Set up CometD client
        HttpClient jettyHttpClient = new HttpClient(new SslContextFactory.Client()); //Sets up an SSL-enabled Jetty HTTP client, required for secure CometD communication.
        jettyHttpClient.start();
        Map<String, Object> options = new HashMap<>();
        ClientTransport transport =  new LongPollingTransport(options, jettyHttpClient); //Uses long-polling to receive real-time events from Salesforce.
        BayeuxClient cometdClient = new BayeuxClient(instanceUrl + "/cometd/" + API_VERSION, transport); //Initializes the CometD BayeuxClient
         //Adds the OAuth token to authenticate with Salesforce
        cometdClient.addExtension(new org.cometd.client.ext.AckExtension());
        cometdClient.putHeader( "Authorization", "Bearer " + accessToken);


        // Step 3: Handshake and subscribe
        cometdClient.handshake(30000, new ClientSessionChannel.MessageListener() {
            @Override
            public void onMessage(ClientSessionChannel channel, org.cometd.bayeux.Message message) {
                if (message.isSuccessful()) {
                    System.out.println("Connected to Salesforce Streaming API");
                    cometdClient.getChannel("/topic/AccountUpdates").subscribe((ch, msg) -> {
                        System.out.println("Received event: " + msg.getData());
                    });
                } else {
                    System.err.println("Handshake failed: " + message);
                }
            }
        });
    }
}

/*
If you want to build Java consumer clients for streaming APIs, this is what you need:
| Learn                                   | Why                                |
| --------------------------------------- | ---------------------------------- |
| Java Networking (OkHttp, Jetty)         | For making HTTP/API calls          |
| OAuth 2.0                               | To authenticate with secured APIs  |
| JSON parsing                            | To read incoming messages          |
| Event-driven listeners                  | To handle real-time data           |
| CometD or WebSockets                    | For actual streaming communication |
| Optional: Salesforce Streaming Concepts | For understanding topics/events    |
|-------------------------------------------------------------------------------

🔹 Java Networking and API Integration
        HTTP communication via OkHttp
        OAuth 2.0 Authentication
        JSON parsing using Jackson
        Asynchronous event subscription (CometD protocol)
Also touches:
🔹 Java Concurrency & Event Listeners
        Callback-based (onMessage()) subscription system
        Asynchronous long-polling using CometD (real-time messaging)
 */