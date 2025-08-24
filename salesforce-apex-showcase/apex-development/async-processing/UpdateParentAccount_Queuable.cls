
public class UpdateParentAccount implements System.Queueable {
    private List<Account> accList;
    private Id parentAccId;

    // Constructor
    public UpdateParentAccount(List<Account> accRecords, Id accId) {
        this.accList = accRecords;
        this.parentAccId = accId;
    }
    
    public void execute(System.QueueableContext context) {
       
        if (accList != null && !accList.isEmpty() && parentAccId != null) {
            for (Account acc : accList) {
                acc.ParentId = parentAccId;
            }
            update accList;
        }
    }
}

// Usage Example:
// List<Account> accounts = [SELECT Id FROM Account WHERE Type = 'Customer'];
// Id parentId = 'PARENT_ACCOUNT_ID_HERE';
// UpdateParentAccount job = new UpdateParentAccount(accounts, parentId);
// Syst

//----------------------------------
@isTest
public class UpdateParentAccountTest {
    @TestSetup
    static void setupTestDate(){
        //Create parent account
        Account parentAccount = new Account(
            Name = 'Parent Account';
            Type = 'Customer';
        );
        insert parentAccount;

       List<Account> childAccounts = new List<Account>() ;
       for (Intger i=1; i<=5 ;i++){
        Account childAcc = new Account(
            Name = 'Child Account'+i;
            Type = 'Prospect';
        );
        insert childAccounts;
       }
    }
    /*Main positive test case
        -Tests the core functionality
        -Verifies all child accounts get the parent assigned correctly
    */
    @isTest
    static void testUpdateParentAccountSuccess(){
        //get test date
        Account parentAccount = [SELECT Id from Account WHERE Name = 'Parent Account ' LIMIT 1];
        List<Account> childAccount = [SELECT Id,ParentId from Account WHERE Name LIKE 'Child Account%'];
        // verify initial state - no parent assiged 
        for (Account acc : childAccount){
            System.assertEquals(null,acc.ParentId,'Initially child accounts should not have a parent ');
        }
        Test.startTest();
        //Execute queuble job 
        UpdateParentAccount job = UpdateParentAccount(childAccount ,parentAccount.Id);
        System.enqueueJob(job);
        Test.stopTest();

    // verify resulst 
    List<Account> updatedAccount = [SELECT Id,ParentId From Account WHERE Name LIKE 'Child Account%'];
    System.assertEquals(5,updatedAccount.size(), 'Should have 5 child accounts');
    for (Account acc : updatedAccount){
        System.assertEquals(parentAccount.Id, acc.ParentId, 'All child accounts should have the parent account assigned');

    }
    }

        /*  Negative test case
            - Tests handling of null account list
            - Ensures no exceptions are thrown  
        */

       @isTest
    static void testUpdateParentAccountWithNullList() {
        // Get parent account
        Account parentAccount = [SELECT Id FROM Account WHERE Name = 'Parent Account' LIMIT 1];
        
        Test.startTest();
        // Execute queueable job with null list
        UpdateParentAccount job = new UpdateParentAccount(null, parentAccount.Id);
        System.enqueueJob(job);
        Test.stopTest();
        
        // No exception should be thrown - test passes if no error occurs
        System.assert(true, 'Job should handle null list gracefully');
    }
    
    @isTest
    static void testUpdateParentAccountWithEmptyList() {
        // Get parent account
        Account parentAccount = [SELECT Id FROM Account WHERE Name = 'Parent Account' LIMIT 1];
        
        Test.startTest();
        // Execute queueable job with empty list
        UpdateParentAccount job = new UpdateParentAccount(new List<Account>(), parentAccount.Id);
        System.enqueueJob(job);
        Test.stopTest();
        
        // No exception should be thrown - test passes if no error occurs
        System.assert(true, 'Job should handle empty list gracefully');
    }
    
    @isTest
    static void testUpdateParentAccountWithNullParentId() {
        // Get child accounts
        List<Account> childAccounts = [SELECT Id, ParentId FROM Account WHERE Name LIKE 'Child Account%'];
        
        Test.startTest();
        // Execute queueable job with null parent ID
        UpdateParentAccount job = new UpdateParentAccount(childAccounts, null);
        System.enqueueJob(job);
        Test.stopTest();
        
        // Verify no updates occurred
        List<Account> updatedAccounts = [SELECT Id, ParentId FROM Account WHERE Name LIKE 'Child Account%'];
        
        for (Account acc : updatedAccounts) {
            System.assertEquals(null, acc.ParentId, 'Parent ID should remain null when null parent ID is passed');
        }
    }


}