public class DailyOppProcessor implements schedulable {
    public void execute(Schedulablecontext ctx){
        List<Opportunity> opplist = [SELECT Id,LeadSource FROM Opportunity
                                    WHERE LeadSource = null LIMIT 200];
        for (Opportunity opp: opplist){
            opp.LeadSource = 'Web';
        }
        if (!opplist.isEmpty()){
            update opplist;
        }
}
}
// last part : in Setup "Apex classes then Schedual Apex ..." 

//---------------- Test Class 
@isTest
public class DailyOppProcessorTest {
    @TestSetup
    static void setupTestDate(){
        List<Opportunity> opplist = new List<Opportunity>();
        for (Integer i=1;i<=50;i++){
        opp.Name = 'Test_ilyasse'+i;
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today().addDays(30);
        opp.LeadSource = null //this will be updated by the scheduled job
        oppList.add(opp);
        }
        insert oppList;
        
    }
    @isTest 
    static void testDailyOppProcessoScheduledJob(){
        // verify init state - all opportunity have null leadSource 
        List<Opportunity> nullLeadSourceOpps = [SELECT Id,LeadSourd From Opportunity WHERE LeadSource = null];
        System.assertEquals(50,nullLeadSourceOpps.size() , 'should have 50 opp with null LeadSource....');
        
        Test.startTest();
        String cornExpression = '0 0 2 * * ?';
        Stirng jobName = 'Daily Opp Processor Job';
        DailyOppProcessor processor = new DailyOppProcessor();
        String jobId = System.schedule(jobName,cornExpression,processed);
        
        Test.stopTest();
    }
}