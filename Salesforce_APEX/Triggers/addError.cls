public class OpportunityTriggerHandler {
    public static void validateAmount (List<Opportunity> oppList ){
        for (Opportunity opp : oppList ){
            if (opp.Amount == null ){
                opp.addError('Please populate Amount on Opportunity .');
            }
        }
    }
}
Trigger OpportunityTrigger on Opportunity (before insert ){
    OpportunityTriggerHandler.validateAmount(Trigger.new);
}

//************ Business Rule Enforcement (e.g., Opportunity Stage)**************************************** */
trigger OpportunityTrigger on Opportunity (before update) {
    for (Opportunity opp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

        if (oldOpp.StageName == 'Closed Won' && opp.StageName != 'Closed Won') {
            opp.StageName.addError('You cannot change the stage after it is Closed Won.');
        }
    }
}

//************************************************************* */
trigger OpportunityTrigger on Opportunity (before insert, before update) {
    Set<Id> accIds = new Set<Id>();
    for (Opportunity opp : Trigger.new) {
        if (opp.AccountId != null) {
            accIds.add(opp.AccountId);
        }
    }

    Map<Id, Account> accounts = new Map<Id, Account>(
        [SELECT Id, Industry FROM Account WHERE Id IN :accIds]
    );

    for (Opportunity opp : Trigger.new) {
        Account relatedAcc = accounts.get(opp.AccountId);
        if (relatedAcc != null && relatedAcc.Industry == 'Banking') {
            opp.addError('Opportunities for Banking accounts must be handled manually.');
        }
    }
}
