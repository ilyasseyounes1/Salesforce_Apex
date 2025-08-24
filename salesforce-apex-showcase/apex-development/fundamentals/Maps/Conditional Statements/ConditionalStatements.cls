// File 1: Basic Conditional Statements in Apex
public class ConditionalStatements {
    public static void checkNumber(Integer num) {
        if (num > 0) {
            System.debug('The number is positive');
        } else if (num < 0) {
            System.debug('The number is negative');
        } else {
            System.debug('The number is zero');
        }
    }
    
    public static void checkString(String input) {
        switch on input {
            when 'Hello' {
                System.debug('Greeting detected');
            }
            when 'Bye' {
                System.debug('Farewell detected');
            }
            when else {
                System.debug('Unknown input');
            }
        }
    }
}

// File 2: Conditional Statements with sObjects, Lists, Sets, and Maps
public class AdvancedConditionalStatements {
    public static void checkContacts(List<Contact> contacts) {
        if (contacts.isEmpty()) {
            System.debug('No contacts available');
        } else {
            for (Contact c : contacts) {
                if (c.LastName == 'Smith') {
                    System.debug('Found a Smith!');
                }
            }
        }
    }
    
    public static void checkAccountMap(Map<String, Account> accountMap) {
        if (accountMap.containsKey('AcmeCorp')) {
            System.debug('AcmeCorp account found');
        } else {
            System.debug('AcmeCorp account not found');
        }
    }
}
