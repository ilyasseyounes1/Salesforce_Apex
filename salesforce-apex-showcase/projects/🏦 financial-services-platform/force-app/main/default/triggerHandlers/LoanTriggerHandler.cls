/**
 * @description LoanTriggerHandler - Business Logic Handler
 */
public with sharing class LoanTriggerHandler {
    
    public void handleBeforeInsert(List<SObject> newRecords) {
        System.debug('LoanTriggerHandler - Before Insert');
    }
    
    public void handleAfterInsert(List<SObject> newRecords) {
        System.debug('LoanTriggerHandler - After Insert');  
    }
}
