public class AccountRecord {
    public static ID insertAccount(String name,String rating,String active){
        Account acc = new Account();
        acc.Name = name;
        acc.Rating = rating;
        acc.Active__c = active;
            insert acc; 	// this statement will inster a record 
                            // into the org
        	return acc.Id;
    }
    public static void insertContact(){
        Id accId;
        accId = insertAccount ('ilyasse3apex','Hot','yes');
        Contact con = new Contact(FirstName = 'Contact 101',LastName ='Con 101');
        con.accountId = accId; // account is lookup to account.
        insert con;
    }
    public static void inserAccountWithConAndOpp(String name,String rating,String active){
        Account acc = new Account();
        acc.Name = name;
        acc.Rating = rating;
        acc.Active__c = active;
        insert acc;
        
        Contact con = new Contact(FirstName = 'Contact 102', LastName = 'Con 102');
        con.AccountId = acc.Id; // accontId is lookup to account
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Opp 101';
        opp.CloseDate = System.today(); // search Date Formats and Date Literals ....
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.Id;
        insert opp;
    }
    public static void insertAccountWithCon_Opp_Case(String name, String rating, String active) {
    try {
        // Create and insert the Account
        Account acc = new Account();
        acc.Name = name;
        acc.Rating = rating;
        acc.Active__c = active;
        insert acc;

        // Create and insert the Contact linked to the Account
        Contact con = new Contact(FirstName = 'Contact 103', LastName = 'Con103', AccountId = acc.Id);
        insert con;

        // Create and insert the Opportunity linked to the Account
        Opportunity opp = new Opportunity();
        opp.Name = 'Opp 103';
        opp.CloseDate = System.today();
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.Id;
        insert opp;

        // Create  and insert the Case linked to the Contact
        Case ca = new Case();
        ca.Status = 'New';
        ca.Origin = 'Web';
        ca.ContactId = con.Id;
        insert ca;

    } catch (Exception e) {
        System.debug('An error occurred: ' + e.getMessage());
    }
}

}