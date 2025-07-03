public class SOQLQuery {
    public static void queryDemo() {

        // Query 1: Retrieve accounts with Industry 'Media' or 'Energy'
        List<Account> accList = [
            SELECT Id, Name, Industry
            FROM Account
            WHERE Industry IN ('Media', 'Energy')
        ];

        // Debugging retrieved accounts
        for (Account acc : accList) {
            System.debug(acc);
        }

        // Query 2: Retrieve accounts with Industry 'Media' and order by Name descending
        List<Account> accList2 = [
            SELECT Id, Name, Industry
            FROM Account
            WHERE Industry = 'Media'
            ORDER BY Name DESC
        ];

        // Debugging retrieved accounts
        for (Account acc : accList2) {
            System.debug(acc);
        }

        // Query 3: Using a variable in SOQL query
        String med = 'Media';
        List<Account> accList3 = [
            SELECT Id, Name, Industry
            FROM Account
            WHERE Industry = :med
            ORDER BY Name DESC
        ];

        // Debugging retrieved accounts
        for (Account acc : accList3) {
            System.debug(acc);
        }

        // Query 4: Retrieve a limited set of account records
        Set<Id> accIds = new Set<Id>();
        List<Account> accList4 = [
            SELECT Id FROM Account LIMIT 10
        ];

        // Storing retrieved account Ids into a Set
        for (Account acc : accList4) {
            accIds.add(acc.Id);
        }

        // Query 5: Retrieve account details for previously collected account IDs
        List<Account> accList5 = [
            SELECT Id, Name, Industry, AnnualRevenue
            FROM Account
            WHERE Id IN :accIds
        ];

        // Debugging retrieved accounts
        for (Account acc : accList5) {
            System.debug(acc);
        }

         // Query 5: Retrieve account details for previously collected account IDs and store in a Map
        Map<Id, Account> accMap5 = new Map<Id, Account>([
            SELECT Id, Name, Industry, AnnualRevenue
            FROM Account
            WHERE Id IN :accIds
        ]);

        // Debugging retrieved accounts
        System.debug(accMap5);

          // Query 6: Aggregate Function - Get total annual revenue for all accounts
        AggregateResult totalRevenue = [
            SELECT SUM(AnnualRevenue) totalRevenue FROM Account
        ];

        System.debug('Total Annual Revenue: ' + totalRevenue.get('totalRevenue'));

        // Query 7: Aggregate Function - Count accounts by industry
        List<AggregateResult> industryCount = [
            SELECT Industry, COUNT(Id) recordCount FROM Account GROUP BY Industry
        ];

        // Debugging industry count
        for (AggregateResult ar : industryCount) {
            System.debug('Industry: ' + ar.get('Industry') + ', Count: ' + ar.get('recordCount'));
        }
        //Retrieves all accounts where the Name contains "Global".
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Name LIKE '%Global%'];
            for (Account acc : accs) {
            System.debug('Matching Account: ' + acc.Name);


        //1. Child-to-Parent (Many-to-One)
        //You go from child to parent using dot notation.
        //Example: From a Contact to its Account.
        List<Contact> Contacts = [SELECT Id,FistName,LastName,Account.Name FROM Contact];
        for (Contact c: contacts ){
            System.debug('Contact:'+ c.FistName +''+ c.LastName + 'Account :'+ c.Account.Name);
        }
                        //Each Contact has a lookup to an Account.
                        //Account.Name accesses the parent Account's name via the relationship.

        //***************************************************** */

        //2. Parent-to-Child (One-to-Many)
        //You go from parent to children using a subquery inside parentheses (...).
        //Use the child relationship name, not the object name.
        //Example: From Account to its related Contacts:
        List<Account> accounts = [SELECT Id, Name, (SELECT Id, FirstName, LastName FROM Contacts) FROM Account];
        for(Account acc : accounts){
            System.debug('Account: ' + acc.Name);
            for(Contact c : acc.Contacts){
            System.debug('  Contact: ' + c.FirstName + ' ' + c.LastName);
            }
                    //Contacts is the child relationship name (not Contact).
                    //It fetches all Contacts related to each Account.
        }


        /*Nested Relationship Example  */
        //Get all Opportunities and their Account Names and Contacts:
        List<Opportunity> opps = [
            SELECT Id, Name, Account.Name,
           Account.Owner.Name,
           (SELECT Id, FirstName, LastName FROM Account.Contacts)
    FROM Opportunity
];

            for(Opportunity o : opps){
                System.debug('Opportunity: ' + o.Name);
                System.debug('  Account: ' + o.Account.Name);
                System.debug('  Account Owner: ' + o.Account.Owner.Name);
                for(Contact c : o.Account.Contacts){
                    System.debug('    Contact: ' + c.FirstName + ' ' + c.LastName);
                }
}

            }}}


