/**
 salesforce-streaming-dashboard/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   ├── com/example/
│   │   │   │   ├── SalesforceStreamingDashboardApplication.java
│   │   │   │   ├── config/
│   │   │   │   │   ├── WebSocketConfig.java
│   │   │   │   ├── controller/
│   │   │   │   │   ├── DashboardController.java
│   │   │   │   ├── service/
│   │   │   │   │   ├── StreamingService.java
│   │   ├── resources/
│   │   │   ├── application.properties
│   │   │   ├── templates/
│   │   │   │   ├── dashboard.html
 */
import java.sql.Time;
import java.util.HashMap;
import java.util.Map;

import org.cometd.client.BayeuxClient;
import org.cometd.client.transport.LongPollingTransport;
import org.eclipse.jetty.client.HttpClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.annotation.PostConstruct;
import okhttp3.FormBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

@SpringBootApplication
public class App {

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Controller
    public static class DashboardController {
        @GetMapping("/")
        public String dashboard() {
            return "dashboard";  // Thymeleaf template name
        }
    }

    @Service
    public static class StreamingService {
        @Value("${salesforce.client-id}")
        private String clientId;
        @Value("${salesforce.client-secret}")
        private String clientSecret;
        @Value("${salesforce.username}")
        private String username;
        @Value("${salesforce.password}")
        private String password;
        @Value("${salesforce.login-url}")
        private String loginUrl;
        @Value("${salesforce.api-version}")
        private String apiVersion;

        private final SimpMessagingTemplate messagingTemplate;
        private final ObjectMapper objectMapper = new ObjectMapper();

        public StreamingService(SimpMessagingTemplate messagingTemplate) {
            this.messagingTemplate = messagingTemplate;
        }

        @PostConstruct
        public void init() throws Exception {
            OkHttpClient httpClient = new OkHttpClient();
            RequestBody formBody = new FormBody.Builder()
                .add("grant_type", "password")
                .add("client_id", clientId)
                .add("client_secret", clientSecret)
                .add("username", username)
                .add("password", password)
                .build();

            Request request = new Request.Builder()
                .url(loginUrl + "/services/oauth2/token")
                .post(formBody)
                .build();

            Response response = httpClient.newCall(request).execute();
            Map<String, String> oauthResponse = objectMapper.readValue(response.body().string(), Map.class);
            String accessToken = oauthResponse.get("access_token");
            String instanceUrl = oauthResponse.get("instance_url");

            HttpClient jettyHttpClient = new HttpClient();
            jettyHttpClient.start();

            Map<String, Object> options = new HashMap<>();
            options.put("headers", Map.of("Authorization", "Bearer " + accessToken));

            BayeuxClient cometdClient = new BayeuxClient(instanceUrl + "/cometd/" + apiVersion,
                new LongPollingTransport(options, jettyHttpClient));
            cometdClient.addExtension(new org.cometd.client.ext.AckExtension());

            cometdClient.handshake(message -> {
                if (message.isSuccessful()) {
                    System.out.println("Connected to Salesforce Streaming API");
                    cometdClient.getChannel("/topic/AccountUpdates").subscribe((channel, msg) -> {
                        try {
                            Map<String, Object> sobject = (Map<String, Object>) msg.getDataAsMap().get("sobject");
                            messagingTemplate.convertAndSend("/topic/accounts", sobject);
                            System.out.println("Event sent to WebSocket: " + sobject);
                        } catch (Exception e) {
                            System.err.println("Error processing event: " + e.getMessage());
                        }
                    });
                } else {
                    System.err.println("Handshake failed: " + message);
                }
            });
        }
    }

    @Configuration
    @EnableWebSocketMessageBroker
    public static class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
        @Override
        public void configureMessageBroker(MessageBrokerRegistry config) {
            config.enableSimpleBroker("/topic");
            config.setApplicationDestinationPrefixes("/app");
        }

        @Override
        public void registerStompEndpoints(StompEndpointRegistry registry) {
            registry.addEndpoint("/ws").setAllowedOrigins("*");
        }
    }
}

//----------------------------------------------------------------------------------------------------------


<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Real-Time Account Dashboard</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.6.1/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
    <style>
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid black; padding: 8px; text-align: left; }
    </style>
</head>
<body>
    <h1>Real-Time Account Dashboard</h1>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
            </tr>
        </thead>
        <tbody id="accountTable"></tbody>
    </table>
    <script>
        // Connect to WebSocket
        const socket = new SockJS('/ws');
        const stompClient = Stomp.over(socket);
        stompClient.connect({}, function (frame) {
            console.log('Connected to WebSocket: ' + frame);
            stompClient.subscribe('/topic/accounts', function (message) {
                const account = JSON.parse(message.body);
                const row = `<tr><td>${account.Id}</td><td>${account.Name}</td></tr>`;
                document.getElementById('accountTable').innerHTML += row;
            });
        });
    </script>
</body>
</html>

/**application.properties file for Spring Boot configuration : 
        salesforce.client-id=${SALESFORCE_CLIENT_ID}
        salesforce.client-secret=${SALESFORCE_CLIENT_SECRET}
        salesforce.username=${SALESFORCE_USERNAME}
        salesforce.password=${SALESFORCE_PASSWORD}
        salesforce.login-url=${SALESFORCE_LOGIN_URL:https://login.salesforce.com}
        salesforce.api-version=${SALESFORCE_API_VERSION:59.0}
        logging.level.org.springframework.web=DEBUG
        logging.level.com.example=DEBUG
 */


 /**
  * PushTopic pushTopic = new PushTopic();
    pushTopic.Name = 'AccountUpdates';
    pushTopic.Query = 'SELECT Id, Name FROM Account WHERE Name LIKE \'Test%\'';
    pushTopic.ApiVersion = 59.0;
    pushTopic.NotifyForOperationCreate = true;
    pushTopic.NotifyForOperationUpdate = true;
    pushTopic.NotifyForFields = 'referenced';
    insert pushTopic;
  */


  /*
        Purpose: Streams Account create/update events (where Name LIKE 'Test%') to a Java-based Spring Boot dashboard.
        PushTopic: Salesforce metadata object (AccountUpdates) with query SELECT Id, Name FROM Account WHERE Name LIKE 'Test%', publishes to /topic/AccountUpdates.
        Authentication: OAuth Password Grant Flow via https://login.salesforce.com provides access_token and instance_url (https://.......salesforce.com).
        Streaming: StreamingService.java uses CometD to subscribe to /topic/AccountUpdates, extracts Id, Name.
        WebSocket: Spring Boot forwards events to /topic/accounts; dashboard.html displays them at http://localhost:8080.
   */