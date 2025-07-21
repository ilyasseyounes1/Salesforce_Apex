@isTest
public class Lv8_EnterprisePatterns_Testing {
    // Production-Ready Testing
    @isTest
    static void testAPIIntegration() {
        // Create mock response
        String mockResponse = '{"status":"success","data":[{"id":"123","name":"Test"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockResponse));
        
        Test.startTest();
        String result = YourAPIService.getData();
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        
    }
}

public class MockHttpResponseGenerator implements HttpCalloutMock {
    private Integer statusCode;
    private String responseBody;
    
    public MockHttpResponseGenerator(Integer code, String body) {
        this.statusCode = code;
        this.responseBody = body;
    }
    
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setBody(responseBody);
        return res;
    }
}

