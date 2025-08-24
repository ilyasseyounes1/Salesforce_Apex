/**
 * SOSL (Salesforce Object Search Language) Complete Reference
 * Author: [Your Name]
 * 
 * SOSL vs SOQL:
 * - SOSL: Search across MULTIPLE objects, text-based search
 * - SOQL: Query from SINGLE object, structured data retrieval
 * 
 * Key Points:
 * - SOSL uses search index (faster for text searches)
 * - Limited to 20 queries per transaction
 * - Maximum 2,000 records per query
 * - Can search up to 25 objects per query
 */

public class SOSLReference {
    
    // ========================================
    // 1. BASIC SOSL SYNTAX
    // ====================================
    
    public static void basicSOSLExamples() {
        // Basic syntax: FIND 'term' IN search_group RETURNING object_list
        
        // Search across all fields in multiple objects
        List<List <SObject>> results1 = [FIND 'John' IN ALL FIELDS RETURNING Account, Contact];
        
        // Search in specific field group
        List<List<SObject> > results2 = [FIND 'Acme' IN NAME FIELDS RETURNING Account(Id, Name)];
        
        // Search with specific fields returned
        List<List<SObject> > results3 = [FIND 'Technology' IN ALL FIELDS 
                                        RETURNING Account(Id, Name, Industry), 
                                                Contact(Id, Name, Email)];
    }
    }
    
    // =======================================
    // 2. SEARCH GROUPS
    // ========================================
    
    public static void searchGroupExamples() {
        // ALL FIELDS - searches all searchable fields (most comprehensive, slower)
        List<List<SObject>> allFields = [FIND 'Acme' IN ALL FIELDS RETURNING Account];
        
        // NAME FIELDS - searches name-related fields only (faster for name searches)
        List<List<SObject>> nameFields = [FIND 'John Smith' IN NAME FIELDS RETURNING Contact];
        
        // EMAIL FIELDS - searches email fields only
        List<List<SObject>> emailFields = [FIND 'john@company.com' IN EMAIL FIELDS RETURNING Contact];
        
        // PHONE FIELDS - searches phone fields only
        List<List<SObject>> phoneFields = [FIND '555-1234' IN PHONE FIELDS RETURNING Contact];
        
        // SIDEBAR FIELDS - searches recently viewed records
        List<List<SObject>> sidebarFields = [FIND 'Acme' IN SIDEBAR FIELDS RETURNING Account];
    }
    
    // ========================================
    // 3. WILDCARDS AND PATTERN MATCHING
    // =====================================
    
    public static void wildcardExamples() {
        // Asterisk (*) - matches any number of characters
        List<List<SObject>> wildcard1 = [FIND 'John*' IN ALL FIELDS RETURNING Contact];
        
        // Question mark (?) - matches single character
        List<List<SObject>> wildcard2 = [FIND 'Sm?th' IN ALL FIELDS RETURNING Contact];
        
        // Phrase search with quotes
        List<List<SObject>> phrase = [FIND '"John Smith"' IN ALL FIELDS RETURNING Contact];
        
        // Boolean operators
        List<List<SObject>> orSearch = [FIND 'John OR Jane' IN ALL FIELDS RETURNING Contact];
        List<List<SObject>> notSearch = [FIND 'John NOT Smith' IN ALL FIELDS RETURNING Contact];
    }
    
    // ======================================
    // 4. RETURNING CLAUSE WITH FILTERS
    // ========================================
    
    public static void returningWithFilters() {
        // Basic returning with specific fields
        List<List<SObject>> basic = [FIND 'Acme' IN ALL FIELDS 
                                    RETURNING Account(Id, Name, Industry)];
        
        // With WHERE clause filtering
        List<List<SObject>> withWhere = [FIND 'Technology' IN ALL FIELDS 
                                        RETURNING Account(Id, Name WHERE Industry = 'Technology')];
        
        // With ORDER BY
        List<List<SObject>> withOrder = [FIND 'John' IN ALL FIELDS 
                                        RETURNING Contact(Id, Name ORDER BY Name)];
        
        // With LIMIT
        List<List<SObject>> withLimit = [FIND 'Account' IN ALL FIELDS 
                                        RETURNING Account(Id, Name) LIMIT 10];
        
        // Multiple conditions
        List<List<SObject>> complex = [FIND 'Manager' IN ALL FIELDS 
                                      RETURNING Contact(Id, Name, Department 
                                                       WHERE Department = 'Sales' AND Title LIKE '%Manager%' 
                                                       ORDER BY Name LIMIT 25)];
    }
    
    // ========================================
    // 5. RELATIONSHIP QUERIES
    //    ========================================
    
    public static void relationshipQueries() {
        // Child-to-parent relationships
        List<List<SObject>> childToParent = [FIND 'John' IN ALL FIELDS 
                                            RETURNING Contact(Id, Name, Account.Name, Account.Industry)];
        
        // Custom relationships
        List<List<SObject>> customRel = [FIND 'Custom' IN ALL FIELDS 
                                        RETURNING Custom_Object__c(Id, Name, Parent_Object__r.Name)];
        
        // Note: Parent-to-child relationships have limited support in SOSL
        // Use SOQL for complex parent-to-child queries
    }
    
    // =====================================
    // 6. PROCESSING RESULTS
    // ======================================== 
    
    public static void processResults() {
        // SOSL returns List<List<SObject >> - each inner list corresponds to an object type
        List<List<SObject>> results = [FIND 'Acme' IN ALL FIELDS 
                                      RETURNING Account(Id, Name), 
                                               Contact(Id, Name), 
                                               Lead(Id, Name)];
        
        // Safe result processing
        if (!results.isEmpty()) {
            // First list = Accounts
            if (results.size() > 0 && !results[0].isEmpty()) {
                List<Account> accounts = (List<Account>)results[0];
                for (Account acc  : accounts) {
                    System.debug('Account: ' + acc.Name);
                }
            }
            
            // Second list = Contacts
            if (results.size() > 1 && !results[1].isEmpty()) {
                List<Contact> contacts = (List<Contact>)results[1];
                for (Contact con : contacts) {
                    System.debug('Contact: ' + con.Name);
                }
            } 
            
            // Third list = Leads
            if (results.size() > 2 && !results[2].isEmpty()) {
                List<Lead> leads  = (List<Lead>)results[2];
                for (Lead lead : leads) {
                    System.debug('Lead: ' + lead.Name);
                }
            }
        }
    }
    
    // ========================================
    // 7. DYNAMIC SOSL
    // ========================================
    
    public static void dynamicSOSL() {
        // Using Search.query() for dynamic SOSL
        String searchTerm = 'Acme';
        String query  = 'FIND \'' + String.escapeSingleQuotes(searchTerm) + '\' IN ALL FIELDS RETURNING Account(Id, Name)';
        List<List<SObject>> results = Search.query(query);
        
        // Building dynamic query
        String dynamicQuery = buildDynamicQuery('John', new List<String>{'Account', 'Contact'});
        List<List<SObject>> dynamicResults = Search.query(dynamicQuery);
    }
    
    // Helper method for building dynamic queries
    private static String  buildDynamicQuery(String searchTerm, List<String> objectTypes) {
        String query = 'FIND \'' + String.escapeSingleQuotes(searchTerm) + '\' IN ALL FIELDS RETURNING ';
        
        List<String> returningClauses = new List<String>();
        for (String objType : objectTypes) {
            returningClauses.add(objType + '(Id, Name)');
        }
        
        query += String.join(returningClauses, ', ');
        return query;
    }
    
    // ========================================
    // 8. COMMON USE CASES
    // ========================================
    
    // Global search functionality
    public static List<List<SObject>> globalSearch(String searchTerm) {
        if (String.isBlank(searchTerm) || searchTerm.length() < 2) {
            return new  List<List<SObject>>();
        }
        
        return [FIND :searchTerm IN ALL FIELDS 
                RETURNING Account(Id, Name, Industry), 
                         Contact(Id, Name, Email, Phone), 
                          Lead(Id, Name, Company, Email) 
                LIMIT 50];
    }
    
    // Email search across objects
    public static List<List<SObject>> findByEmail(String email) {
        return [FIND :email IN EMAIL FIELDS 
                RETURNING Contact(Id, Name, Email, Account.Name), 
                         Lead(Id, Name, Email, Company)];
    }
    
    // Phone search across objects
    public static List<List<SObject>> findByPhone(String phone) {
        return [FIND :phone IN PHONE FIELDS 
                  RETURNING Contact(Id, Name, Phone, Account.Name), 
                         Lead(Id, Name, Phone, Company)];
    }
    
    // Typeahead/autocomplete functionality
    public static List<String> getTypeaheadSuggestions(String searchTerm) {
        List<String> suggestions = new List<String>   ();
        
        try {
            List<List<SObject>> results = [FIND :searchTerm IN NAME FIELDS 
                                          RETURNING Account(Id, Name), 
                                                   Contact(Id, Name) 
                                          LIMIT 20];
            
            for (List<SObject> objectList : results) {
                for (SObject obj : objectList) {
                    suggestions.add((String)obj.get('Name'));
                }
            }
        } catch (Exception e) {
            System.debug('Typeahead search error: ' + e.getMessage());
        }
        
        return suggestions;
    }
    
    // ========================================
    // 9. ERROR   HANDLING 
    // ========================================
    
    public static  List<List<SObject>> safeSearch(String searchTerm) {
        // Input validation
        if (String.isBlank(searchTerm)) {
            return new List<List<SObject>>();
        }
        
        if (searchTerm.length() < 2) {
            return new List<List<SObject>>();
        }
        
        try {
            // Escape special characters
            String escapedTerm = String.escapeSingleQuotes(searchTerm);
            
            return [FIND :escapedTerm IN ALL FIELDS 
                    RETURNING Account(Id, Name), 
                             Contact(Id, Name)];
                             
        } catch  (SearchException e) {
            System.debug('Search error: ' + e.getMessage());
            return new List<List<SObject>>();
        } catch (Exception e) {
            System.debug('General error: ' + e.getMessage());
            return new List<List<SObject>>();
        }
    }
    
    // ========================================
    // 10. GOVERNOR LIMITS MONITORING
    // ========================================
    
    public static void checkLimits () {
        // Monitor SOSL usage
        System.debug('SOSL Queries Used: ' +  Limits.getSoslQueries () + '/' + Limits.getLimitSoslQueries()  ) ;
        
        // Check before executing SOSL
        if (Limits.getSoslQueries() < Limits.getLimitSoslQueries() ) {
            List< List<SObject>> results = [FIND 'search' IN ALL FIELDS RETURNING Account] ;
        } else {
            System.debug ('SOSL limit reached');
        }
    }