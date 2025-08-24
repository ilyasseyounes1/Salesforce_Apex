/**
 * @description Test Data Factory for creating test records
 */
@isTest
public class TestDataFactory {
    
    public static Account createTestAccount() {
        return new Account(Name = 'Test Account');
    }
    
    public static List<Account> createTestAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        return accounts;
    }
}
