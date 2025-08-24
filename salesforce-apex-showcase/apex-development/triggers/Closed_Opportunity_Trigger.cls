// 12/08/2025 / 01:24pm  Apex SuperBadge :)
trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
    List<Task> tasksToInsert = new List<Task>();

    for (Opportunity opp : Trigger.new) {
        Opportunity oldOpp = Trigger.isUpdate ? Trigger.oldMap.get(opp.Id) : null;

        // Check if Stage is Closed Won (and changed in case of update)
        if (opp.StageName == 'Closed Won' &&
            (Trigger.isInsert || (oldOpp != null && oldOpp.StageName != 'Closed Won'))) {

            Task followUpTask = new Task();
            followUpTask.Subject = 'Follow Up Test Task';
            followUpTask.WhatId = opp.Id; // Link task to the opportunity
            followUpTask.ActivityDate = System.today().addDays(7); // Optional: Due in 7 days
            followUpTask.Status = 'Not Started';
            followUpTask.Priority = 'Normal';
            
            tasksToInsert.add(followUpTask);
        }
    }

    // Bulk insert outside loop
    if (!tasksToInsert.isEmpty()) {
        insert tasksToInsert;
    }
}