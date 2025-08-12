public class AccountProcessor {
    
    @future
    public static void countContacts(List<Id> accountIds) {
        // Aggregate contacts by Account
        Map<Id, Integer> contactCountMap = new Map<Id, Integer>();
        
        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) cnt
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            contactCountMap.put((Id)ar.get('AccountId'), (Integer)ar.get('cnt'));
        }
        
        // Prepare list of accounts to update
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountIds) {
            Integer count = contactCountMap.containsKey(accId) ? contactCountMap.get(accId) : 0;
            accountsToUpdate.add(new Account(
                Id = accId,
                Number_Of_Contacts__c = count
            ));
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
/*
Test Class : 

@isTest
public class AccountProcessorTest {
    
    @isTest
    static void testCountContacts() {
        // Create accounts
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{ acc1, acc2 };
        
        // Add contacts to first account only
        Contact c1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc1.Id);
        Contact c2 = new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = acc1.Id);
        insert new List<Contact>{ c1, c2 };
        
        // Call future method
        Test.startTest();
        AccountProcessor.countContacts(new List<Id>{ acc1.Id, acc2.Id });
        Test.stopTest(); // Ensures @future executes
        
        // Query updated accounts
        Account updatedAcc1 = [SELECT Number_Of_Contacts__c FROM Account WHERE Id = :acc1.Id];
        Account updatedAcc2 = [SELECT Number_Of_Contacts__c FROM Account WHERE Id = :acc2.Id];
        
        // Assert results
        System.assertEquals(2, updatedAcc1.Number_Of_Contacts__c, 'Acc1 should have 2 contacts');
        System.assertEquals(0, updatedAcc2.Number_Of_Contacts__c, 'Acc2 should have 0 contacts');
    }
}


*/