
// === Trigger: CreateCaseForVIPContact ===
trigger CreateCaseForVIPContact on Contact (after insert) {
    List<Case> casesToCreate = new List<Case>();

    for (Contact con : Trigger.new) {
        if (con.VIP__c == true) { // Assume VIP__c is a custom checkbox field
            Case newCase = new Case(
                Subject = 'Welcome VIP Contact: ' + con.FirstName + ' ' + con.LastName,
                Status = 'New',
                Priority = 'High',
                Origin = 'Web',
                ContactId = con.Id,
                AccountId = con.AccountId
            );
            casesToCreate.add(newCase);
        }
    }

    if (!casesToCreate.isEmpty()) {
        insert casesToCreate;
    }
}

// === Test Class: CreateCaseForVIPContactTest ===
@isTest
private class CreateCaseForVIPContactTest {

    @isTest
    static void testVIPContactCreatesCase() {
        // Create test Account
        Account acc = new Account(Name = 'TestCorp');
        insert acc;

        // Create VIP Contact
        Contact vip = new Contact(
            FirstName = 'Alice',
            LastName = 'Johnson',
            Email = 'alice@example.com',
            VIP__c = true,
            AccountId = acc.Id
        );
        insert vip;

        // Verify case was created
        List<Case> cases = [SELECT Subject, ContactId, AccountId, Priority, Status FROM Case WHERE ContactId = :vip.Id];
        System.assertEquals(1, cases.size());
        System.assertEquals('High', cases[0].Priority);
        System.assertEquals('New', cases[0].Status);
        System.assertEquals(acc.Id, cases[0].AccountId);
        System.assert(cases[0].Subject.contains('Welcome VIP Contact'));
    }

    @isTest
    static void testNonVIPDoesNotCreateCase() {
        Contact normal = new Contact(
            FirstName = 'Bob',
            LastName = 'Smith',
            VIP__c = false
        );
        insert normal;

        List<Case> cases = [SELECT Id FROM Case WHERE ContactId = :normal.Id];
        System.assertEquals(0, cases.size());
    }
}
