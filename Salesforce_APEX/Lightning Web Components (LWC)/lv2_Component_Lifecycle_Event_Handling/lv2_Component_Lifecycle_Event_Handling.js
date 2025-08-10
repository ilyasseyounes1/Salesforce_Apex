import { LightningElement, track } from 'lwc';

export default class LifecycleDemo extends LightningElement {
    // Lifecycle tracking
    @track lifecycleStatus = {
        constructed: false,
        connected: false,
        rendered: false,
        disconnected: false
    };
    
    @track renderCount = 0;
    
    // Event handling properties
    @track inputValue = '';
    @track keyboardValue = '';
    @track focusValue = '';
    @track eventLog = [];
    
    // Private properties
    startTime = Date.now();
    
    // ============ LIFECYCLE HOOKS ============
    
    constructor() {
        super();
        this.logEvent('LIFECYCLE', 'Constructor called - Component created');
        this.lifecycleStatus = { ...this.lifecycleStatus, constructed: true };
        this.startTime = Date.now();
    }
    
    connectedCallback() {
        this.logEvent('LIFECYCLE', 'connectedCallback - Component inserted into DOM');
        this.lifecycleStatus = { ...this.lifecycleStatus, connected: true };
        this.initializeComponent();
    }
    
    renderedCallback() {
        this.renderCount++;
        this.logEvent('LIFECYCLE', `renderedCallback - Render #${this.renderCount}`);
        this.lifecycleStatus = { ...this.lifecycleStatus, rendered: true };
        this.updateDOMAfterRender();
    }
    
    disconnectedCallback() {
        this.logEvent('LIFECYCLE', 'disconnectedCallback - Component removed from DOM');
        this.lifecycleStatus = { ...this.lifecycleStatus, disconnected: true };
        this.cleanup();
    }
    
    errorCallback(error, stack) {
        this.logEvent('ERROR', `Error caught: ${error.message}`);
        console.error('Component Error:', error);
        console.error('Stack:', stack);
    }
    
    // ============ LIFECYCLE HELPER METHODS ============
    
    initializeComponent() {
        this.logEvent('INIT', 'Component initialization complete');
        setTimeout(() => {
            const firstInput = this.template.querySelector('lightning-input');
            if (firstInput) {
                // firstInput.focus(); // Uncomment if needed
            }
        }, 100);
    }
    
    updateDOMAfterRender() {
        const logContainer = this.template.querySelector('.log-container');
        if (logContainer) {
            logContainer.scrollTop = logContainer.scrollHeight;
        }
    }
    
    cleanup() {
        this.logEvent('CLEANUP', 'Cleaning up component resources');
    }
    
    // ============ EVENT HANDLERS ============
    
    handleSimpleClick(event) {
        this.logEvent('CLICK', 'Simple button clicked');
    }
    
    handleClickWithData(event) {
        const action = event.target.dataset.action;
        const id = event.target.dataset.id;
        this.logEvent('CLICK', `Button with data: action=${action}, id=${id}`);
    }
    
    handleInputChange(event) {
        this.inputValue = event.target.value;
        this.logEvent('INPUT', `Input changed: "${event.target.value}"`);
    }
    
    handleKeyUp(event) {
        this.keyboardValue = event.target.value;
        const keyInfo = `Key: ${event.key}, Code: ${event.code}`;
        this.logEvent('KEYUP', keyInfo);
        
        if (event.key === 'Enter') {
            this.logEvent('SPECIAL', 'Enter key pressed - could trigger action');
        } else if (event.key === 'Escape') {
            this.logEvent('SPECIAL', 'Escape key pressed - input cleared');
            event.target.value = '';
            this.keyboardValue = '';
        }
    }
    
    handleKeyDown(event) {
        this.logEvent('KEYDOWN', `Key down: ${event.key}`);
        
        if (event.key === 'Tab' && event.shiftKey) {
            this.logEvent('SPECIAL', 'Shift+Tab detected');
        }
    }
    
    handleFocus(event) {
        this.logEvent('FOCUS', 'Input gained focus');
    }
    
    handleBlur(event) {
        this.focusValue = event.target.value;
        this.logEvent('BLUR', `Input lost focus, final value: "${event.target.value}"`);
    }
    
    handleTriggerCustomEvent() {
        const customEvent = new CustomEvent('lifecycledemo', {
            detail: {
                message: 'Custom event triggered!',
                timestamp: new Date().toISOString(),
                data: { renderCount: this.renderCount }
            },
            bubbles: true
        });
        
        this.dispatchEvent(customEvent);
        this.logEvent('CUSTOM', 'Custom event dispatched');
    }
    
    // ============ UTILITY METHODS ============
    
    forceRerender() {
        this.lifecycleStatus = { ...this.lifecycleStatus };
        this.logEvent('ACTION', 'Force re-render triggered');
    }
    
    simulateError() {
        try {
            throw new Error('Simulated error for testing');
        } catch (error) {
            throw error;
        }
    }
    
    clearEventLog() {
        this.eventLog = [];
        this.logEvent('ACTION', 'Event log cleared');
    }
    
    logEvent(type, message) {
        const timestamp = new Date().toLocaleTimeString();
        const newLogEntry = {
            id: Date.now() + Math.random(),
            timestamp: timestamp,
            event: type,
            details: message
        };
        this.eventLog = [newLogEntry, ...this.eventLog.slice(0, 9)];
    }
    
    // ============ GETTERS ============
    
    get isEventLogEmpty() {
        return this.eventLog.length === 0;
    }
}