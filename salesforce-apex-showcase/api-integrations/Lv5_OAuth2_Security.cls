public with sharing class Lv5_OAuth2_Security {
    @AuraEnabled(cacheable=true)
    public static String getOAuthToken() {
        // Retrieve Spotify config from Custom Metadata record named 'Main'
        SpotifyConfig__mdt config = SpotifyConfig__mdt.getInstance('Main');
        
        if (config == null || String.isBlank(config.ClientId__c) || String.isBlank(config.ClientSecret__c)) {
            System.debug('Spotify OAuth Failed: Missing clientId or clientSecret in Custom Metadata');
            return null;
        }
        
        String clientId = config.ClientId__c;
        String clientSecret = config.ClientSecret__c;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint('https://accounts.spotify.com/api/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String auth = clientId + ':' + clientSecret;
        String encodedAuth = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(auth));
        req.setHeader('Authorization', encodedAuth);

        req.setBody('grant_type=client_credentials');

        HttpResponse res;
        try {
            res = http.send(req);
        } catch (Exception e) {
            System.debug('Spotify OAuth Failed: Exception - ' + e.getMessage());
            return null;
        }

        if (res.getStatusCode() == 200) {
            Map<String, Object> tokenData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) tokenData.get('access_token');
        } else {
            System.debug('Spotify OAuth Failed: ' + res.getStatusCode() + ' - ' + res.getBody());
            return null;
        }
    }
}
