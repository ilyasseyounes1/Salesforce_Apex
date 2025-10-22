#  Performance Guide & Governor Limits

![Performance](images/performance-optimization.png)

## 🎯 Understanding Governor Limits

Salesforce enforces **governor limits** to ensure fair resource sharing in the multi-tenant environment. These limits prevent any single tenant from monopolizing shared resources.

###  Key Governor Limits (Per Transaction)

| Resource | Synchronous Limit | Asynchronous Limit |
|----------|-------------------|-------------------|
| **Total number of SOQL queries** | 100 | 200 |
| **Total number of DML statements** | 150 | 150 |
| **Total number of records processed by DML** | 10,000 | 10,000 |
| **Total heap size** | 6 MB | 12 MB |
| **Maximum CPU time** | 10,000 ms | 60,000 ms |
| **Maximum execution time for each Apex transaction** | 10 minutes | 10 minutes |

##  Performance Optimization Strategies

### 1. **Query Optimization**

####  Anti-Pattern: Queries in Loops
`pex
// BAD: Query inside loop (N+1 problem)
public void updateAccountRatings(List<Opportunity> opps) {
    for (Opportunity opp : opps) {
        // This query runs for each opportunity!
        Account acc = [SELECT Id, Rating FROM Account WHERE Id = :opp.AccountId];
        if (opp.Amount > 50000) {
            acc.Rating = 'Hot';
            update acc;
        }
    }
}
`

####  Best Practice: Bulkified Queries
`pex
// GOOD: Single query with bulkification
public void updateAccountRatings(List<Opportunity> opps) {
    // 1. Collect all Account IDs
    Set<Id> accountIds = new Set<Id>();
    for (Opportunity opp : opps) {
        accountIds.add(opp.AccountId);
    }
    
    // 2. Single query for all accounts
    Map<Id, Account> accountMap = new Map<Id, Account>(
        [SELECT Id, Rating FROM Account WHERE Id IN :accountIds]
    );
    
    // 3. Process and collect updates
    List<Account> accountsToUpdate = new List<Account>();
    for (Opportunity opp : opps) {
        if (opp.Amount > 50000) {
            Account acc = accountMap.get(opp.AccountId);
            if (acc != null && acc.Rating != 'Hot') {
                acc.Rating = 'Hot';
                accountsToUpdate.add(acc);
            }
        }
    }
    
    // 4. Single DML operation
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
`

### 2. **Selective SOQL Queries**

####  Inefficient Query
`pex
// BAD: Selecting unnecessary fields and records
List<Account> accounts = [
    SELECT Id, Name, BillingAddress, ShippingAddress, Description, 
           Website, Phone, Fax, AccountNumber, Site, TickerSymbol,
           (SELECT Id, FirstName, LastName, Email, Phone, Title,
                   MailingAddress, OtherAddress, Department, Birthdate
            FROM Contacts)
    FROM Account
];
`

####  Optimized Query
`pex
// GOOD: Select only needed fields with filtering
List<Account> accounts = [
    SELECT Id, Name, Type, 
           (SELECT Id, FirstName, LastName, Email 
            FROM Contacts 
            WHERE IsActive__c = true 
            ORDER BY LastName
            LIMIT 5)
    FROM Account 
    WHERE Type IN ('Customer', 'Partner')
    AND CreatedDate = LAST_N_DAYS:30
    AND BillingCountry = 'USA'
    ORDER BY Name
    LIMIT 200
];
`

### 3. **Efficient Collection Usage**

#### Maps for Fast Lookups
`pex
//  Use Maps for O(1) lookups instead of Lists O(n)
public void processContacts(List<Contact> contacts) {
    // Collect Account IDs
    Set<Id> accountIds = new Set<Id>();
    for (Contact con : contacts) {
        accountIds.add(con.AccountId);
    }
    
    // Create Map for fast lookups
    Map<Id, Account> accountMap = new Map<Id, Account>(
        [SELECT Id, Name, Type FROM Account WHERE Id IN :accountIds]
    );
    
    // Fast lookups using Map
    for (Contact con : contacts) {
        Account relatedAccount = accountMap.get(con.AccountId);
        if (relatedAccount != null) {
            // Process contact with account data
            con.Account_Type__c = relatedAccount.Type;
        }
    }
}
`

#### Set for Uniqueness Checks
`pex
//  Use Set for efficient uniqueness checking
public List<Account> removeDuplicatesByName(List<Account> accounts) {
    Set<String> uniqueNames = new Set<String>();
    List<Account> uniqueAccounts = new List<Account>();
    
    for (Account acc : accounts) {
        String accountName = acc.Name?.toLowerCase();
        if (accountName != null && !uniqueNames.contains(accountName)) {
            uniqueNames.add(accountName);
            uniqueAccounts.add(acc);
        }
    }
    
    return uniqueAccounts;
}
`

### 4. **DML Optimization**

#### Batch DML Operations
`pex
//  Batch DML operations to avoid governor limits
public void massUpdateAccounts(List<Account> accounts) {
acc.AnnualRevenue = revenue;
    
    try {
        update acc;
    } catch (DmlException e) {
        System.debug('Validation failed: ' + e.getDmlMessage(0));
        throw new CustomException('Failed to update account: ' + e.getDmlMessage(0));
    }
}
`

### 3. **Governor Limit Errors**

####  System.LimitException: Apex CPU time limit exceeded
`pex
// PROBLEM: Inefficient processing
public void processLargeDataSet(List<Account> accounts) {
    for (Account acc : accounts) {
        for (Contact con : [SELECT Id FROM Contact WHERE AccountId = :acc.Id]) {
            // Expensive operation for each contact
            String result = performComplexCalculation(con);
            // More processing...
        }
    }
}
`

`pex
//  SOLUTION: Optimize with efficient data structures
public void processLargeDataSet(List<Account> accounts) {
    // Single query to get all contacts
    Map<Id, List<Contact>> contactsByAccount = new Map<Id, List<Contact>>();
    
    for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accounts]) {
        if (!contactsByAccount.containsKey(con.AccountId)) {
            contactsByAccount.put(con.AccountId, new List<Contact>());
        }
        contactsByAccount.get(con.AccountId).add(con);
    }
    
    // Efficient processing
    for (Account acc : accounts) {
        List<Contact> relatedContacts = contactsByAccount.get(acc.Id);
        if (relatedContacts != null) {
            processContactsBatch(relatedContacts); // Batch processing
        }
    }
}
`

####  System.LimitException: Too many DML statements
`pex
// PROBLEM: DML inside loop
for (Account acc : accounts) {
    acc.Status__c = 'Processed';
    update acc; // Multiple DML statements
}
`

`pex
//  SOLUTION: Collect and batch DML
List<Account> accountsToUpdate = new List<Account>();
for (Account acc : accounts) {
    acc.Status__c = 'Processed';
    accountsToUpdate.add(acc);
}

if (!accountsToUpdate.isEmpty()) {
    update accountsToUpdate; // Single DML statement
}
`

##  Debugging Techniques

### 1. **Effective Debug Logging**
`pex
public class DebugHelper {
    
    public enum LogLevel { ERROR, WARN, INFO, DEBUG }
    
    public static void log(LogLevel level, String className, String methodName, String message) {
        String logMessage = String.format(
            '[{0}] {1}.{2}: {3}',
            new List<String>{
                level.name(),
                className,
                methodName,
                message
            }
        );
        
        switch on level {
            when ERROR {
                System.debug(LoggingLevel.ERROR, logMessage);
            }
            when WARN {
                System.debug(LoggingLevel.WARN, logMessage);
            }
            when INFO {
                System.debug(LoggingLevel.INFO, logMessage);
            }
            when DEBUG {
                System.debug(LoggingLevel.DEBUG, logMessage);
            }
        }
    }
    
    public static void logLimits(String context) {
        String limitsInfo = String.format(
            '{0} - SOQL: {1}/{2}, DML: {3}/{4}, CPU: {5}/{6}ms, Heap: {7}/{8}bytes',
            new List<String>{
                context,
                String.valueOf(Limits.getQueries()),
                String.valueOf(Limits.getLimitQueries()),
                String.valueOf(Limits.getDMLStatements()),
                String.valueOf(Limits.getLimitDMLStatements()),
                String.valueOf(Limits.getCpuTime()),
                String.valueOf(Limits.getLimitCpuTime()),
                String.valueOf(Limits.getHeapSize()),
                String.valueOf(Limits.getLimitHeapSize())
            }
        );
        System.debug(LoggingLevel.INFO, limitsInfo);
    }
}
`

### 2. **Exception Handling Patterns**
`pex
public class RobustService {
    
    public void processRecords(List<SObject> records) {
        try {
            validateInputs(records);
            performBusinessLogic(records);
            saveChanges(records);
            
        } catch (DmlException e) {
            handleDmlException(e);
        } catch (QueryException e) {
            handleQueryException(e);
        } catch (CustomException e) {
            handleBusinessException(e);
        } catch (Exception e) {
            handleUnexpectedException(e);
        }
    }
    
    private void handleDmlException(DmlException e) {
        DebugHelper.log(DebugHelper.LogLevel.ERROR, 'RobustService', 'processRecords', 
                       'DML Error: ' + e.getMessage());
        
        // Create error records for failed DML
        List<ErrorLog__c> errorLogs = new List<ErrorLog__c>();
        for (Integer i = 0; i < e.getNumDml(); i++) {
            errorLogs.add(new ErrorLog__c(
                ErrorType__c = 'DML_EXCEPTION',
                ErrorMessage__c = e.getDmlMessage(i),
                RecordId__c = e.getDmlId(i),
                StackTrace__c = e.getStackTraceString()
            ));
        }
        
        if (!errorLogs.isEmpty()) {
            insert errorLogs;
        }
    }
}
`

##  Performance Debugging

### 1. **Query Performance Analysis**
`pex
public class QueryPerformanceAnalyzer {
    
    public static void analyzeQuery(String queryString) {
        Long startTime = System.currentTimeMillis();
        Integer startQueries = Limits.getQueries();
        Integer startCPU = Limits.getCpuTime();
        
        // Execute query
        List<SObject> results = Database.query(queryString);
        
        Long endTime = System.currentTimeMillis();
        Integer endQueries = Limits.getQueries();
        Integer endCPU = Limits.getCpuTime();
        
        // Log performance metrics
        System.debug('=== QUERY PERFORMANCE ANALYSIS ===');
        System.debug('Query: ' + queryString);
        System.debug('Results: ' + results.size() + ' records');
        System.debug('Execution Time: ' + (endTime - startTime) + 'ms');
        System.debug('SOQL Queries Used: ' + (endQueries - startQueries));
        System.debug('CPU Time Used: ' + (endCPU - startCPU) + 'ms');
        System.debug('===================================');
    }
}
`

### 2. **Memory Usage Tracking**
`pex
public class MemoryTracker {
    
    private static Map<String, Integer> checkpoints = new Map<String, Integer>();
    
    public static void setCheckpoint(String name) {
        checkpoints.put(name, Limits.getHeapSize());
        System.debug('MEMORY CHECKPOINT [' + name + ']: ' + Limits.getHeapSize() + ' bytes');
    }
    
    public static void logMemoryUsage(String operation) {
        Integer currentHeap = Limits.getHeapSize();
        Integer maxHeap = Limits.getLimitHeapSize();
        Decimal usagePercent = (Decimal.valueOf(currentHeap) / Decimal.valueOf(maxHeap)) * 100;
        
        System.debug('MEMORY USAGE [' + operation + ']: ' + 
                    currentHeap + '/' + maxHeap + ' (' + 
                    usagePercent.setScale(2) + '%)');
        
        if (usagePercent > 80) {
            System.debug(LoggingLevel.WARN, 'HIGH MEMORY USAGE WARNING!');
        }
    }
}
`

##  Mobile & Lightning Issues

### Lightning Web Component Integration
`pex
//  Proper LWC Apex controller
public with sharing class LWCController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        try {
            return [
                SELECT Id, Name, Type, Industry 
                FROM Account 
                WHERE Type != null 
                ORDER BY Name 
                LIMIT 50
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving accounts: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String updateAccount(Id accountId, String newName) {
        try {
            Account acc = [SELECT Id, Name FROM Account WHERE Id = :accountId];
            acc.Name = newName;
            update acc;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException('Error updating account: ' + e.getMessage());
        }
    }
}
`

##  Testing Issues

### Mock Testing for Callouts
`pex
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        
        // Mock response based on endpoint
        if (request.getEndpoint().contains('/api/accounts')) {
            response.setBody('{"status":"success","data":{"id":"123","name":"Test Account"}}');
        } else {
            response.setStatusCode(404);
            response.setBody('{"error":"Not found"}');
        }
        
        return response;
    }
}

@isTest
private class ExternalServiceTest {
    
    @isTest
    static void testCalloutSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        String result = ExternalService.makeCallout('/api/accounts/123');
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.contains('success'));
    }
}
`

##  Debugging Tools & Commands

### SFDX Debug Commands
`powershell
# View debug logs
sf apex log get --number 5

# Tail logs in real-time
sf apex log tail --color --skip-headers

# Run anonymous Apex
sf apex run --file debug-script.apex

# Get org limits
sf org list limits --target-org MyOrg

# Check API usage
sf org display --target-org MyOrg --verbose
`

### Anonymous Apex Debug Scripts
`pex
// debug-script.apex - Quick debugging
System.debug('=== DEBUGGING SESSION START ===');

// Check current user context
System.debug('Current User: ' + UserInfo.getName());
System.debug('Profile: ' + UserInfo.getProfileId());
System.debug('Org ID: ' + UserInfo.getOrganizationId());

// Check limits
System.debug('SOQL Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
System.debug('DML Statements: ' + Limits.getDMLStatements() + '/' + Limits.getLimitDMLStatements());

// Test specific functionality
try {
    List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 5];
    System.debug('Found ' + accounts.size() + ' accounts');
    
    for (Account acc : accounts) {
        System.debug('Account: ' + acc.Name + ' (ID: ' + acc.Id + ')');
    }
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

System.debug('=== DEBUGGING SESSION END ===');
`

##  Emergency Procedures

### System Recovery Scripts
`pex
public class EmergencyRecovery {
    
    public static void emergencyDataCleanup() {
        System.debug(' EMERGENCY CLEANUP INITIATED');
        
        try {
            // Clean up failed batch jobs
            List<AsyncApexJob> failedJobs = [
                SELECT Id, Status, JobType 
                FROM AsyncApexJob 
                WHERE Status IN ('Failed', 'Aborted')
                AND CreatedDate = TODAY
            ];
            
            System.debug('Found ' + failedJobs.size() + ' failed jobs to review');
            
            // Clean up orphaned records
            cleanupOrphanedRecords();
            
            // Reset system flags
            resetSystemFlags();
            
            System.debug(' Emergency cleanup completed');
            
        } catch (Exception e) {
            System.debug(' Emergency cleanup failed: ' + e.getMessage());
            sendEmergencyAlert(e);
        }
    }
    
    private static void cleanupOrphanedRecords() {
        // Implementation for cleanup
    }
    
    private static void resetSystemFlags() {
        // Reset any system-level flags or settings
    }
    
    private static void sendEmergencyAlert(Exception e) {
        // Send alert to system administrators
    }
}
`

---

*When in doubt, debug it out! *
