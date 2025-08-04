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

    // ⬇️ Move mock class inside and mark it private
    private class MockHttpResponseGenerator implements HttpCalloutMock {
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
}
/*
Aspect
Explanation
Why test Apex APIs?
Ensure your integration works correctly and safely without real callouts.
Real callouts allowed in test?
❌ No – Salesforce blocks real HTTP callouts during test execution.
Solution
Use Mock HTTP classes that simulate responses from external services.
Mock interface
Implement HttpCalloutMock interface in your mock class.
Setup mock in test
Use Test.setMock(HttpCalloutMock.class, new YourMockClass()) in your test.
What to mock?
Status code, headers, and body of the external HTTP response.
Where to test?
In a separate @isTest class/method.
Assert what?
Check if the API response was handled properly (record updates, logic, etc).
Tools used
- Test.startTest() / Test.stopTest()  - System.assertEquals()
Test class requirement
At least 75% code coverage to deploy to production.


*/
