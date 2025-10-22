#  Technical Interview Preparation

![Interview Success](images/interview-preparation.png)

##  Common Apex Interview Questions

### **Level 1: Fundamentals**

#### Q1: What is Apex and how does it differ from Java?
**Answer:**
- Apex is Salesforce's proprietary programming language
- Strongly-typed, object-oriented language
- Runs on Salesforce's multi-tenant platform
- Key differences from Java:
  - No primitive data types (all are objects)
  - Built-in governor limits
  - Native SOQL/SOSL integration
  - Automatic transaction management

#### Q2: Explain the different types of triggers in Salesforce
**Answer:**
`pex
// Before triggers - for validation and field updates
trigger AccountTrigger on Account (before insert, before update) {
    for (Account acc : Trigger.new) {
        if (acc.AnnualRevenue == null) {
            acc.AnnualRevenue = 0;
        }
    }
}

// After triggers - for related record updates
trigger AccountTrigger on Account (after insert, after update) {
    List<Contact> contactsToUpdate = new List<Contact>();
    
    for (Account acc : Trigger.new) {
        for (Contact con : [SELECT Id FROM Contact WHERE AccountId = :acc.Id]) {
            con.Account_Type__c = acc.Type;
            contactsToUpdate.add(con);
        }
    }
    
    if (!contactsToUpdate.isEmpty()) {
        update contactsToUpdate;
    }
}
`

### **Level 2: Intermediate**

#### Q3: How do you handle bulk operations and avoid governor limits?
**Answer:**
`pex
public class BulkProcessingExample {
    
    public void processBulkRecords(List<Account> accounts) {
        // 1. Collect IDs for related queries
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        
        // 2. Single query for all related data
        Map<Id, List<Contact>> contactsByAccount = new Map<Id, List<Contact>>();
        for (Contact con : [SELECT Id, AccountId, Email FROM Contact WHERE AccountId IN :accountIds]) {
            if (!contactsByAccount.containsKey(con.AccountId)) {
                contactsByAccount.put(con.AccountId, new List<Contact>());
            }
            contactsByAccount.get(con.AccountId).add(con);
        }
        
        // 3. Process in bulk
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Account acc : accounts) {
            List<Contact> relatedContacts = contactsByAccount.get(acc.Id);
            if (relatedContacts != null) {
                for (Contact con : relatedContacts) {
                    con.Account_Name__c = acc.Name;
                    contactsToUpdate.add(con);
                }
            }
        }
        
        // 4. Single DML operation
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}
`

#### Q4: Explain different types of Apex collections and when to use each
**Answer:**
`pex
public class CollectionExamples {
    
    public void demonstrateCollections() {
        // List - Ordered collection, allows duplicates
        List<String> accountTypes = new List<String>{'Customer', 'Partner', 'Customer'};
        accountTypes.add('Prospect');
        System.debug('List size: ' + accountTypes.size()); // 4
        
        // Set - Unordered collection, no duplicates
        Set<String> uniqueTypes = new Set<String>{'Customer', 'Partner', 'Customer'};
        System.debug('Set size: ' + uniqueTypes.size()); // 2
        
        // Map - Key-value pairs for fast lookups
        Map<Id, Account> accountMap = new Map<Id, Account>();
        List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 10];
        
        for (Account acc : accounts) {
            accountMap.put(acc.Id, acc);
        }
        
        // O(1) lookup time
        Account foundAccount = accountMap.get(someAccountId);
    }
}
`

### **Level 3: Advanced**

#### Q5: Implement a trigger handler framework
**Answer:**
`pex
// Base trigger handler
public virtual class TriggerHandler {
    
    protected TriggerContext context;
    private static Set<String> bypassedHandlers = new Set<String>();
    
    public TriggerHandler() {
        this.context = new TriggerContext();
    }
    
    public void run() {
        if (isDisabled()) {
            return;
        }
        
        switch on context.triggerEvent {
            when BEFORE_INSERT {
                beforeInsert();
            }
            when BEFORE_UPDATE {
                beforeUpdate();
            }
            when AFTER_INSERT {
                afterInsert();
            }
            when AFTER_UPDATE {
                afterUpdate();
            }
        }
    }
    
    // Virtual methods to override
    protected virtual void beforeInsert() {}
    protected virtual void beforeUpdate() {}
    protected virtual void afterInsert() {}
    protected virtual void afterUpdate() {}
    
    // Bypass mechanism
    public static void bypass(String handlerName) {
        bypassedHandlers.add(handlerName);
    }
    
    private Boolean isDisabled() {
        return bypassedHandlers.contains(getHandlerName());
    }
    
    private String getHandlerName() {
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }
}

// Implementation
public class AccountTriggerHandler extends TriggerHandler {
    
    protected override void beforeInsert() {
        validateAccountData((List<Account>) Trigger.new);
    }
    
    protected override void afterInsert() {
        createDefaultContacts((List<Account>) Trigger.new);
    }
    
    private void validateAccountData(List<Account> accounts) {
        for (Account acc : accounts) {
            if (String.isBlank(acc.Name)) {
                acc.addError('Account name is required');
            }
        }
    }
    
    private void createDefaultContacts(List<Account> accounts) {
        List<Contact> contactsToInsert = new List<Contact>();
        
        for (Account acc : accounts) {
            contactsToInsert.add(new Contact(
                AccountId = acc.Id,
                LastName = 'Default Contact',
                Email = 'default@' + acc.Name.toLowerCase().replaceAll(' ', '') + '.com'
            ));
        }
        
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }
}
`

##  Coding Challenge Examples

### Challenge 1: Deduplication Service
`pex
/**
 * Create a service that finds and merges duplicate accounts based on:
 * - Same name (case-insensitive)
 * - Same email domain
 * - Same phone number
 */
public class AccountDeduplicationService {
    
    public class DuplicateGroup {
        public Account masterRecord;
        public List<Account> duplicates;
        
        public DuplicateGroup(Account master) {
            this.masterRecord = master;
            this.duplicates = new List<Account>();
        }
    }
    
    public List<DuplicateGroup> findDuplicates() {
        List<Account> allAccounts = [
            SELECT Id, Name, Website, Phone, CreatedDate
            FROM Account 
            WHERE Name != null
            ORDER BY CreatedDate ASC
        ];
        
        Map<String, DuplicateGroup> duplicateMap = new Map<String, DuplicateGroup>();
        
        for (Account acc : allAccounts) {
            String key = generateDuplicateKey(acc);
            
            if (duplicateMap.containsKey(key)) {
                duplicateMap.get(key).duplicates.add(acc);
            } else {
                duplicateMap.put(key, new DuplicateGroup(acc));
            }
        }
        
        // Return only groups with duplicates
        List<DuplicateGroup> result = new List<DuplicateGroup>();
        for (DuplicateGroup group : duplicateMap.values()) {
            if (!group.duplicates.isEmpty()) {
                result.add(group);
            }
        }
        
        return result;
    }
    
    private String generateDuplicateKey(Account acc) {
        List<String> keyParts = new List<String>();
        
        // Name similarity
        if (acc.Name != null) {
            keyParts.add(acc.Name.toLowerCase().replaceAll('[^a-z0-9]', ''));
        }
        
        // Email domain
        if (acc.Website != null) {
            keyParts.add(extractDomain(acc.Website));
        }
        
        // Phone number (digits only)
        if (acc.Phone != null) {
            keyParts.add(acc.Phone.replaceAll('[^0-9]', ''));
        }
        
        return String.join(keyParts, '|');
    }
    
    private String extractDomain(String website) {
        // Extract domain from website URL
        return website.replaceAll('https?://(www\\.)?', '').split('/')[0];
    }
}
`

### Challenge 2: Rate Limiter Implementation
`pex
/**
 * Implement a rate limiter for API calls
 */
public class RateLimiter {
    
    private static Map<String, List<DateTime>> requestLog = new Map<String, List<DateTime>>();
    
    public static Boolean isAllowed(String identifier, Integer maxRequests, Integer timeWindowMinutes) {
        DateTime now = System.now();
        DateTime windowStart = now.addMinutes(-timeWindowMinutes);
        
        // Get or create request history
        if (!requestLog.containsKey(identifier)) {
            requestLog.put(identifier, new List<DateTime>());
        }
        
        List<DateTime> requests = requestLog.get(identifier);
        
        // Remove old requests outside time window
        List<DateTime> validRequests = new List<DateTime>();
        for (DateTime requestTime : requests) {
            if (requestTime >= windowStart) {
                validRequests.add(requestTime);
            }
        }
        
        // Check if under limit
        if (validRequests.size() < maxRequests) {
            validRequests.add(now);
            requestLog.put(identifier, validRequests);
            return true;
        }
        
        return false;
    }
    
    public static void resetLimits(String identifier) {
        requestLog.remove(identifier);
    }
}
`

##  Interview Tips

### **Technical Preparation**
1.  **Study Core Concepts**
   - Governor limits and bulkification
   - Trigger best practices
   - SOQL optimization
   - Security model (FLS, CRUD, Sharing)
   - Asynchronous processing

2.  **Practice Coding**
   - Write code on whiteboard/paper
   - Explain your thought process
   - Consider edge cases
   - Discuss testing approach

3.  **System Design**
   - Understand enterprise patterns
   - Discuss scalability considerations
   - Integration approaches
   - Data modeling decisions

### **Behavioral Questions**
- "Describe a challenging Apex problem you solved"
- "How do you approach debugging complex issues?"
- "Tell me about a time you optimized slow-performing code"
- "How do you stay updated with Salesforce releases?"

### **Questions to Ask Interviewer**
- What does the Salesforce development team structure look like?
- What are the main technical challenges the team is facing?
- How do you handle deployments and release management?
- What opportunities are there for learning and growth?

---

*Practice makes perfect! *
