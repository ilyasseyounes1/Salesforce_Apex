public class Lv1_HttpBasics_FirstApiCall {
    public static void callWeatherAPI(){
        Http http = new Http();
        HttpRequest rep = new HttpRequest();
        rep.setEndpoint(' http://api.weatherapi.com/v1');
        rep.setMethod('GET');

        HttpResponse res = http.send(req);
        System.debug('Status:' + res.getStatusCode());
        System.debug('Body: ' +res.getBody());
        
    }
}
