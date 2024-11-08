public class sObjectListDemo {
    public static void AccountList() {
        // Create and insert Account 1
        Account acc1 = new Account(Name = 'Acc101', Active__c = 'Yes');
        insert acc1;
        
        // Create and insert Account 2
        Account acc2 = new Account();
        acc2.Name = 'Acc102';
        acc2.Active__c = 'Yes';
        insert acc2;
        
        // Create a list of Account objects and add new accounts to it
        List<Account> accList = new List<Account>();
        
        Account acc3 = new Account(Name = 'Acc103', Active__c = 'Yes');
        accList.add(acc3);
        
        Account acc4 = new Account();
        acc4.Name = 'Acc104';
        acc4.Active__c = 'Yes';
        accList.add(acc4);

        // Insert all accounts in the list with a single DML statement
        insert accList;
    }

    public static void PositionList() {
        // Create a list of Position__c objects and add new positions to it
        List<Position__c> posList = new List<Position__c>();
        
        Position__c pos1 = new Position__c(Name = 'acc299');
        posList.add(pos1);
        
        Position__c pos2 = new Position__c(Name = 'acc300');
        posList.add(pos2);

        // Insert all positions in the list with a single DML statement
        insert posList;
    }
}
