@RestResponse(UrlMapping='/ContactService/*')
global with sharing  class ContactIntegrationService{
    //Wrapper calss to match incoming JSON structure
    global class ContactRequest {
        public String first_name;
        public String last_name;
        public String email_address;
        public String phone_number;
    }
    //Response wrapper for standardized output
    global class ContactResponse {
        public String contactId;
        public String status;
        public String errorMassage;

        public ContactResponse (String conId, String status,String errorMassage){
            this.contactId = conId;
            this.status = status;
            this.errorMassage = errorMassage;
        }
    }
    @HttpPost
    global static ContactRespons createContact(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try { // Parse JSON input 
            String requestBody  = req.requestBody.toString();
            ContactResquest contactDate = (ContactRequest) JSON.deserialize(requestBody,ContactRquest.class);
            // validate input 
            if (String.isBlank (contactData.email_address)){
                return new ContactResponse (null, 'Error' , 'Email address is required.');
            }

            // Map JSON to Contact obj
            Contact newContact = new Contact(
                FirstName = contactDate.first_name,
                LastName = contactDate.last_name ,
                Email = contactDate.email_address,
                Phone = contactDate.phone_number
            );
            insert newContact;
            return new ContactResponse (newContact.Id,'Success',null);
        }catch (Exception e){
            //Handle errors
            res.statusCode = 500;
            return new ContactResponse (null , 'Error','Failed to create Contact '+ e.getMessage());

        }
    }
}
/*Sample JSON Input
{
  "first_name": "Jane",
  "last_name": "Doe",
  "email_address": "jane.doe@example.com",
  "phone_number": "555-0123"
}
*/