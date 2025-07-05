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

//*******************"Customer Onboarding System"******************************/

Trigger CustomerTrigger on Customer__c (before insert , after insert){
    // BEFORE INSERT: Set defaults and validation ;
    if (Trigger.isBefore && Trigger.isInsert){
        for (Customer__c cust : Trigger.New){
            if (cust.Status__c == null ){
                cust.Status__c = 'New';
            }
            // validate email domain :
            if (cust.Email__c != null && !cust.Email__c.endWith('@company.com')){
                cust.addError('Email must be from @company.com domain.');
            }
        }
    }
    // AFTER INSERT :  creat welcome task + send welcom email :
     if (Trigger.isAfter && Trigger.isInsert){
        List<Welcom__task__c>  task = new List<Welcom__task__c>();

        for (Customer__c cust : Trigger.New){
            tasks.add(new Welcom__task__c(
                Customer__c = cust.Id,
                task_Description__c = 'Call customer and explain onboarding steps.' )
            );
            // Async welcom email: 
            CustomerService.sendWelcomeEmailAsync(cust.Email__c);
        }
        insert tasks;
     }
}