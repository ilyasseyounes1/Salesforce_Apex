/**
 * @description LoanTrigger - Financial Services Automation
 */
trigger LoanTrigger on Loan__c (before insert, before update, after insert, after update) {
    // Trigger logic handled by framework
    System.debug('LoanTrigger executed');
}
