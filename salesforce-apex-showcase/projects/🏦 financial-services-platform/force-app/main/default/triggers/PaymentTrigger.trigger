/**
 * @description PaymentTrigger - Financial Services Automation
 */
trigger PaymentTrigger on Payment__c (before insert, before update, after insert, after update) {
    // Trigger logic handled by framework
    System.debug('PaymentTrigger executed');
}
