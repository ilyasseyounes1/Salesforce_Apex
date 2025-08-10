public class lv14_GraphQL_API {
    // method execute GraphQL query 
    public static String executeGraphQLQuery(String query){
        String endpoint = URL.getOrgDomainUrl().toExternalForm()+
                                                '/service/data/v58.0/graphql';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer'+UserInfo.getSessionId());
        req.setHeader('Content-type', 'application/json');

        //GraphQL request body 
        Map<Stirng,Object> requestBody = new Map<String,Object>();
        requestBody.put('query',query);
        req.setBody(JSON.serialize(requestBody));
        
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (req.getStatusCode()){
            return res.getBody();
        }else{
            throw new CalloutException('GraphQL Error:' + res.getBody());
        }
    }
    //Example; Query Account with realted Contact
     public static void queryAccountsWithContacts() {
        String graphqlQuery = '''
            query {
                uiapi {
                    query {
                        Account(first: 5) {
                            edges {
                                node {
                                    Id
                                    Name {
                                        value
                                    }
                                    Industry {
                                        value
                                    }
                                    Contacts(first: 3) {
                                        edges {
                                            node {
                                                Id
                                                Name {
                                                    value
                                                }
                                                Email {
                                                    value
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        ''';
      try {
            String response = executeGraphQLQuery(graphqlQuery);
            System.debug('GraphQL Response: ' + response);
            
            // Parse and process the response
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
            System.debug('Parsed Result: ' + result);
            
        } catch (Exception e) {
            System.debug('GraphQL Error: ' + e.getMessage());
        }
}