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

/*
| Aspect                  | Details                                                                                                                                      |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **Purpose**             | Enables clients to query Salesforce data flexibly by specifying exactly what data they need in a single request.                             |
| **Key Feature**         | Single endpoint (`/services/data/vXX.X/graphql`) for all queries, unlike REST’s multiple endpoints.                                          |
| **Data Fetching**       | Client defines the shape of the response (fields, nested objects) → reduces overfetching/underfetching.                                      |
| **Query Language**      | Declarative syntax for describing required data and relationships between objects.                                                           |
| **Operations**          | - **Query**: Read data.<br> - **Mutation**: Modify data.<br> - **Subscription** (not yet in Salesforce native GraphQL) for real-time events. |
| **Benefits**            | - Fewer round trips to the server.<br>- Smaller payloads.<br>- Easier to aggregate related data in one call.                                 |
| **Schema**              | Exposes types, fields, and relationships in a structured way. Salesforce generates schema from your org's metadata.                          |
| **Usage**               | Send POST request with a GraphQL query in the body to the GraphQL endpoint.                                                                  |
| **Integration Example** | Useful in Lightning Web Components, mobile apps, or external systems that need optimized data retrieval.                                     |
| **Limitations**         | - Still in **Pilot/Beta** stages for some features.<br>- Governor limits apply.<br>- Not all Salesforce objects/fields may be exposed.       |

*/