@isTest
public class DataFactory {
    public static List<Account> createAccountRecorcd (String name ,Integer Count,Boolean isInsert){
        List<Account> accList = new List<Account>();
        for (Integer i=1; i<Count; i++ ){
            Account acc = new Account();
            acc.Name = name+i;
            acc.Active__c = 'Yes';
            accList.add(acc);
        }
        if (isInsert){
            insert accList;
        }
        return accList;
    }
}
//--------------------------------------------------------------

@isTest
public class TestDataFactory {

    public static Account createAccount(String name) {
        Account acc = new Account(Name = name != null ? name : 'Test Account');
        insert acc;
        return acc;
    }

    public static Contact createContact(Id accountId) {
        Contact c = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john@example.com',
            AccountId = accountId
        );
        insert c;
        return c;
    }
    
    public static List<Account> createMultipleAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'Account_' + i));
        }
        insert accounts;
        return accounts;
    }
}

@isTest
private class MyTestClass {

    static testMethod void testSomething() {
        // Get test data from factory
        Account acc = TestDataFactory.createAccount('Acme Inc.');
        Contact con = TestDataFactory.createContact(acc.Id);

        // Run your logic here
        acc.Phone = '123456';
        update acc;

        // Verify
        Account updatedAcc = [SELECT Phone FROM Account WHERE Id = :acc.Id];
        System.assertEquals('123456', updatedAcc.Phone);
    }
}
