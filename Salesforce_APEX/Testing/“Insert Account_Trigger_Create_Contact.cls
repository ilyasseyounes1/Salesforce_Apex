// --------------------
// Trigger
// --------------------
trigger AccountTrigger on Account (after insert) {
    AccountTriggerHandler.createContactForNewAccounts(Trigger.new);
}

// --------------------
// Trigger Handler Class
// --------------------
public class AccountTriggerHandler {
    
    public static void createContactForNewAccounts(List<Account> newAccounts) {
        List<Contact> contactsToInsert = new List<Contact>();
        
        for (Account acc : newAccounts) {
            Contact con = new Contact(
                FirstName = 'Auto',
                LastName = acc.Name + ' Contact',
                Email = 'contact@' + acc.Name.removeWhitespace().toLowerCase() + '.com',
                AccountId = acc.Id
            );
            contactsToInsert.add(con);
        }
        
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }
}

// --------------------
// Test Class
// --------------------
@isTest
private class AccountTriggerTest {
    
    @isTest static void testAccountInsertCreatesContact() {
        // Create test data
        Account acc = new Account(Name = 'Test Company');
        
        Test.startTest();
        insert acc;
        Test.stopTest();
        
        // Query created Contact
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, AccountId 
                                  FROM Contact WHERE AccountId = :acc.Id];
        
        // Assertions
        System.assertEquals(1, contacts.size(), 'A Contact should be created for the Account');
        System.assertEquals('Auto', contacts[0].FirstName);
        System.assert(contacts[0].LastName.contains('Test Company'));
        System.assertEquals(acc.Id, contacts[0].AccountId);
    }
}
