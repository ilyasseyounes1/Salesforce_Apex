#  Apex Coding Standards & Best Practices

![Best Practices](images/best-practices-banner.png)

##  Table of Contents
- [ General Principles](#general-principles)
- [ Naming Conventions](#naming-conventions)
- [ Code Structure](#code-structure)
- [ Performance Guidelines](#performance-guidelines)
- [ Security Best Practices](#security-best-practices)
- [ Testing Standards](#testing-standards)

---

##  General Principles

### 1. **Write Self-Documenting Code**
`pex
//  Bad
public void processRecords(List<SObject> recs) {
    // What does this method actually do?
}

//  Good
public void updateAccountStatusBasedOnOpportunities(List<Account> accounts) {
    // Clear, descriptive method name tells the story
}
`

### 2. **Follow SOLID Principles**
- **Single Responsibility**: One class, one responsibility
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes must be substitutable for base types
- **Interface Segregation**: Many specific interfaces vs one general
- **Dependency Inversion**: Depend on abstractions, not concretions

### 3. **DRY (Don't Repeat Yourself)**
`pex
//  Bad - Repeated validation logic
public class AccountService {
    public void method1(Account acc) {
        if (acc.Name == null || acc.Name.trim() == '') {
            throw new CustomException('Account name is required');
        }
        // ... rest of method
    }
    
    public void method2(Account acc) {
        if (acc.Name == null || acc.Name.trim() == '') {
            throw new CustomException('Account name is required');
        }
        // ... rest of method
    }
}

//  Good - Centralized validation
public class AccountService {
    private void validateAccountName(Account acc) {
        if (acc.Name == null || acc.Name.trim() == '') {
            throw new CustomException('Account name is required');
        }
    }
    
    public void method1(Account acc) {
        validateAccountName(acc);
        // ... rest of method
    }
    
    public void method2(Account acc) {
        validateAccountName(acc);
        // ... rest of method
    }
}
`

---

##  Naming Conventions

### Classes
`pex
//  Pascal Case for classes
public class AccountTriggerHandler { }
public class PaymentProcessorService { }
public class CustomException extends Exception { }
`

### Methods
`pex
//  Camel Case for methods
public void processPayments() { }
public Boolean isAccountActive() { }
public List<Contact> getActiveContacts() { }
`

### Variables
`pex
//  Camel Case for variables
String customerName;
Integer totalRecords;
List<Account> filteredAccounts;
Map<Id, Contact> contactMap;
`

### Constants
`pex
//  ALL_CAPS for constants
public static final String DEFAULT_ACCOUNT_TYPE = 'Customer';
public static final Integer MAX_RETRY_ATTEMPTS = 3;
private static final String ERROR_MESSAGE = 'Processing failed';
`

### Collections
`pex
//  Descriptive plural names
List<Account> accounts;           // Not accountList
Set<Id> accountIds;              // Not accountIdSet  
Map<Id, Contact> contactsById;   // Not contactMap
`

---

##  Code Structure

### Class Organization
`pex
public class AccountService {
    // 1. Constants (public first, then private)
    public static final String TYPE_CUSTOMER = 'Customer';
    private static final Integer MAX_RECORDS = 200;
    
    // 2. Static variables
    private static Set<Id> processedAccountIds = new Set<Id>();
    
    // 3. Instance variables
    private List<Account> accounts;
    private Map<Id, Contact> relatedContacts;
    
    // 4. Constructors
    public AccountService() {
        this.accounts = new List<Account>();
    }
    
    public AccountService(List<Account> accounts) {
        this.accounts = accounts;
    }
    
    // 5. Public methods
    public void processAccounts() {
        validateAccounts();
        enrichWithContacts();
        updateAccountStatuses();
    }
    
    // 6. Private methods (alphabetical order)
    private void enrichWithContacts() {
        // Implementation
    }
    
    private void updateAccountStatuses() {
        // Implementation
    }
    
    private void validateAccounts() {
        // Implementation
    }
}
`

### Method Structure
`pex
public void processLargeDataSet(List<Account> accounts) {
    // 1. Input validation
    if (accounts == null || accounts.isEmpty()) {
        throw new IllegalArgumentException('Accounts list cannot be null or empty');
    }
    
    // 2. Variable declarations
    List<Account> accountsToUpdate = new List<Account>();
    Set<Id> processedIds = new Set<Id>();
    
    // 3. Main processing logic
    for (Account acc : accounts) {
        if (!processedIds.contains(acc.Id)) {
            // Process account
            processedIds.add(acc.Id);
            accountsToUpdate.add(acc);
        }
    }
    
    // 4. Database operations (at the end)
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
`

---

##  Performance Guidelines

### 1. **Bulkify Your Code**
`pex
//  Bad - Query inside loop
public void updateAccountRatings(List<Opportunity> opportunities) {
    for (Opportunity opp : opportunities) {
        Account acc = [SELECT Id, Rating FROM Account WHERE Id = :opp.AccountId];
        if (opp.Amount > 100000) {
            acc.Rating = 'Hot';
            update acc;
        }
    }
}

//  Good - Bulkified approach
public void updateAccountRatings(List<Opportunity> opportunities) {
    Set<Id> accountIds = new Set<Id>();
    for (Opportunity opp : opportunities) {
        accountIds.add(opp.AccountId);
    }
    
    Map<Id, Account> accountsMap = new Map<Id, Account>(
        [SELECT Id, Rating FROM Account WHERE Id IN :accountIds]
    );
    
    List<Account> accountsToUpdate = new List<Account>();
    for (Opportunity opp : opportunities) {
        if (opp.Amount > 100000) {
            Account acc = accountsMap.get(opp.AccountId);
            if (acc != null) {
                acc.Rating = 'Hot';
                accountsToUpdate.add(acc);
            }
        }
    }
    
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
`

### 2. **Efficient SOQL Queries**
`pex
//  Bad - Inefficient query
List<Account> accounts = [
    SELECT Id, Name, (SELECT Id, FirstName, LastName FROM Contacts)
    FROM Account
];

//  Good - Selective query with filtering
List<Account> accounts = [
    SELECT Id, Name, 
           (SELECT Id, FirstName, LastName 
            FROM Contacts 
            WHERE IsActive__c = true 
            ORDER BY LastName
            LIMIT 10)
    FROM Account 
    WHERE Type = 'Customer' 
    AND CreatedDate = LAST_N_DAYS:30
    LIMIT 200
];
`

### 3. **Use Collections Wisely**
`pex
//  Use Sets for uniqueness checks
Set<String> uniqueNames = new Set<String>();
for (Account acc : accounts) {
    uniqueNames.add(acc.Name);
}

//  Use Maps for lookups
Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
Account foundAccount = accountMap.get(someId); // O(1) lookup
`

---

##  Security Best Practices

### 1. **Enforce FLS and CRUD**
`pex
//  Check permissions before operations
public class SecureAccountService {
    public void createAccounts(List<Account> accounts) {
        // Check object permissions
        if (!Account.SObjectType.getDescribe().isCreateable()) {
            throw new SecurityException('Insufficient permissions to create accounts');
        }
        
        // Check field permissions
        List<String> fieldsToCheck = new List<String>{'Name', 'Type', 'Industry'};
        for (String field : fieldsToCheck) {
            if (!Account.SObjectType.getDescribe().fields.getMap().get(field).getDescribe().isCreateable()) {
                throw new SecurityException('Insufficient permissions for field: ' + field);
            }
        }
        
        insert accounts;
    }
}
`

### 2. **Use Proper Sharing Context**
`pex
//  Explicit sharing control
public with sharing class AccountService {
    // Respects sharing rules
}

public without sharing class SystemService {
    // Only use when necessary for system operations
}

public inherited sharing class FlexibleService {
    // Inherits sharing context from caller
}
`

### 3. **Input Validation**
`pex
public void processUserInput(String userInput) {
    //  Validate and sanitize input
    if (String.isBlank(userInput)) {
        throw new IllegalArgumentException('Input cannot be blank');
    }
    
    if (userInput.length() > 255) {
        throw new IllegalArgumentException('Input too long');
    }
    
    // Remove potential script injection
    String sanitizedInput = userInput.replaceAll('<script[^>]*>.*?</script>', '');
    
    // Continue processing...
}
`

---

##  Testing Standards

### 1. **Comprehensive Test Coverage**
`pex
@isTest
private class AccountServiceTest {
    
    @testSetup
    static void setupTestData() {
        // Create test data once for all test methods
        List<Account> accounts = TestDataFactory.createAccounts(10);
        insert accounts;
    }
    
    @isTest
    static void testProcessAccounts_Success() {
        // Given
        List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 5];
        
        // When
        Test.startTest();
        AccountService service = new AccountService();
        service.processAccounts(accounts);
        Test.stopTest();
        
        // Then
        List<Account> updatedAccounts = [SELECT Id, Status__c FROM Account WHERE Id IN :accounts];
        System.assertEquals(5, updatedAccounts.size(), 'All accounts should be updated');
        for (Account acc : updatedAccounts) {
            System.assertEquals('Processed', acc.Status__c, 'Account status should be updated');
        }
    }
    
    @isTest
    static void testProcessAccounts_EmptyList() {
        // When/Then
        try {
            Test.startTest();
            AccountService service = new AccountService();
            service.processAccounts(new List<Account>());
            Test.stopTest();
            System.assert(false, 'Should have thrown exception');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('cannot be null or empty'));
        }
    }
}
`

### 2. **Test Data Factory Pattern**
`pex
@isTest
public class TestDataFactory {
    
    public static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Type = 'Customer',
                Industry = 'Technology'
            ));
        }
        return accounts;
    }
    
    public static Account createAccount(String name) {
        return new Account(
            Name = name,
            Type = 'Customer',
            BillingCountry = 'USA'
        );
    }
}
`

##  Code Quality Metrics

### Maintainability Guidelines
-  **Cyclomatic Complexity**: < 10 per method
-  **Class Length**: < 500 lines
-  **Method Length**: < 50 lines
-  **Parameter Count**: < 5 per method
-  **Test Coverage**: > 85%

### Code Review Checklist
-  Follows naming conventions
-  Proper error handling
-  No hardcoded values
-  Bulkified for collections
-  Security considerations addressed
-  Comprehensive test coverage
-  Proper documentation

---

*Follow these practices to write maintainable, scalable, and secure Apex code! *
