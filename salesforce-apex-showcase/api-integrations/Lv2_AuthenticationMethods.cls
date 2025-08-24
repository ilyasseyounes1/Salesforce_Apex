public class Lv2_AuthenticationMethods {
    public static void callWithAPIKey(){
        Http http = new Http();
        HttpRequest req = HttpRequest();
        req.setEndpoint('');
        req.setMethod('GET');
        req.setHeader('', '');

        HttpResponse = res = http.send(req);
        System.debug('Authenticated response: '+ res.getBody());
    }
}
