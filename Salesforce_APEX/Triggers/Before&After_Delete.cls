    // Prevent Deletion of an Active__c Account , and check for System Admin requirement : 
public class AccountTriggerHandler {
    public static void preventDeletion(List<Account> accList) {
        Profile p = [SELECT ID FROM Profile
                    WHERE Name = 'System Administrator' ]
        for (Account acc : accList) {
            if (UserInfo.getProfileId() != p.Id || acc.Active__c == 'Yes') {
                //acc.addError('Active Account cannot be deleted');
                // Best Practice.
                acc.addError(Lable.Prevent_Account_Deletion);// use custom labe for error.
            }
        }
    }
    public static void updateTotaleCountOnAccount (){

    }
}

trigger AccountTrigger on Account (before delete) {
    if (TriggerisDelete){
        if (Trigger.isBefore){
            AccountTriggerHandler.preventDeletion(Trigger.old);
        }else if (Trigger.isAfter){
            AccountTriggerHandler.
        }
    }
}
//***************************************************************** */
//AFTER DELETE: when a contact record is deleted then update "Taotal Contact" field on related Account.
public class ContactTriggerHandler {
    public static void totalContactCount(List<Contact> conList){
        List<Account> accList = new List<Account>();
        Set<Id> accIds = new Set<Id>();

        for (Contact con : conList){
            if (AccountId != null){
                accIds.add(con.AccountId);
            }
        }
        for (Account acc : [SELECT Id, (SELECT Id FROM Contacts)
                            FROM  Account WHERE Id IN: accIds]){
                                acc.Total_Contact_Count__c = acc.Contacts.size();
                                accList.add(acc);
                            }
    }

}

Trigger ContactTrigger on Contact (After insert , after delete, after undelete ){
    if (Trigger.isInsert){
        if(Trigger.isAfter){

        }

    }
    if (Trigger.isDelete){
        if (Trigger.isAfter){

        }

    }
    if (Trigger.isUndelete){
        if (Trigger.isAfter){

        }

    }
}