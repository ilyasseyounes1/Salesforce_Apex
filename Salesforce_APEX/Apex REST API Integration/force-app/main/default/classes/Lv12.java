/*
~/SalesforcePartnerWSDL/
├── partner.wsdl.xml ------> partner.wsdl.xml is the WSDL file that you generated from Salesforce Partner SOAP API. It describes the API methods, objects, and data types.
├── force-wsc-60.0.0-uber.jar   ------> WSC (Web Service Connector) is Salesforce's Java library to call SOAP APIs (like Partner or Metadata WSDL).
└── partner.jar   ------>partner.jar is the Java library that you generated from your partner.wsdl.xml. It contains all the Java classes that represent:
                        Salesforce Partner SOAP API methods (like login, query, create, etc.)
                        Salesforce objects (like SObject)
                        Salesforce error types, connection logic, and data types
 */



import com.sforce.soap.partner.*;
import com.sforce.soap.partner.sobject.SObject;
import com.sforce.ws.ConnectorConfig;

public class Lv12.1_Connect_To_Salesforce_using_Partner_WSDL_and_JAVA {
   
    public static void main(String[] args) throws Exception {
        // Replace with your Salesforce username and password+token
        final String USERNAME = "Username@gmail.com";
        final String PASSWORD = "Password+Token"; // Replace with your actual password and security tokenf

        ConnectorConfig config = new ConnectorConfig();
        config.setUsername(USERNAME);
        config.setPassword(PASSWORD);

        PartnerConnection connection = Connector.newConnection(config);
        System.out.println("Connected to Salesforce!");

        String soql = "SELECT Id, Name FROM Account LIMIT 5";
        QueryResult result = connection.query(soql);

        for (SObject record : result.getRecords()) {
            System.out.println("Account ID: " + record.getField("Id"));
            System.out.println("Account Name: " + record.getField("Name"));
            System.out.println("-----");
        }
    }
}


/*
| WSDL Type                                  | Use Case                                                                  | Strongly Typed?     | Multi-Org Support | Typical Use From                |
| ------------------------------------------ | ------------------------------------------------------------------------- | ------------------- | ----------------- | ------------------------------- |
| **Enterprise WSDL**                        | For one **specific org**. Best when the org’s schema doesn’t change often | ✅ Yes               | ❌ No              | External SOAP clients           |
| **Partner WSDL**                           | For **any org**, dynamic schema via `sObject`                             | ❌ No                | ✅ Yes             | External SOAP clients           |
| **Apex WSDL**                              | Exposes your **custom Apex Web Services** to outside systems              | ✅ Yes               | ✅ Yes             | External apps calling your Apex |
| **Metadata WSDL**                          | Used to create, update, or delete metadata (objects, fields, layouts)     | ✅ Yes               | ✅ Yes             | Apex (via WSDL2Apex)            |
| **Tooling WSDL**                           | For **development tools** (e.g. retrieving Apex classes, SOQL queries)    | ✅ Yes               | ✅ Yes             | IDEs, Dev Tools                 |
| **Tooling WSDL with Strongly Typed Enums** | Same as Tooling WSDL but enums have strict values                         | ✅ Yes (more strict) | ✅ Yes             | Dev Tools (typed)               |



 What "Strongly Typed" Means
    Strongly Typed WSDL: Defines exact object types and fields, like Account.Name as string.
    Loosely Typed WSDL: Uses a generic sObject type — you must specify fields at runtime (like dynamic Apex).
*/


