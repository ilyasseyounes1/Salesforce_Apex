public class Lv3_JsonHandling_DataMapping {
     public class ApiUser {
        public String id;
        public String name;
        public String email;
    }
    
    public static void createAccountFromAPI() {
        // Simulate API response
        String jsonResponse = '{"id":"123","name":"John Doe","email":"john@example.com"}';
        
        ApiUser user = (ApiUser) JSON.deserialize(jsonResponse, ApiUser.class);
        
        Account acc = new Account();
        acc.Name = user.name;
        acc.External_ID__c = user.id;
        // acc.Email__c = user.email; // If you have this field
        
        insert acc;
        System.debug('Created Account: ' + acc.Id);
    }
}
