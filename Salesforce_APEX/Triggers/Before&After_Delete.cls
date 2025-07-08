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
}

trigger AccountTrigger on Account (before delete) {
    // No need to check isDelete since it's only defined on before delete
    AccountTriggerHandler.preventDeletion(Trigger.old);
}
