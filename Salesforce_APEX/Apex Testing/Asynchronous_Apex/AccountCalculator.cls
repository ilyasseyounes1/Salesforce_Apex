public class AccountCalculator {
    @future 
    public static void countContact (List<Id> accIds){
        List<Account> accList = [SELECT Id, Count_Number_Contact__c
                                (SELECT Id From Contacts)
                                From Account 
                                WHERE Id IN: accIds];

    for (Account acc : accList){
        acc.Count_Number_Contact__c = acc.Contacts.size();
    }
    if (!accList.isEmpty()){
        update accList;
    }

    }
}
//----------------To call Async : Anonymous window
List<Account> accList = [SELECT Id 
                        From Account
                        LIMIT 10];
List<Id> AccIds = new List<Id>();
for(Account acc : accList){
    accIds.add(acc.Id);
}
AccountCalculator.countContact(accIds);


//----------------------- Test Class for this method : ------------
@isTest
public class AccountCalculatorTest {
    
    @testSetup
    static void setupTestData() {
        // Create 2 test accounts
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Test Account 1'));
        accounts.add(new Account(Name = 'Test Account 2'));
        insert accounts;
        
        // Create 3 contacts for first account, 0 for second
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= 3; i++) {
            contacts.add(new Contact(
                FirstName = 'Test' + i,
                LastName = 'Contact' + i,
                AccountId = accounts[0].Id
            ));
        }
        insert contacts;
    }
    
    @isTest
    static void testCountContact() {
        // Get account IDs
        List<Id> accountIds = new List<Id>(new Map<Id, Account>([SELECT Id FROM Account]).keySet());
        
        Test.startTest();
        AccountCalculator.countContact(accountIds);
        Test.stopTest();
        
        // Verify results
        List<Account> accounts = [SELECT Id, Count_Number_Contact__c FROM Account ORDER BY Name];
        System.assertEquals(3, accounts[0].Count_Number_Contact__c, 'First account should have 3 contacts');
        System.assertEquals(0, accounts[1].Count_Number_Contact__c, 'Second account should have 0 contacts');
    }
    
    @isTest
    static void testCountContactEmptyList() {
        Test.startTest();
        AccountCalculator.countContact(new List<Id>());
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'Method should handle empty list');
    }
}

//---------------------------------- final version of original class : --------------------------
public class AccountCalculator {
    @future 
    public static void countContact(List<Id> accIds) {
        try {
            // Input validation
            if (accIds == null || accIds.isEmpty()) {
                return;
            }
            
            // Query accounts with their contacts
            List<Account> accList = [SELECT Id, Count_Number_Contact__c,
                                    (SELECT Id FROM Contacts)
                                    FROM Account 
                                    WHERE Id IN :accIds];

            // Process each account
            List<Account> accountsToUpdate = new List<Account>();
            for (Account acc : accList) {
                Integer contactCount = acc.Contacts.size();
                
                // Only update if the count has changed
                if (acc.Count_Number_Contact__c != contactCount) {
                    acc.Count_Number_Contact__c = contactCount;
                    accountsToUpdate.add(acc);
                }
            }
            
            // Update only accounts that need updating
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
            
        } catch (Exception e) {
            // Log error or handle as needed
            System.debug('Error in countContact: ' + e.getMessage());
        }
    }
}