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