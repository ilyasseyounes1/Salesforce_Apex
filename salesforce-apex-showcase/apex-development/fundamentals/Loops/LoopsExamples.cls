// Apex class for looping through Cases and updating their status
public class CaseLoopExample {
    
    // Method to demonstrate different types of loops in Salesforce Apex
    public void processCases() {
        
        // Step 1: Query a list of Case records (SELECT statement)
        List<Case> cases = [SELECT Id, CaseNumber, Status FROM Case];

        // Step 2: Loop through the list of cases using a 'for' loop
        for (Integer i = 0; i < cases.size(); i++) {
            Case c = cases[i];  
            System.debug('Case Id: ' + c.Id + ', Case Number: ' + c.CaseNumber);
        }
        
        // Step 3: Loop through the list of cases using a 'for-each' loop
        for (Case c : cases) {
            System.debug('Case Id: ' + c.Id + ', Status: ' + c.Status);
        }

        // Step 4: Using a 'while' loop to go through the list of cases
        Integer index = 0;
        while (index < cases.size()) {
            Case c = cases[index];  
            System.debug('Case Id: ' + c.Id + ', Case Number: ' + c.CaseNumber);
            index++;  
        }
        
        // Step 5: Example of updating Case status using a loop
        // Query a list of cases that are in 'New' status
        List<Case> casesToUpdate = [SELECT Id, Status FROM Case WHERE Status = 'New'];
        
        // Loop through the casesToUpdate list and modify their status
        for (Case c : casesToUpdate) {
            // If the case is 'New', change its status to 'In Progress'
            if (c.Status == 'New') {
                c.Status = 'In Progress';
            }
        }
        
        // Perform a bulk DML update to save the changes to the records
        update casesToUpdate;  // Update all modified cases in a single DML operation
    }
}
