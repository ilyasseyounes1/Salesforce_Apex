public class AccountTriggerHandler {
    public static Boolean handleAccount (List<Account> accList ){

        if (Trigger.isExcuting){
            // do whatever you want to do as part of trigger invocation: 
            System.debug('trigger is executing : ' + Trigger.isExcuting);
        }else {
            // do whatever u want to do if the call originated from diffent context .
            System.debug('Without Trigger');
            //Anonymose window


        }

    }
    return ture ;
}
//********************************************************************************* */
public class AccountTriggerHandler {
    
    // Static variable to prevent recursion
    private static Boolean hasAlreadyRun = false;

    // Handle before-insert logic
    public static void handleBeforeInsert(List<Account> accList) {
        // Avoid recursive execution
        if (hasAlreadyRun) return;
        hasAlreadyRun = true;

        if (Trigger.isExecuting) {
            System.debug('Trigger is executing - BEFORE INSERT');

            for (Account acc : accList) {
                // Example: Auto-set Description field if not provided
                if (String.isBlank(acc.Description)) {
                    acc.Description = 'Created via trigger on ' + Date.today();
                }

                // Example: Auto-categorize account based on name
                if (acc.Name != null && acc.Name.containsIgnoreCase('Inc')) {
                    acc.Type = 'Customer';
                }
            }
        } else {
            System.debug('Method called outside of trigger context (anonymous window, etc.)');
        }
    }
}

    // Handle before-update logic
    public static void handleBeforeUpdate(List<Account> accList, Map<Id, Account> oldMap) {
        if (hasAlreadyRun) return;
        hasAlreadyRun = true;

        if (Trigger.isExecuting) {
            System.debug('Trigger is executing - BEFORE UPDATE');

            for (Account acc : accList) {
                Account oldAcc = oldMap.get(acc.Id);

                // Example: Prevent changing the Account Name if it's already set
                if (oldAcc.Name != null && acc.Name != oldAcc.Name) {
                    acc.addError('Account name cannot be changed after creation.');
                }

                // Example: Track description changes
                if (acc.Description != oldAcc.Description) {
                    System.debug('Description was changed from "' + oldAcc.Description + '" to "' + acc.Description + '"');
                }
            }
        } else {
            System.debug('Method called outside of trigger context');
        }
    }


trigger AccountTrigger on Account (before insert, before update) {
    // Call the handler class method and pass the list of Accounts
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AccountTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            AccountTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
