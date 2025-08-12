@isTest
private class commonTestSetup {
    @TestSetup
    static void makeData(){
        List<Account> testAccts = new List<Account>();
        for (Integer i=0; i<2 ;i++){
            testAccts.add(new Account (Name ='TestAcct'+i));
        }
        insert testAccts;
        
    }
}
@isTest static void testMethod1(){
    Account acct = [SELECT Id From Account WHERE Name = 'TestAcc0' LIMIT 1];
    acct.Phone = '555-44432';
    update acct;
    // Delete second account : 
    Account acct2 = [SELECT Id FROM Account WHERE Name = 'TestAcc1' LIMIT 1];
    delete acct2;

}
@isTest 
static void testMethod2(){
    Account acct = [SELECT Phone FROM Account WHERE Name = 'TestAcct0' LIMIT 1];
    System.assertEquals(null,acct.Phone);

    Account acct2 = [SELECT Id From Account WHERE Name = 'TestAcc1' LIMIT 1];
    System.assertEquals(null ,acct2);
}

//----------------------------Final : -----------------------

@isTest
private class CommonTestSetup {

    // Shared setup: creates 2 test accounts before each test method
    @TestSetup
    static void makeData() {
        List<Account> testAccts = new List<Account>();
        for (Integer i = 0; i < 2; i++) {
            testAccts.add(new Account(Name = 'TestAcct' + i));
        }
        insert testAccts;
    }

    // Test 1: update phone and delete one account
    @isTest
    static void testMethod1() {
        // Update phone of first account
        Account acct = [SELECT Id, Phone FROM Account WHERE Name = 'TestAcct0' LIMIT 1];
        acct.Phone = '555-44432';
        update acct;

        // Delete second account
        Account acct2 = [SELECT Id FROM Account WHERE Name = 'TestAcct1' LIMIT 1];
        delete acct2;

        // Verify changes in this test only
        Account updatedAcct = [SELECT Phone FROM Account WHERE Id = :acct.Id];
        System.assertEquals('555-44432', updatedAcct.Phone);

        // Confirm deletion using try-catch
        try {
            Account deletedAcct = [SELECT Id FROM Account WHERE Id = :acct2.Id];
            System.assert(false, 'Account should have been deleted');
        } catch (QueryException e) {
            System.assert(e.getMessage().contains('List has no rows'), 'Expected exception for deleted account');
        }
    }

    // Test 2: verify fresh setup (phone is null, both accounts exist)
    @isTest
    static void testMethod2() {
        Account acct = [SELECT Phone FROM Account WHERE Name = 'TestAcct0' LIMIT 1];
        System.assertEquals(null, acct.Phone, 'Phone should be null because setup is reset');

        Account acct2 = [SELECT Id FROM Account WHERE Name = 'TestAcct1' LIMIT 1];
        System.assertNotEquals(null, acct2, 'Second account should exist again');
    }
}