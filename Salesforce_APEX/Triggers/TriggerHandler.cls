public class AccountTriggerHandler {
    public static void updateDesc(List<Account>){
        for (Account acc : accList){
            acc.Description = 'Account newly created';
        }
    }
    public static void PopulateRating(List<Account>){
        // no problem for rpeating AccList because it s in a local scoupe.
        for (Account acc: accList ){
            if (acc.industry != null && acc.industry = 'Media'){
                acc.Rating = 'Hot';
            }
        }
        

    }
}


Tirgger AccountTrigger on Account (before insert ){

    if (trigger.isInsert){
        AccountTriggerHandler.updateDesc(Trigger.New);
        AccountTriggerHandler.PopulateRating(Trigger.New);
    }
}