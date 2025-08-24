public class AccountTriggerHandler {
    
    // 1. Update description when phone changes
    public static void updatePhone(List<Account> accList, Map<Id, Account> accOldMap) {
        for (Account acc : accList) {
            if (acc.Phone != accOldMap.get(acc.Id).Phone) {
                acc.Description = 'Phone is Updated | Old value = ' + accOldMap.get(acc.Id).Phone + ' | New value = ' + acc.Phone;
            }
        }
    }

    // 2. Set Rating to 'Hot' if Industry is Media (on insert or update)
    public static void populateRating(List<Account> accList, Map<Id, Account> accOldMap) {
        for (Account acc : accList) {
            // INSERT
            if (accOldMap == null && acc.Industry != null && acc.Industry == 'Media') {
                acc.Rating = 'Hot';
            }
            // UPDATE
            else if (accOldMap != null && acc.Industry != accOldMap.get(acc.Id).Industry && acc.Industry == 'Media') {
                acc.Rating = 'Hot';
            }
        }
    }

    // 3. Update related contacts if Account phone is updated
    public static void updateRelatedContact(List<Account> accList, Map<Id, Account> accOldMap) {
        Map<Id, Account> accMap = new Map<Id, Account>();
        List<Contact> conList = new List<Contact>();

        for (Account acc : accList) {
            if (acc.Phone != accOldMap.get(acc.Id).Phone) {
                accMap.put(acc.Id, acc);
            }
        }

        if (!accMap.isEmpty()) {
            for (Contact con : [SELECT Id, HomePhone, AccountId FROM Contact WHERE AccountId IN :accMap.keySet()]) {
                if (accMap.containsKey(con.AccountId)) {
                    con.HomePhone = accMap.get(con.AccountId).Phone;
                    conList.add(con);
                }
            }

            if (!conList.isEmpty()) {
                update conList;
            }
        }
    }

    // 4. (Optional) Add a method to set default Description on insert
    public static void updateDesc(List<Account> accList) {
        for (Account acc : accList) {
            acc.Description = 'New Account Created';
        }
    }
}



trigger AccountTrigger on Account (before insert, after insert, before update, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AccountTriggerHandler.updateDesc(Trigger.New);
            AccountTriggerHandler.populateRating(Trigger.New, null); // null for oldMap in insert
        }
        else if (Trigger.isUpdate) {
            AccountTriggerHandler.updatePhone(Trigger.New, Trigger.oldMap);
            AccountTriggerHandler.populateRating(Trigger.New, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            AccountTriggerHandler.updateRelatedContact(Trigger.New, Trigger.oldMap);
        }
        // No logic yet in after insert — safe to leave empty or add later
    }
}
