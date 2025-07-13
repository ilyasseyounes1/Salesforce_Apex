public with sharing class AccountWrapperDemo {
    @AuraEnabled
    public static List<AccountWrapper> getAccountWithContact (){
        List<AccountWrapper> warpList = new List<AccountWrapper>();
        List<Account> accList = [SELECT Id,Name 
                                (SELECT Id, FistName,LastName FROM Contact)]
                                From Account LIMIT 10 
        if (!accList.isEmpty()){
            for (Account acc : accLsit ){
                warpList.add(new AccountWrapper(acc, acc.Contact));
            }
        }
        return warpList;
    }
    public class AccountWrapper {
        @AuraEnabled public Account accRecord {get;set;}
        @AuraEnabled public List<Contact> conList {get;set;}

        // Constructor : 
        public AccountWrapper (Account accRecord , list<Contact> conList){
            this.accRecord = accRecord;
            this.conList = conList;
        }
    }
}
/*  🔐 What is Enforcing Sharing?
When you enforce sharing, record-level access (like ownership, sharing rules, etc.) 
is respected. This ensures that the Apex code behaves like a regular user, 
not like an admin. */

/* ⚠ Important Notes
Apex triggers always run in system context, regardless of with sharing.
If your class calls another class, the outermost class’s sharing declaration applies 
(unless the inner class is without sharing, which overrides).
Use with sharing when you want your code to act like a user in terms of record access. */