


/**
 * ENTERPRISE EVENT MANAGEMENT SYSTEM
 * 
 * This project demonstrates advanced Salesforce development skills including:
 * - Complex trigger frameworks with proper bulkification
 * - Advanced SOQL with dynamic queries and aggregations
 * - Integration patterns with external APIs
 * - Batch processing and asynchronous operations
 * - Custom metadata-driven configuration
 * - Advanced exception handling and logging
 * - Test-driven development with comprehensive coverage
 * 
 * Business Case: Multi-tenant event management platform supporting:
 * - Event creation and management
 * - Dynamic pricing based on demand
 * - Automated capacity management
 * - Real-time notifications
 * - Payment processing integration
 * - Analytics and reporting
 */

// =============================================================================
// CUSTOM OBJECTS STRUCTURE (for reference)
// =============================================================================
/*
Event__c:
- Name, Description__c, Start_Date__c, End_Date__c, Location__c
- Capacity__c, Available_Spots__c, Base_Price__c, Current_Price__c
- Event_Type__c, Status__c, Organizer__c (User lookup)

Registration__c:
- Event__c (lookup), Attendee__c (Contact lookup), Registration_Date__c
- Status__c, Amount_Paid__c, Payment_Method__c, Registration_Number__c

Event_Pricing_Rule__c:
- Event_Type__c, Capacity_Threshold__c, Price_Multiplier__c, Active__c

Notification_Log__c:
- Event__c, Recipient__c, Message__c, Status__c, Sent_Date__c, Type__c
*/

// =============================================================================
// 1. TRIGGER FRAMEWORK     Start: 18/07/2025 1:24 pm
// =============================================================================

/**
 * Generic Trigger Handler Framework
 * Implements proper bulkification and separation of concerns
 */
public abstract class TriggerHandler {
    private Boolean isTriggerExecuting;
    private Integer batchSize;
    
    public TriggerHandler() {
        this.isTriggerExecuting = Trigger.isExecuting;
        this.batchSize = Trigger.size;
    }
    
    public void run() {
        if (!validateRun()) return;
        
        switch on Trigger.operationType {
            when BEFORE_INSERT { beforeInsert(); }
            when BEFORE_UPDATE { beforeUpdate(); }
            when BEFORE_DELETE { beforeDelete(); }
            when AFTER_INSERT { afterInsert(); }
            when AFTER_UPDATE { afterUpdate(); }
            when AFTER_DELETE { afterDelete(); }
            when AFTER_UNDELETE { afterUndelete(); }
        }
    }
    
    // Virtual methods to be overridden
    protected virtual void beforeInsert() {}
    protected virtual void beforeUpdate() {}
    protected virtual void beforeDelete() {}
    protected virtual void afterInsert() {}
    protected virtual void afterUpdate() {}
    protected virtual void afterDelete() {}
    protected virtual void afterUndelete() {}
    
    private Boolean validateRun() {
        if (!this.isTriggerExecuting) {
            throw new TriggerException('Trigger handler called outside of trigger execution');
        }
        return true;
    }
    
    public class TriggerException extends Exception {}
}

// =============================================================================
// 2. EVENT TRIGGER HANDLER
// =============================================================================

/**
 * Event Trigger Handler with complex business logic
 */
    private List<Event__c> newEvents = (List<Event__c>) Trigger.new;
    private List<Event__c> oldEvents = (List<Event__c>) Trigger.old;
    private Map<Id, Event__c> newEventMap = (Map<Id, Event__c>) Trigger.newMap;
    private Map<Id, Event__c> oldEventMap = (Map<Id, Event__c>) Trigger.oldMap;
    
// .........