public class Lv1_HttpBasics_FirstApiCall {
    public static void callWeatherAPI(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        // Use Named Credential + Custom Label for API key
        String apiKey = Label.WeatherApiKey;
        req.setEndpoint('callout:WeatherAPI/v1/current.json?q=London&key=' + apiKey);
        req.setMethod('GET');

        HttpResponse res = http.send(req);
        System.debug('Status: ' + res.getStatusCode());
        System.debug('Body: ' + res.getBody());
    }
}

//---------------- Test Class : 
/*
   @isTest
public class Lv1_HttpBasics_FirstApiCall_Test {

    global class SimpleMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{}'); // empty JSON response
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void simpleTest() {
        Test.setMock(HttpCalloutMock.class, new SimpleMock());
        Lv1_HttpBasics_FirstApiCall.callWeatherAPI();
    }
}

*/