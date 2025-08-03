public class Lv12_Create_Custom_Object_Using_Metadata_API {
    public static void createInvoiceObject(){
        //Init Metadate service 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadateService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();

        //Create custom object 
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = 'Invoice__c';
        customObject.label = 'Invoice';
        customObject.pluralLabel = 'Invoices';
        customObject.nameField = new MetadateService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = 'Invoice Name';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        
        //Add a custom field (Amount__c)
        MetadataService.CustomField amountField = new MetadataService.CustomField();
        amountField.fullName = 'Invoice__c.Amount__c';
        amountField.label = 'Amount';
        amountField.type_x = 'Currency';
        amountField.Required = false;

        // Execute createMetadata call 
        try {
            MetadateService.Metadata[] metadate = new MetadataService.Metadata[]{customObject,amountField};
            MetadataService.AsyncResult[] result = service.createMetadata(metadate);
            for (MetadataService.AsyncResult result : results ){
                if (result.success ){
                    System.debug('Create:' + result.fullName);
                }else{
                    System.debug('Error : ' + result.error[0].message);
                }
            }
        }catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }
}



/**
| **Category**              | **Details**                                                                                                                                             |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **What is Metadata API?** | SOAP-based API to retrieve, deploy, create, update, delete metadata (not data) in Salesforce                                                            |
| **Purpose / Use Cases**   | - Move customizations between orgs  <br> - CI/CD automation  <br> - Backup & restore <br> - Version control integration                                 |
| **Retrieve vs Deploy**    | - **Retrieve**: Pull metadata *from* org <br> - **Deploy**: Push metadata *to* org                                                                      |
| **Metadata Format**       | Stored as XML files in a specific directory structure (e.g., `classes`, `objects`, `layouts`)                                                           |
| **Manifest File**         | `package.xml` defines what metadata types/components to retrieve or deploy                                                                              |
| **Destructive Changes**   | `destructiveChanges.xml` used to delete metadata components from target org                                                                             |
| **Common Metadata Types** | ApexClass, ApexTrigger, CustomObject, CustomField, Layout, RecordType, Flow, ValidationRule, PermissionSet, Profile                                     |
| **Main Tools**            | - Salesforce CLI (sfdx)  <br> - VS Code + Salesforce Extensions  <br> - Workbench  <br> - Change Sets (UI)  <br> - ANT Migration Tool (legacy)          |
| **Deployment Lifecycle**  | 1. Retrieve from source org <br> 2. Commit to Git repo <br> 3. Test in scratch/UAT org <br> 4. Deploy to production <br> 5. Monitor with logs & tests   |
| **CI/CD Concepts**        | - Delta deployments <br> - Test level control (`RunLocalTests`, etc.) <br> - Rollback & dry-run (`checkOnly`) <br> - Single/multi-package deployments   |
| **Best Practices**        | - Use `package.xml` for precise control <br> - Track changes in Git <br> - Test in scratch orgs <br> - Run Apex tests during deploy <br> - Backup often |
| **Common Challenges**     | - Missing dependencies <br> - Profile/Permission conflicts <br> - API version mismatches <br> - Naming conflicts                                        |
| **When NOT to Use**       | - For record data → use **REST API** <br> - For small updates → use **Tooling API** <br> - For manual work → use **Change Sets**                        |
| **Related APIs**          | - REST API (data) <br> - Tooling API (metadata via REST) <br> - Apex Metadata API (dynamic updates from Apex)                                           |
| **Security & Access**     | Requires API access and permissions like "Modify Metadata Through Metadata API Functions"                                                               |
| **Real-World Usage**      | Essential for team-based DevOps, continuous deployment, rollback planning, sandbox refresh processes                                                    |
_______________________________________________________________________________________________________________________________________________________________________________________
 */

