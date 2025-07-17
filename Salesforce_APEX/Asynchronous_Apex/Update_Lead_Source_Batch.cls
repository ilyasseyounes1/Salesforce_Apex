public class Batch_Opp_LeadCource_update implements Database.batchable<sObject> ,Database.stateful {//  Allows the class to maintain state (variable values) across batch transactions
    public Integer recordCount = 0;

    public Database.QueryLocator start(Database.batchableContext bc){
        return Database.getQueryLocator([SELECT Id,LeadSource From Opportunity]);
    }
    public void execute (Database.batchableContext bc , List<Opportunity> opps){
        if (!opps.isEmpty()){
            for (Opportunity opp : opps){
                opp.LeadSource = 'Web';
            }
            update opps;
            recordCount = recordCount + opps.size();
        }
    }
    public void finish (database.BatchableContext bc ){
        System.debug('Total records processed '+ recordCount);
    }
}
//------------- : Anonymos wind-----------------------------
Batch_Opp_LeadCource_update opp = new Batch_Opp_LeadCource_update();
Id bachId = Database.executeBatch(opp,20); // 20 to set up total batches manualy default is 200 , now 20
//--------------: Test class -------------------------------

@isTest
public class DataFactory {
    public static List<Opportunity> createOpp(String OpportunityN, String Stage, String CloseDate, Integer Count, Boolean isInsert) {
        List<Opportunity> oppList = new List<Opportunity>();
        
        for (Integer i = 1; i <= Count; i++) {
            Opportunity opp = new Opportunity();
            opp.Name = OpportunityN + i;
            opp.StageName = Stage;
            opp.CloseDate = Date.valueOf(CloseDate);
            opp.LeadSource = 'Phone'; // Set initial value to test the update
            oppList.add(opp);
        }
        
        if (isInsert) {
            insert oppList;
        }
        
        return oppList;
    }
}

@isTest
private class MyOppTest {
    
    @isTest
    static void TestOpp() {
        // Create test data
        List<Opportunity> oppList = DataFactory.createOpp('Test', 'Closed Won', '2025-09-23', 10, true);
        
        Test.startTest();
        // Execute batch
        Batch_Opp_LeadCource_update oppBatch = new Batch_Opp_LeadCource_update();
        Id batchId = Database.executeBatch(oppBatch);
        Test.stopTest();
        
        // Query updated records
        List<Opportunity> oppUpdated = [SELECT Id, LeadSource FROM Opportunity WHERE Name LIKE 'Test%'];
        
        // Assertions
        System.assertEquals(10, oppUpdated.size(), 'Should have 10 opportunities');
        
        for (Opportunity opp : oppUpdated) {
            System.assertEquals('Web', opp.LeadSource, 'LeadSource should be updated to Web');
        }
    }
}