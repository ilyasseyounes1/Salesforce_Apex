// Trigger -----------------------------
trigger AccountTrigger on Account (after insert) {
    AccountTriggerHandler.createOpportunitiesForActiveAccounts(Trigger.new);
}
// Trigger Handler ------------------------
public class AccountTriggerHandler {

    public static void createOpportunitiesForActiveAccounts(List<Account> newAccounts) {
        List<Opportunity> oppList = new List<Opportunity>();

        for (Account acc : newAccounts) {
            if (acc.Active__c == 'Yes') {
                Opportunity opp = new Opportunity(
                    Name = acc.Name + ' Opportunity',
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addDays(30),
                    AccountId = acc.Id
                );
                oppList.add(opp);
            }
        }

        if (!oppList.isEmpty()) {
            insert oppList;
        }
    }
}

// Test Class ---------------------------------

@isTest
private class AccountTriggerHandlerTest{
    @isTest
    static void createOppTest (){
        List<Account> accList = new List<Account>();
        for (Integer i=1 ; i<=10 ; i++){
            acc.Name = 'Test'+i;
            acc.Active__c = 'Yes';
            accList.add(acc);

        }
        Test.startTest();
        insert accList;
        Test.stopTest();

        List<Opportunity> oppList = [SELECT Id
                                    From Opportunity
                                    WHERE AccountId =: accList[0].Id
                                    ];
        System.assert(oppList!= null , 'Opportunity is not Created 1');

    }
}