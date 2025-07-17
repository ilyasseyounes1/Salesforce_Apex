public class DML_UseCasesDemo {

    // 1. INSERT: Add new records
    public static void insertExample() {
        Account acc = new Account(Name = 'Insert Example', Active__c = 'Yes');
        insert acc;
    }

    // 2. BULK INSERT: Add multiple records efficiently
    public static void bulkInsertExample() {
        List<Account> accList = new List<Account>();
        for (Integer i = 1; i <= 10; i++) {
            accList.add(new Account(Name = 'Bulk Account ' + i, Active__c = 'Yes'));
        }
        insert accList;
    }

    // 3. UPDATE: Modify existing records
    public static void updateExample() {
        Account acc = [SELECT Id, Name  FROM Account LIMIT 1];
        acc.Name =  'Updated Name';
        update acc;
    }

    // 4. BULK UPDATE
    public static void bulkUpdateExample() {
        List<Account>  accList = [SELECT Id, Name FROM Account LIMIT 5];
        for (Account  acc : accList) {
            acc.Name += ' [Updated]';
        }
        update accList;
    }

    // 5. UPSERT: Insert if new,  update if exists (based on Id or External ID)
    public static void upsertExample() {
        Account acc = new Account (Name = 'Upsert Account', External_Id__c = 'EXT001');
        upsert acc External_Id__c ;
    }

    // 6. DELETE: Remove records
     public static void deleteExample () {
        Account acc = new Account(Name = 'To Delete');
        insert acc;
        delete acc;
    }

    // 7. BULK DELETE 
    public static void  bulkDeleteExample () {
        List<Account> accList = new List<Account>();
        for (Integer i = 1; i <= 5; i++) {
            accList.add(new Account(Name = 'To Bulk Delete ' + i));
        }
        insert accList;
        delete accList;
    }

    // 8. UNDELETE: Restore soft-deleted records
    public static void undeleteExample() {
        Account acc = new Account (Name = 'To Undelete');
        insert acc;
        delete acc;
        undelete acc;

        // Ex:2 
        List<Account> accList = new List<Account>();
        accList = [SELECT Id, Name , Rating FROM Account 
                    WHERE Name Like 'Test Deleted %' ];
                    if (!accList.isEmpty()){
                        delete accList;
                    }
    }

    // 9. MERGE: Merge duplicate records (Account, Contact, Lead only)
    public static void mergeExample() {
        Account acc1 = new Account(Name = 'Merge A');
        Account acc2 = new Account(Name = 'Merge B');
        insert new List<Account>{acc1, acc2};
        merge acc1 acc2;
    }

    // 10. Database.insert(): Handle partial success/failure
    public static void databaseInsertExample() {
        List<Account> accList = new List<Account>{
            new Account(Name = 'Valid Account'),
            new Account() // Missing required Name field
        };

        Database.SaveResult[] results = Database.insert(accList, false);
        for (Database.SaveResult res : results) {
            if (res.isSuccess()) {
                System.debug('Success: ' + res.getId());
            } else {
                for (Database.Error err : res.getErrors()) {
                    System.debug('Error: ' + err.getMessage());
                }
            }
        }

        //Another Ex : 
        List<Contact> conList = new List<Contact > {
            new Contact(FistName = 'ilyasse',LastName = 'younes',Department='Finance'),
            new Contact(FistName = 'ilyasse',LastName = 'younes',Department='Finance'),
            new Contact() // Erorr
            };
            Database.SaveResult[] srList = Database.insert (conList ,false);
            // Iterate through erach returned result :
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()){
                    // Operation was successful , so get the ID of the record that was processed
                    System.debug('Successfully inserted contact. Contact ID : ' +Sr.getId());
                }else{
                    // Operation failed , so get all erors :
                    for (Database.Erorr err : sr.getErrors()){
                        System.debug('the following error has occurred .');
                        System.debug(err.getStatusCode() + ':'+ err.getMessage());
                        System.debug('Contact fields that affected thid erorr :' + err.getFields());
                    }
                }
            }
        }



    }
    public static void main () {
        DML_UseCasesDemo.insertExample();
        DML_UseCasesDemo.bulkInsertExample();
        DML_UseCasesDemo.updateExample();
        DML_UseCasesDemo.databaseInsertExample(); // For partial success handling

        return 0;
    }
}

 