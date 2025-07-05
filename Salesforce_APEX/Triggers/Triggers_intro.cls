Trigger AcountTrigger on Account (before insert){
    System.debug(acc);
}

trigger AccountTrigger1 on Account (before insert ){
    if (Trigger isIsert ){
        if (Trigger isBefore ){
            // Trigger.New is a sObj list.
            for (Account acc : Trigger.New) {
                acc.Description = 'Account is created ';
            }
        }
    }
}
//************** Trigger and TriggerHandler : *********************************** */
        // trigger Class : code logic 
public class AccountTriggerHandler {
    public static void updateDesc (List<Account> accList){
        for (Account acc : accList){
            acc.Description = 'Account is created';
        }
    }
}


Trigger AccountTrigger on Account (before insert ){
    if (Trigger.isBefore){

        AccountTriggerHandler.updateDesc(Trigger.New);
    }
}
//*********************************************************** */

public class AccountTriggerHandler {
    public static void updateDesc(List<Account> accList){
        for (Account acc : accList){
            acc.Description = 'new Record Added';
        }
    }
    public static void createOpp (List<Account> accList){
        List<Opportunity> oppList = new List<Opportunity>();
        for (Account acc : accList){
            Opportunity opp = new Opportunity();
            opp.Name = acc.Name;
            opp.CloseDate = System.today();
            opp.StageName ='Prospecting';
            opp.AccountId = acc.Id;
            // acc.AnnualRevenu = 1000; Erorr : Read only
            oppList.add(opp);
            
        }
        if (!oppList.isEmpty()){
            insert oppList;
        }
    }

trigger AccountTrigger1 on Account (before insert ,after insert) {
    if (Trigger.isInsert){
        if (Trigger.isefore){
            AccountTriggerHandler.updateDesc(Trigger.new);
           
        }else if (Trigger.isAfter){
            AccountTriggerHandler.createOpp(Trigger.New);
        }
    }
}

//***************************************************************** */
trigger LeadAfterInsert on Lead (after insert) {
    for (Lead l : Trigger.new) {
        if (l.Email != null) {
            ExternalSync.sendLeadEmailAsync(l.Email);
        }
    }
}

// Separate class with future method
public class ExternalSync {
    @future
    public static void sendLeadEmailAsync(String email) {
        // Make HTTP callout or external sync
        System.debug('Sending email: ' + email);
    }
}
