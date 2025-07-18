public class AccountTriggerHandler {
        public static void UpdateAccountDesc (List<Account> accList , Map<Id,Account> accOldMap ){
        List<Account> accToBeUpdated = new list<Account> ();

        for (Account acc : accList){
            Account a = new Account();
            a.id = acc.Id ;
            a.Description = 'Test Recursion ';
            
            accToBeUpdated.add(a);
        }
        if (!accToBeUpdated.isEmpty()){
            update accToBeUpdated;
        }

    }
}
public class PreventRecursion{
    public static Boolean fistCall = false ;
}



Trigger AccountTrigger on Account (before update , after update){
    if(Trigger.isAfter){
        if (!PreventRecursion.fistCall){
            PreventRecursion.fistCall = true;
        AccountTriggerHandler.UpdateAccountDesc(Trigger.New , Trigger.oldMap);
        }
    }
}

///************************************************************************* */
// updates the Description field of an Account record to "Test Recursion" after it is updated,
// but ensures that this logic is executed only once per transaction to prevent infinite recursion.

public class AccountTriggerHandler {
    public static void updateAccountDesc(List<Account> accList, Map<Id, Account> accOldMap) {
        List<Account> accToBeUpdated = new List<Account>();

        for (Account acc : accList) {
            Account oldAcc = accOldMap.get(acc.Id);
            
            // Only update if description is not already "Test Recursion"
            if (acc.Description != 'Test Recursion') {
                Account a = new Account(Id = acc.Id);
                a.Description = 'Test Recursion';
                accToBeUpdated.add(a);
            }
        }

        if (!accToBeUpdated.isEmpty()) {
            update accToBeUpdated;
        }
    }
}
public class PreventRecursion {
    public static Boolean firstCall = false;
}

trigger AccountTrigger on Account (before update, after update) {
    if (Trigger.isAfter && !PreventRecursion.firstCall) {
        PreventRecursion.firstCall = true;
        AccountTriggerHandler.updateAccountDesc(Trigger.new, Trigger.oldMap);
    }
}


//*************************  ****************************** */
/*  When an opportunity is updated to "Closed Won" or "Closed Lost", 
then update the description with 'Opportunity is Closed Won' or 'Opportunity is Closed Lost' as per the stage. */

public class OpportunityTriggerHandler {
    public static void updateOpportunityDescription (List<Opportunity>oppList , Map<Id,Opportunity> oldMap){
        List<Opportunity> oppToUpdate = new List <Opportunity>();

        for (Opportunity opp : oppList){
            Opportunity oldOpp = oldMap.get(opp.Id);

            // check if stage changed to Close Won or Close Lost : 
            if (opp.StageName == 'Close Won' || opp.StageName == 'Close Lost '
                && opp.satgeName !=  oldOpp.StageName ){
                    Opportunity updateOpp = new Opportunity(Id = opp.Id);

                    if (opp.StageName == 'Close Won'){
                        updateOpp.Description == 'Opportunity is Closed ';
                    }
                    if (opp.StageName == 'Close Lost '){
                        updateOpp.Description = 'Opportunity is closed Lost'
                    }

                    oppToUpdate.add(updateOpp);

            }
        }
        if (!oppToUpdate.isEmpty()){
            update oppToUpdate;
        }
    }
}

trigger OpportunityTrigger on Opportunity (after update) {
    OpportunityTriggerHandler.updateOpportunityDescription(Trigger.new, Trigger.oldMap);
}


