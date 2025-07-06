public class AccountTriggerHandler{} 
    public static void  updatePhone (List<Account> accList , Map<Id, Account> accOldMap = new Map<Id, Account>()){
    for (Account acc : accList){
        if (acc.Phone != accOldMap.get(acc.Id).Phone){
            acc.Description = 'Phone is Updated | Old value = '+ accOldMap.get(acc.Id).Phone +'New value = ' +acc.Phone ;
        }
    }
}

Trigger AccountTrigger on Account (befoe Update){
    if (Trigger.isUpdate){
        if (Trigger.isBefore){
            AccountTriggerHandler.updatePhone(Trigger.New , Trigger.oldMap);
        }
    }
}

//*************** Update Rating if the record is Update or Create (insert or update ) : ******************************************* */
public class AccountTriggerHandler {
    public static void populateRating (List<Account> accList , Map<Id,Account> accOldMap){
        for (Account acc : accLit ){
            if (accOldMap == null && acc.industry != null && acc.industry == 'Media')
           || ( acc.industry  != accOldMap.get(acc.Id).industry && acc.industry == 'Media'){
                acc.Rating = 'Hot';
            }
        }
    }
}


trigger AccountTrigger on Account (before insert , after insert , before  update){
    if (Trigger.isInsert){
        if(Trigger.isBefore ){
            AcountTriggerHandler.updateDesc(Trigger.New);
            AccountTriggerHandler.populateRating(Trigger.New,null); //??

        }else if (Trigger.isAfter){}

    }
     if (Trigger.isUpdate){
        if (Trigger.isBefore){
            AccountTriggerHandler.updatePhone(Trigger.New,Trigger.oldMap);
            AccountTriggerHandler.populateRating(Trigger.New, Trigger.oldMap); //??

        }

    }
    
}