/************** Insert Records : ****************************************** */
public class DML_Demo {
    public static void insertDemo() {

        List<Account> accList = new List<Account>();

        Account acc = new Account();
        acc.Name = 'Test DML 1';
        acc.Active__c = 'Yes';
        accList.add(acc);

        Account acc1 = new Account();
        acc1.Name = 'Test DML 2';
        acc1.Active__c = 'Yes';
        accList.add(acc1);

        insert accList;

        List<Contact> conList = new List<Contact>{
            new Contact(
                FirstName = 'ilyas',
                LastName = 'younes',
                AccountId = accList[0].Id
            ),
            new Contact(
                FirstName = 'moracami',
                LastName = 'sora',
                AccountId = accList[1].Id
            )
        };

        insert conList;
    }
/*******************bulk insert version *************************************************** */
//Loop to create 100 Accounts → You can scale this up to 10,000 safely.
//voids governor limits (only 2 DML statements used, no matter how many records).
        
        List<Account> accList = new List<Account>();
        for (Integer i = 1; i <= 100; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account ' + i;
            acc.Active__c = 'Yes';
            accList.add(acc);
        }
        
        insert accList;
        //DML statements per tx	150 max
        //Records per DML operation	10,000

}
//******************* Update ****************************************************************** */
    List<Accoutn>  acclsit = new List<Account>();
    acc1lsit = [SELECT Id ,Name ,Rating FROM Account 
                WHERE  Rating = 'Hot'];

    if (!acc1lsit.isEmpty()) {
        for (Account acc : acclsit){
            acc.Industry = 'Media';
            acc.Active__c = 'Yes';
        } 
        Update acclsit;
    }





