/**
 * @description AccountTriggerHandler - Business Logic Handler
 */
public with sharing class AccountTriggerHandler {
    
    public void handleBeforeInsert(List<SObject> newRecords) {
        System.debug('AccountTriggerHandler - Before Insert');
    }
    
    public void handleAfterInsert(List<SObject> newRecords) {
        System.debug('AccountTriggerHandler - After Insert');  
    }
}
