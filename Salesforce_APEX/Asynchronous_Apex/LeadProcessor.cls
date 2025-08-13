public class LeadProcessor implements Database.Batchable<SObject> {

    // Start method: returns all Lead records
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, LeadSource FROM Lead]);
    }

    // Execute method: updates LeadSource to "Dreamforce"
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Lead> leadsToUpdate = new List<Lead>();
        for (SObject s : scope) {
            Lead l = (Lead) s;
            l.LeadSource = 'Dreamforce';
            leadsToUpdate.add(l);
        }
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }

    // Finish method: can be used for post-processing logs
    public void finish(Database.BatchableContext bc) {
        // Optional: system log or email notification
        System.debug('LeadProcessor batch completed.');
    }
}
/**
    @isTest
public class LeadProcessorTest {
    @isTest
    static void testLeadProcessorBatch() {
        // Create 200 test Leads
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            leads.add(new Lead(
                FirstName = 'TestFirst' + i,
                LastName = 'TestLast' + i,
                Company = 'TestCompany' + i
            ));
        }
        insert leads;

        // Run the batch
        Test.startTest();
        LeadProcessor batch = new LeadProcessor();
        Database.executeBatch(batch, 50);
        Test.stopTest();

        // Verify all Leads were updated to "Dreamforce"
        for (Lead l : [SELECT LeadSource FROM Lead]) {
            System.assertEquals('Dreamforce', l.LeadSource, 'LeadSource should be updated to Dreamforce');
        }
    }
}

 */