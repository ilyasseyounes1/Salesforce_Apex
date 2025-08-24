/**
 * @description PaymentTriggerHandler - Business Logic Handler
 */
public with sharing class PaymentTriggerHandler {
    
    public void handleBeforeInsert(List<SObject> newRecords) {
        System.debug('PaymentTriggerHandler - Before Insert');
    }
    
    public void handleAfterInsert(List<SObject> newRecords) {
        System.debug('PaymentTriggerHandler - After Insert');  
    }
}
